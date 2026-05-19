import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_components.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

class BadgeDef {
  final String   id;
  final IconData icon;
  final String   title;
  final String   description;
  final Color    color;
  const BadgeDef({required this.id, required this.icon, required this.title, required this.description, required this.color});
}

const List<BadgeDef> allBadges = [
  BadgeDef(
    id: 'first_step',
    icon: Icons.emoji_events_rounded,
    title: 'Premier pas',
    description: 'Tu as enregistré ta première transaction.',
    color: HezaColors.warning,
  ),
  BadgeDef(
    id: 'ten_transactions',
    icon: Icons.receipt_long_rounded,
    title: 'Gestionnaire assidu',
    description: '10 transactions enregistrées. Tu prends le contrôle !',
    color: Color(0xFF00BCD4),
  ),
  BadgeDef(
    id: 'first_income',
    icon: Icons.attach_money_rounded,
    title: 'Premier revenu',
    description: 'Tu as enregistré ton premier revenu.',
    color: HezaColors.success,
  ),
  BadgeDef(
    id: 'saver',
    icon: Icons.savings_rounded,
    title: 'Épargnant régulier',
    description: 'Tu as épargné 3 mois de suite. Quelle discipline !',
    color: HezaColors.primaryLight,
  ),
  BadgeDef(
    id: 'learner',
    icon: Icons.school_rounded,
    title: 'Apprenti investisseur',
    description: 'Tu as complété 3 leçons financières.',
    color: HezaColors.primary,
  ),
  BadgeDef(
    id: 'all_lessons',
    icon: Icons.auto_stories_rounded,
    title: 'Maître financier',
    description: 'Toutes les 6 leçons complétées. Tu es prêt !',
    color: Color(0xFF673AB7),
  ),
  BadgeDef(
    id: 'goal_halfway',
    icon: Icons.trending_up_rounded,
    title: 'À mi-chemin',
    description: 'Un objectif atteint à 50%. Continue comme ça !',
    color: Color(0xFFFF7043),
  ),
  BadgeDef(
    id: 'independence',
    icon: Icons.flag_rounded,
    title: 'Objectif atteint',
    description: 'Tu as atteint un premier objectif d\'épargne !',
    color: Color(0xFF9C27B0),
  ),
  BadgeDef(
    id: 'three_goals',
    icon: Icons.military_tech_rounded,
    title: 'Champion de l\'épargne',
    description: '3 objectifs accomplis. Tu es une référence !',
    color: HezaColors.warning,
  ),
];

/// Affiche une popup d'animation quand un badge est débloqué.
void showBadgeUnlocked(BuildContext context, String badgeId) {
  final badge = allBadges.where((b) => b.id == badgeId).firstOrNull;
  if (badge == null) return;
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => _BadgeUnlockedDialog(badge: badge),
  );
}

class _BadgeUnlockedDialog extends StatefulWidget {
  final BadgeDef badge;
  const _BadgeUnlockedDialog({required this.badge});

  @override
  State<_BadgeUnlockedDialog> createState() => _BadgeUnlockedDialogState();
}

