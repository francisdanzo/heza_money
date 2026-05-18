import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

/// Définition d'un badge
class BadgeDef {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const BadgeDef({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Liste de tous les badges disponibles dans l'app
const List<BadgeDef> allBadges = [
  BadgeDef(
    id: 'first_step',
    emoji: '🥇',
    title: 'Premier pas',
    description: 'Tu as enregistré ta première transaction. Bravo !',
    color: AppColors.alert,
  ),
  BadgeDef(
    id: 'saver',
    emoji: '💰',
    title: 'Épargnant',
    description: 'Tu as épargné 3 mois de suite. Quelle discipline !',
    color: AppColors.action,
  ),
  BadgeDef(
    id: 'learner',
    emoji: '📚',
    title: 'Apprenti investisseur',
    description: 'Tu as complété 3 leçons financières. Continue !',
    color: AppColors.primary,
  ),
  BadgeDef(
    id: 'independence',
    emoji: '🏠',
    title: 'Prêt pour l\'indépendance',
    description: 'Tu as atteint un objectif d\'épargne. Félicitations !',
    color: Color(0xFF9C27B0),
  ),
];

/// Écran des badges et gamification
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(earnedBadgesProvider);
    final scoreAsync = ref.watch(financialScoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes badges')),
      body: badgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (earned) {
          final earnedIds = earned.map((b) => b.badgeId).toSet();
          final score = scoreAsync.value ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // Score financier
              _buildScoreCard(score),
              const SizedBox(height: 24),

              SectionHeader(title: 'Badges (${earnedIds.length}/${allBadges.length})'),
              const SizedBox(height: 12),

              ...allBadges.map((badge) {
                final isEarned = earnedIds.contains(badge.id);
                final earnedBadge = earned
                    .where((b) => b.badgeId == badge.id)
                    .firstOrNull;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BadgeCard(
                    badge: badge,
                    earned: isEarned,
                    earnedAt: earnedBadge?.earnedAt,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    final level = score >= 80
        ? 'Expert'
        : score >= 50
            ? 'Intermédiaire'
            : 'Débutant';
    final levelColor = score >= 80
        ? const Color(0xFF9C27B0)
        : score >= 50
            ? AppColors.alert
            : AppColors.action;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Score financier Heza',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('$score / 100',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            Column(children: [
              const Text('⭐', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 4),
              HezaBadge(
                label: level,
                backgroundColor: levelColor.withValues(alpha: 0.25),
                textColor: levelColor == AppColors.alert
                    ? AppColors.alert
                    : Colors.white,
              ),
            ]),
          ]),
          const SizedBox(height: 16),
          HezaProgressBar(
            value: score / 100,
            color: AppColors.accent,
            height: 10,
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 10),
          Row(children: [
            _ScorePill('Épargne régulière', '40 pts', score >= 40),
            const SizedBox(width: 8),
            _ScorePill('Leçons', '30 pts', score >= 30),
            const SizedBox(width: 8),
            _ScorePill('Objectifs', '30 pts', score >= 70),
          ]),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final String pts;
  final bool active;
  const _ScorePill(this.label, this.pts, this.active);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Text(pts,
              style: AppTextStyles.labelSmall.copyWith(
                color: active ? AppColors.accent : Colors.white38,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              )),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white54,
                fontSize: 9,
              ),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeDef badge;
  final bool earned;
  final DateTime? earnedAt;
  const _BadgeCard(
      {required this.badge, required this.earned, this.earnedAt});

  @override
  Widget build(BuildContext context) {
    return HezaCard(
      child: Row(children: [
        // Emoji badge
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: earned
                ? badge.color.withValues(alpha: 0.15)
                : AppColors.divider.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              earned ? badge.emoji : '🔒',
              style: TextStyle(
                  fontSize: 28,
                  color: earned ? null : Colors.grey.withValues(alpha: 0.4)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  badge.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: earned
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (earned) ...[
                  const SizedBox(width: 8),
                  HezaBadge(
                    label: 'Gagné',
                    backgroundColor: badge.color.withValues(alpha: 0.1),
                    textColor: badge.color,
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text(
                earned
                    ? badge.description
                    : 'Badge non encore débloqué',
                style: AppTextStyles.bodySmall.copyWith(
                  color: earned
                      ? AppColors.textSecondary
                      : AppColors.textDisabled,
                ),
              ),
              if (earnedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Le ${AppFormatters.formatDateMedium(earnedAt!)}',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: badge.color),
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}
