import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/lesson.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

/// Écran détail d'une leçon financière
class LessonDetailScreen extends ConsumerWidget {
  final String lessonId;
  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = LessonsData.findById(lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leçon introuvable')),
        body: const EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Leçon introuvable',
          subtitle: 'Cette leçon n\'existe pas.',
        ),
      );
    }

    final progressAsync = ref.watch(lessonProgressProvider);
    final isCompleted = progressAsync.value
            ?.any((p) => p.lessonId == lessonId && p.completed) ??
        false;

    Color levelColor;
    switch (lesson.level) {
      case 'Intermédiaire':
        levelColor = AppColors.levelIntermediaire;
      case 'Avancé':
        levelColor = AppColors.levelAvance;
      default:
        levelColor = AppColors.levelDebutant;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(lesson.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header leçon
                    HezaCard(
                      backgroundColor: AppColors.primary,
                      child: Row(children: [
                        Text(lesson.emoji,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lesson.title,
                                  style: AppTextStyles.headlineSmall
                                      .copyWith(color: Colors.white)),
                              const SizedBox(height: 6),
                              Row(children: [
                                HezaBadge(
                                  label: lesson.level,
                                  backgroundColor:
                                      levelColor.withOpacity(0.2),
                                  textColor: levelColor,
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.timer_outlined,
                                    size: 13, color: Colors.white70),
                                const SizedBox(width: 3),
                                Text(lesson.duration,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: Colors.white70)),
                              ]),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Contenu de la leçon
                    ...lesson.content.trim().split('\n').map((line) {
                      final trimmed = line.trim();
                      if (trimmed.isEmpty) {
                        return const SizedBox(height: 10);
                      }
                      // Lignes bullet point
                      if (trimmed.startsWith('•')) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 8, bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•  ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.action)),
                              Expanded(
                                child: Text(
                                  trimmed.substring(1).trim(),
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // Lignes numérotées
                      if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(trimmed,
                              style: AppTextStyles.bodyMedium),
                        );
                      }
                      // Titres secondaires (en MAJUSCULES)
                      if (trimmed == trimmed.toUpperCase() &&
                          trimmed.length > 3) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            trimmed,
                            style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary),
                          ),
                        );
                      }
                      // Paragraphe normal
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(trimmed,
                            style: AppTextStyles.bodyMedium),
                      );
                    }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bouton "Marquer comme lu"
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingPage),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isCompleted
                      ? null
                      : () async {
                          await ref
                              .read(lessonProgressDaoProvider)
                              .markCompleted(lessonId);
                          // Badge apprenti investisseur
                          final count = await ref
                              .read(lessonProgressDaoProvider)
                              .getCompletedCount();
                          if (count >= 3) {
                            await ref
                                .read(earnedBadgesDaoProvider)
                                .awardBadge('learner');
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Murakoze ! Leçon complétée 🎓'),
                                backgroundColor: AppColors.action,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8)),
                              ),
                            );
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        isCompleted ? AppColors.divider : AppColors.action,
                  ),
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.check_rounded,
                    color: isCompleted
                        ? AppColors.textSecondary
                        : Colors.white,
                  ),
                  label: Text(
                    isCompleted ? 'Leçon complétée ✓' : 'Marquer comme lu',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isCompleted
                          ? AppColors.textSecondary
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
