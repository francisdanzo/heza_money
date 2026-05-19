import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/models/lesson.dart';
import '../../features/gamification/badges_screen.dart' show showBadgeUnlocked;
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

class LessonDetailScreen extends ConsumerWidget {
  final String lessonId;
  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t      = HezaTheme.of(context);
    final lesson = LessonsData.findById(lessonId);

    if (lesson == null) {
      return Scaffold(
        appBar: GlassAppBar(title: 'Leçon introuvable'),
        body: const EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Leçon introuvable',
          subtitle: 'Cette leçon n\'existe pas.',
        ),
      );
    }

    final progressAsync = ref.watch(lessonProgressProvider);
    final isCompleted   = progressAsync.value?.any((p) => p.lessonId == lessonId && p.completed) ?? false;

    final levelColor = switch (lesson.level) {
      'Intermédiaire' => HezaColors.warning,
      'Avancé'        => const Color(0xFF9C27B0),
      _               => HezaColors.primaryLight,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // ── Custom glass app bar ─────────────────────────────────────────
          _LessonAppBar(lesson: lesson, levelColor: levelColor, t: t),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildContent(lesson.content.trim(), t),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bottom action ────────────────────────────────────────────────
          _MarkDoneBar(
            isCompleted: isCompleted,
            t: t,
            onDone: () async {
              await ref.read(lessonProgressDaoProvider).markCompleted(lessonId);
              final count = await ref.read(lessonProgressDaoProvider).getCompletedCount();

              final newBadges = <String>[];
              final badgesDao = ref.read(earnedBadgesDaoProvider);
              if (count >= 3 && !await badgesDao.hasBadge('learner')) {
                await badgesDao.awardBadge('learner');
                newBadges.add('learner');
              }
              if (count >= 6 && !await badgesDao.hasBadge('all_lessons')) {
                await badgesDao.awardBadge('all_lessons');
                newBadges.add('all_lessons');
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Murakoze ! Leçon complétée'),
                  backgroundColor: HezaColors.primaryLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HezaRadius.md)),
                ));
                context.pop();
                for (final id in newBadges) {
                  if (context.mounted) showBadgeUnlocked(context, id);
                }
              }
            },
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildContent(String content, HezaTheme t) {
    return content.split('\n').map((line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return const SizedBox(height: 10);

      if (trimmed.startsWith('•')) {
        return Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaColors.primaryLight, height: 1.6)),
            Expanded(
              child: Text(trimmed.substring(1).trim(), style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text, height: 1.6)),
            ),
          ]),
        );
      }

      if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(trimmed, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text, height: 1.6)),
        );
      }

      if (trimmed == trimmed.toUpperCase() && trimmed.length > 3) {
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Row(children: [
            Container(width: 3, height: 16, decoration: BoxDecoration(color: HezaColors.primaryLight, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(trimmed, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: t.primary, letterSpacing: 0.5)),
          ]),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(trimmed, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text, height: 1.6)),
      );
    }).toList();
  }
}

// ── Lesson app bar with gradient header ──────────────────────────────────────
class _LessonAppBar extends StatelessWidget {
  final dynamic lesson;
  final Color levelColor;
  final HezaTheme t;
  const _LessonAppBar({required this.lesson, required this.levelColor, required this.t});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HezaColors.primary, HezaColors.primaryLight.withValues(alpha: 0.85)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // Title + meta
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(HezaRadius.md),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lesson.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: levelColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(HezaRadius.full),
                            ),
                            child: Text(lesson.level, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: levelColor)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.timer_outlined, size: 13, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(lesson.duration, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white70)),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────
class _MarkDoneBar extends StatelessWidget {
  final bool isCompleted;
  final HezaTheme t;
  final VoidCallback onDone;
  const _MarkDoneBar({required this.isCompleted, required this.t, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: t.glassBg.withValues(alpha: t.isDark ? 0.2 : 0.7),
            border: Border(top: BorderSide(color: t.glassBorder, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: isCompleted ? 'Leçon complétée' : 'Marquer comme lu',
                leadingIcon: isCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
                onPressed: isCompleted ? null : onDone,
                color: isCompleted ? t.surface : t.primary,
                textColor: isCompleted ? t.textMuted : Colors.white,
                fullWidth: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
