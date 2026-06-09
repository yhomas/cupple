


























import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/max_width_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../cards/domain/card_model.dart';
import '../../cards/presentation/card_controller.dart';
import '../../auth/presentation/auth_controller.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    if (user == null || user.coupleId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('レポート')),
        body: MaxWidthContainer(
          child: Center(
            child: Text('パートナーと連携してください', style: theme.textTheme.titleMedium),
          ),
        ),
      );
    }

    final cardsAsync = ref.watch(timelineCardsProvider(user.coupleId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('レポート'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'テーマ切替',
            onPressed: () => ref.read(themeModeControllerProvider.notifier).toggle(),
          ),
        ],
      ),
      body: MaxWidthContainer(
        child: cardsAsync.when(
          data: (cards) {
            final thankYouCount = cards.where((c) => c.type == CardType.thankYou).length;
            final didItCount = cards.where((c) => c.type == CardType.didIt).length;
            final acknowledgedCount = cards.where((c) => c.isAcknowledged).length;

            final categoryStats = <CardCategory, int>{};
            for (final cat in CardCategory.values) {
              categoryStats[cat] = cards.where((c) => c.category == cat).length;
            }

            final weeklyData = _calcWeeklyData(cards);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('サマリー', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite,
                          label: 'ありがとう',
                          value: thankYouCount.toString(),
                          color: AppColors.pastelPink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star,
                          label: 'やったよ',
                          value: didItCount.toString(),
                          color: AppColors.warmOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    icon: Icons.emoji_emotions,
                    label: '承認された数',
                    value: acknowledgedCount.toString(),
                    color: AppColors.mintGreen,
                  ),
                  const SizedBox(height: 24),
                  Text('過去7日間', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _WeeklyChart(data: weeklyData),
                  const SizedBox(height: 24),
                  Text('カテゴリー別', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...CardCategory.values.map((cat) {
                    final count = categoryStats[cat] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CategoryBar(
                        label: CardModel.categoryLabel(cat),
                        count: count,
                        total: cards.isEmpty ? 1 : cards.length,
                      ),
                    );
                  }),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
        ),
      ),
    );
  }

  List<_DayData> _calcWeeklyData(List<CardModel> cards) {
    final now = DateTime.now();
    final List<_DayData> result = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final dayCards = cards.where((c) =>
          c.createdAt.isAfter(dayStart) && c.createdAt.isBefore(dayEnd)).toList();
      result.add(_DayData(
        date: date,
        thankYou: dayCards.where((c) => c.type == CardType.thankYou).length,
        didIt: dayCards.where((c) => c.type == CardType.didIt).length,
      ));
    }
    return result;
  }
}

class _DayData {
  final DateTime date;
  final int thankYou;
  final int didIt;
  _DayData({required this.date, required this.thankYou, required this.didIt});
}

class _WeeklyChart extends StatelessWidget {
  final List<_DayData> data;
  const _WeeklyChart({required this.data});

  static const _weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = data.map((d) => d.thankYou + d.didIt).fold(0, (a, b) => a > b ? a : b);
    final scale = maxVal == 0 ? 1.0 : maxVal.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final total = d.thankYou + d.didIt;
                final thankRatio = d.thankYou / scale;
                final didRatio = d.didIt / scale;
                final weekday = _weekdayLabels[d.date.weekday - 1];
                return Column(
                  children: [
                    Text('$total', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 32,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (d.thankYou > 0)
                            Container(
                              width: 24,
                              height: (thankRatio * 60).clamp(4, 60),
                              decoration: BoxDecoration(
                                color: AppColors.pastelPink,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          if (d.didIt > 0)
                            Container(
                              width: 24,
                              height: (didRatio * 60).clamp(4, 60),
                              decoration: BoxDecoration(
                                color: AppColors.warmOrange,
                                borderRadius: BorderRadius.vertical(
                                  bottom: const Radius.circular(4),
                                  top: d.thankYou > 0 ? Radius.zero : const Radius.circular(4),
                                ),
                              ),
                            ),
                          if (total == 0)
                            Container(
                              width: 24,
                              height: 4,
                              color: AppColors.mediumGray,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(weekday, style: theme.textTheme.labelSmall),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.pastelPink, label: 'ありがとう'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.warmOrange, label: 'やったよ'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;

  const _CategoryBar({
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text('$count', style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.lightGray,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mintGreen),
          ),
        ),
      ],
    );
  }
}


























