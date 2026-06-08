

























import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/max_width_container.dart';
import '../../../../core/theme/app_colors.dart';
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
      appBar: AppBar(title: const Text('レポート')),
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


























