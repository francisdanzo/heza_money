import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/models/lesson.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

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
      appBar: GlassAppBar(
        title: 'École Financière',
        actions: [
          _GlassTabBar(controller: _tabController),
          const SizedBox(width: 8),
        ],
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

// ─── TAB BAR GLASSMORPHIQUE ───────────────────────────────────────────────────
class _GlassTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  const _GlassTabBar({required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicator: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(HezaRadius.sm),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.symmetric(vertical: 2),
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
      tabs: const [Tab(text: 'Leçons'), Tab(text: 'Simulateur')],
    );
  }
}

// ─── ONGLET LEÇONS ───────────────────────────────────────────────────────────
class _LessonsTab extends ConsumerWidget {
  const _LessonsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(lessonProgressProvider);
    final scoreAsync    = ref.watch(financialScoreProvider);
    final t = HezaTheme.of(context);

    return progressAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: t.primary)),
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
            _XpCard(completed: completedCount, total: total, score: scoreAsync.value ?? 0),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Toutes les leçons'),
            const SizedBox(height: 12),
            ...LessonsData.all.map((lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LessonCard(lesson: lesson, completed: completedIds.contains(lesson.id)),
            )),
          ],
        );
      },
    );
  }
}

class _XpCard extends StatelessWidget {
  final int completed, total, score;
  const _XpCard({required this.completed, required this.total, required this.score});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratio  = total > 0 ? completed / total : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(HezaRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [HezaColors.darkSurface, const Color(0xFF1E3A2B)]
                : [HezaColors.primary, HezaColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Score financier', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                  const SizedBox(height: 4),
                  Text('$score / 100', style: const TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
                ]),
              ),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(HezaRadius.md),
                ),
                child: const Icon(Icons.school_rounded, size: 30, color: Colors.white),
              ),
            ]),
            const SizedBox(height: 16),
            HezaProgressBar(value: ratio, color: HezaColors.accentSoft, height: 8, backgroundColor: Colors.white24),
            const SizedBox(height: 8),
            Text('$completed / $total leçons complétées', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final Lesson lesson;
  final bool completed;
  const _LessonCard({required this.lesson, required this.completed});

  Color _levelColor() {
    switch (lesson.level) {
      case 'Intermédiaire': return HezaColors.warning;
      case 'Avancé':        return Color(0xFF9C27B0);
      default:              return HezaColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = HezaTheme.of(context);
    final lvlColor = _levelColor();

    return HezaCard(
      onTap: () => context.push('/invest/lesson/${lesson.id}'),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: completed
                  ? HezaColors.success.withValues(alpha: 0.12)
                  : t.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(HezaRadius.md),
            ),
            child: Icon(
              completed ? Icons.menu_book_rounded : Icons.book_outlined,
              color: completed ? HezaColors.success : t.primary,
              size: 24,
            ),
          ),
          if (completed)
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(color: HezaColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
              ),
            ),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lesson.title, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: t.text)),
            const SizedBox(height: 4),
            Row(children: [
              HezaBadge(label: lesson.level, backgroundColor: lvlColor.withValues(alpha: 0.12), textColor: lvlColor),
              const SizedBox(width: 8),
              Icon(Icons.timer_outlined, size: 12, color: t.textMuted),
              const SizedBox(width: 3),
              Text(lesson.duration, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub)),
            ]),
          ]),
        ),
        Icon(
          completed ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
          size: completed ? 22 : 16,
          color: completed ? HezaColors.success : t.textMuted,
        ),
      ]),
    );
  }
}

// ─── ONGLET SIMULATEUR ───────────────────────────────────────────────────────
class _SimulatorTab extends StatefulWidget {
  const _SimulatorTab();

  @override
  State<_SimulatorTab> createState() => _SimulatorTabState();
}

class _SimulatorTabState extends State<_SimulatorTab> {
  double _initialAmount  = 100000;
  double _monthlyContrib = 20000;
  double _annualRate     = 8;
  double _years          = 10;

  List<FlSpot> _calculateData() {
    final spots = <FlSpot>[];
    final monthlyRate = _annualRate / 100 / 12;
    double total = _initialAmount;
    for (int month = 0; month <= _years * 12; month++) {
      if (month % 12 == 0) spots.add(FlSpot(month / 12, total));
      total = total * (1 + monthlyRate) + _monthlyContrib;
    }
    return spots;
  }

  double get _finalAmount  => _calculateData().lastOrNull?.y ?? 0;
  double get _totalInvested => _initialAmount + _monthlyContrib * _years * 12;
  double get _totalGain    => _finalAmount - _totalInvested;

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final spots = _calculateData();
    final maxY  = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Résultat final
        ClipRRect(
          borderRadius: BorderRadius.circular(HezaRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [HezaColors.darkSurface, const Color(0xFF1E3A2B)]
                    : [HezaColors.primary, HezaColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Valeur finale estimée', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.formatAmount(_finalAmount, currency: 'BIF'),
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  _ResultChip(label: 'Investi', value: AppFormatters.formatNumber(_totalInvested), color: Colors.white60),
                  const SizedBox(width: 20),
                  _ResultChip(label: 'Gains', value: '+${AppFormatters.formatNumber(_totalGain)}', color: HezaColors.accentSoft),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Graphique
        HezaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Croissance sur ${_years.toInt()} ans', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: t.text)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: LineChart(LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(color: t.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text('An ${v.toInt()}', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: t.textMuted)),
                        interval: _years > 5 ? 5 : 1,
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: t.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: t.primary.withValues(alpha: 0.1),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY * 1.1,
                )),
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
              Text('Paramètres', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: t.text)),
              const SizedBox(height: 16),
              _SliderRow(label: 'Montant initial',  value: _initialAmount,  min: 10000, max: 5000000, divisions: 499, display: AppFormatters.formatAmount(_initialAmount, currency: 'BIF'), onChanged: (v) => setState(() => _initialAmount = v)),
              const SizedBox(height: 12),
              _SliderRow(label: 'Apport mensuel',   value: _monthlyContrib, min: 0,     max: 500000,  divisions: 500, display: AppFormatters.formatAmount(_monthlyContrib, currency: 'BIF'), onChanged: (v) => setState(() => _monthlyContrib = v)),
              const SizedBox(height: 12),
              _SliderRow(label: 'Taux annuel',       value: _annualRate,     min: 1,     max: 20,       divisions: 190, display: AppFormatters.formatPercent(_annualRate, decimals: 1), onChanged: (v) => setState(() => _annualRate = v)),
              const SizedBox(height: 12),
              _SliderRow(label: 'Durée',             value: _years,          min: 1,     max: 30,       divisions: 29,  display: AppFormatters.formatDuration(_years.toInt() * 12), onChanged: (v) => setState(() => _years = v)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ResultChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white60)),
      Text(value,  style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ],
  );
}

class _SliderRow extends StatelessWidget {
  final String label, display;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label, required this.value, required this.min,
    required this.max, required this.divisions, required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.text))),
        Text(display, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: t.primary)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: t.primary,
          inactiveTrackColor: t.border,
          thumbColor: t.primary,
          overlayColor: t.primary.withValues(alpha: 0.15),
          trackHeight: 4,
        ),
        child: Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
      ),
    ]);
  }
}