class _BadgeUnlockedDialogState extends State<_BadgeUnlockedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale   = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    return FadeTransition(
      opacity: _opacity,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: HezaTheme.of(context).surface,
              borderRadius: BorderRadius.circular(HezaRadius.xl),
              border: Border.all(color: badge.color.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [BoxShadow(color: badge.color.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 2)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: badge.color.withValues(alpha: 0.4), width: 2),
                ),
                child: Icon(badge.icon, color: badge.color, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Badge débloqué !',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: badge.color),
              ),
              const SizedBox(height: 6),
              Text(
                badge.title,
                style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: HezaTheme.of(context).text),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: HezaTheme.of(context).textSub),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: badge.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HezaRadius.md)),
                  ),
                  child: const Text('Super !', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t           = HezaTheme.of(context);
    final badgesAsync = ref.watch(earnedBadgesProvider);
    final scoreAsync  = ref.watch(financialScoreProvider);

    return Scaffold(
      appBar: GlassAppBar(title: 'Mes badges'),
      body: badgesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: t.primary)),
        error:   (e, _) => Center(child: Text('$e')),
        data: (earned) {
          final earnedIds = earned.map((b) => b.badgeId).toSet();
          final score     = scoreAsync.value ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              _ScoreCard(score: score, t: t),
              const SizedBox(height: 24),

              SectionHeader(title: 'Badges (${earnedIds.length}/${allBadges.length})'),
              const SizedBox(height: 12),

              ...allBadges.map((badge) {
                final isEarned    = earnedIds.contains(badge.id);
                final earnedBadge = earned.where((b) => b.badgeId == badge.id).firstOrNull;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BadgeCard(badge: badge, earned: isEarned, earnedAt: earnedBadge?.earnedAt, t: t),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// ── Score card ────────────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final int score;
  final HezaTheme t;
  const _ScoreCard({required this.score, required this.t});

  @override
  Widget build(BuildContext context) {
    final level      = score >= 80 ? 'Expert' : score >= 50 ? 'Intermédiaire' : 'Débutant';
    final levelColor = score >= 80 ? const Color(0xFF9C27B0) : score >= 50 ? HezaColors.warning : HezaColors.primaryLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(HezaRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HezaColors.primary, HezaColors.primaryLight.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(HezaRadius.lg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
            boxShadow: [BoxShadow(color: HezaColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Score financier Heza', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('$score / 100', style: const TextStyle(fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
              Column(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(HezaRadius.md),
                  ),
                  child: const Icon(Icons.star_rounded, color: HezaColors.warning, size: 28),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(HezaRadius.full),
                  ),
                  child: Text(level, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: levelColor)),
                ),
              ]),
            ]),
            const SizedBox(height: 16),
            HezaProgressBar(value: score / 100, color: HezaColors.accent, height: 10, backgroundColor: Colors.white24),
            const SizedBox(height: 12),
            Row(children: [
              _ScorePill('Épargne régulière', '40 pts', score >= 40),
              const SizedBox(width: 8),
              _ScorePill('Leçons',    '30 pts', score >= 30),
              const SizedBox(width: 8),
              _ScorePill('Objectifs', '30 pts', score >= 70),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final String pts;
  final bool   active;
  const _ScorePill(this.label, this.pts, this.active);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? HezaColors.accent.withValues(alpha: 0.2) : Colors.white12,
          borderRadius: BorderRadius.circular(HezaRadius.sm),
        ),
        child: Column(children: [
          Text(pts, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: active ? HezaColors.accent : Colors.white38)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: Colors.white54), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Badge card ────────────────────────────────────────────────────────────────
class _BadgeCard extends StatelessWidget {
  final BadgeDef  badge;
  final bool      earned;
  final DateTime? earnedAt;
  final HezaTheme t;
  const _BadgeCard({required this.badge, required this.earned, required this.t, this.earnedAt});

  @override
  Widget build(BuildContext context) {
    final iconColor   = earned ? badge.color : t.textMuted;
    final bgColor     = earned ? badge.color.withValues(alpha: 0.12) : t.border.withValues(alpha: 0.3);

    return HezaCard(
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(HezaRadius.md),
            border: earned ? Border.all(color: badge.color.withValues(alpha: 0.3), width: 1) : null,
            boxShadow: earned ? [BoxShadow(color: badge.color.withValues(alpha: 0.2), blurRadius: 8)] : null,
          ),
          child: earned
              ? Icon(badge.icon, color: iconColor, size: 28)
              : Icon(Icons.lock_rounded, color: t.textMuted.withValues(alpha: 0.5), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                badge.title,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: earned ? t.text : t.textSub),
              ),
              if (earned) ...[
                const SizedBox(width: 8),
                HezaBadge(
                  label: 'Gagné',
                  backgroundColor: badge.color.withValues(alpha: 0.12),
                  textColor: badge.color,
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Text(
              earned ? badge.description : 'Badge non encore débloqué',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: earned ? t.textSub : t.textMuted),
            ),
            if (earnedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Le ${AppFormatters.formatDateMedium(earnedAt!)}',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: badge.color),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}
