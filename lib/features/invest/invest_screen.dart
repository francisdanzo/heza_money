import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/lesson.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

/// Écran Investir — leçons financières + simulateur
class InvestScreen extends ConsumerStatefulWidget {
  const InvestScreen({super.key});

  @override
  ConsumerState<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends ConsumerState<InvestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('École Financière'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: AppTextStyles.titleSmall,
          tabs: const [
            Tab(text: 'Leçons'),
            Tab(text: 'Simulateur'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LessonsTab(),
          _SimulatorTab(),
        ],
      ),
    );
  }
}

/// Onglet liste des leçons
class _LessonsTab extends ConsumerWidget {
  const _LessonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(lessonProgressProvider);
    final scoreAsync = ref.watch(financialScoreProvider);

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (progressList) {
        final completedIds = progressList
            .where((p) => p.completed)
            .map((p) => p.lessonId)
            .toSet();
        final completedCount = completedIds.length;
        final total = LessonsData.all.length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Score XP global
            _buildXpCard(completedCount, total, scoreAsync.value ?? 0),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Toutes les leçons'),
            const SizedBox(height: 12),

            ...LessonsData.all.map((lesson) {
              final done = completedIds.contains(lesson.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LessonCard(lesson: lesson, completed: done),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildXpCard(int completed, int total, int score) {
    final ratio = total > 0 ? completed / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score financier',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score / 100',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🎓', style: TextStyle(fontSize: 28)),
            ),
          ]),
          const SizedBox(height: 12),
          HezaProgressBar(
            value: ratio,
            color: AppColors.accent,
            height: 8,
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 6),
          Text(
            '$completed / $total leçons complétées',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// Card d'une leçon
class _LessonCard extends ConsumerWidget {
  final Lesson lesson;
  final bool completed;
  const _LessonCard({required this.lesson, required this.completed});

  Color get _levelColor {
    switch (lesson.level) {
      case 'Intermédiaire': return AppColors.levelIntermediaire;
      case 'Avancé': return AppColors.levelAvance;
      default: return AppColors.levelDebutant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HezaCard(
      onTap: () => context.push('/invest/lesson/${lesson.id}'),
      child: Row(
        children: [
          // Emoji + état
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.action.withValues(alpha: 0.1)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(lesson.emoji,
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
              if (completed)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.action,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Row(children: [
                  HezaBadge(
                    label: lesson.level,
                    backgroundColor: _levelColor.withValues(alpha: 0.1),
                    textColor: _levelColor,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.timer_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(lesson.duration, style: AppTextStyles.bodySmall),
                ]),
              ],
            ),
          ),
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.arrow_forward_ios_rounded,
            size: completed ? 22 : 16,
            color: completed ? AppColors.action : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Onglet simulateur d'investissement
class _SimulatorTab extends StatefulWidget {
  const _SimulatorTab();

  @override
  State<_SimulatorTab> createState() => _SimulatorTabState();
}

class _SimulatorTabState extends State<_SimulatorTab> {
  double _initialAmount = 100000;
  double _monthlyContrib = 20000;
  double _annualRate = 8;
  double _years = 10;

  // Calcule la valeur future avec intérêts composés + apports mensuels
  List<FlSpot> _calculateData() {
    final spots = <FlSpot>[];
    final monthlyRate = _annualRate / 100 / 12;
    double total = _initialAmount;

    for (int month = 0; month <= _years * 12; month++) {
      if (month % 12 == 0) {
        spots.add(FlSpot(month / 12, total));
      }
      total = total * (1 + monthlyRate) + _monthlyContrib;
    }
    return spots;
  }

  double get _finalAmount {
    final spots = _calculateData();
    return spots.isNotEmpty ? spots.last.y : 0;
  }

  double get _totalInvested =>
      _initialAmount + _monthlyContrib * _years * 12;

  double get _totalGain => _finalAmount - _totalInvested;

  @override
  Widget build(BuildContext context) {
    final spots = _calculateData();
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Résultat final
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valeur finale estimée',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                AppFormatters.formatAmount(_finalAmount, currency: 'BIF'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                _ResultChip(
                  label: 'Investi',
                  value: AppFormatters.formatNumber(_totalInvested),
                  color: Colors.white60,
                ),
                const SizedBox(width: 12),
                _ResultChip(
                  label: 'Gains',
                  value: '+${AppFormatters.formatNumber(_totalGain)}',
                  color: AppColors.accent,
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Graphique
        HezaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Croissance sur ${_years.toInt()} ans',
                  style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            'An ${v.toInt()}',
                            style: AppTextStyles.labelSmall,
                          ),
                          interval: _years > 5 ? 5 : 1,
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.action,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.action.withValues(alpha: 0.1),
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    minY: 0,
                    maxY: maxY * 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Sliders
        HezaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Paramètres', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              _SliderRow(
                label: 'Montant initial',
                value: _initialAmount,
                min: 10000,
                max: 5000000,
                divisions: 499,
                display: AppFormatters.formatAmount(_initialAmount,
                    currency: 'BIF'),
                onChanged: (v) => setState(() => _initialAmount = v),
              ),
              const SizedBox(height: 16),
              _SliderRow(
                label: 'Apport mensuel',
                value: _monthlyContrib,
                min: 0,
                max: 500000,
                divisions: 500,
                display: AppFormatters.formatAmount(_monthlyContrib,
                    currency: 'BIF'),
                onChanged: (v) => setState(() => _monthlyContrib = v),
              ),
              const SizedBox(height: 16),
              _SliderRow(
                label: 'Taux annuel',
                value: _annualRate,
                min: 1,
                max: 20,
                divisions: 190,
                display: AppFormatters.formatPercent(_annualRate,
                    decimals: 1),
                onChanged: (v) => setState(() => _annualRate = v),
              ),
              const SizedBox(height: 16),
              _SliderRow(
                label: 'Durée',
                value: _years,
                min: 1,
                max: 30,
                divisions: 29,
                display: AppFormatters.formatDuration(_years.toInt() * 12),
                onChanged: (v) => setState(() => _years = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultChip(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.white60)),
      Text(value,
          style:
              AppTextStyles.titleSmall.copyWith(color: color, fontSize: 14)),
    ]);
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.titleSmall)),
        Text(display,
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.action)),
      ]),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: AppColors.action,
        inactiveColor: AppColors.divider,
        onChanged: onChanged,
      ),
    ]);
  }
}
