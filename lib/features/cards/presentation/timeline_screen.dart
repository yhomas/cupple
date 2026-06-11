

















import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/max_width_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/card_model.dart';
import 'card_controller.dart';
import '../../auth/presentation/auth_controller.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    if (user == null || user.coupleId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('タイムライン'), actions: [IconButton(icon: const Icon(Icons.logout), tooltip: 'ログアウト', onPressed: () async { await ref.read(authControllerProvider.notifier).signOut(); if (context.mounted) context.go('/login'); })]),
        body: MaxWidthContainer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64),
                const SizedBox(height: 16),
                Text('パートナーと連携してください', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/link-partner'),
                  child: const Text('パートナー連携へ'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cardsAsync = ref.watch(timelineCardsProvider(user.coupleId!));

    return Scaffold(
      appBar: AppBar(title: const Text('タイムライン'), actions: [IconButton(icon: const Icon(Icons.logout), tooltip: 'ログアウト', onPressed: () async { await ref.read(authControllerProvider.notifier).signOut(); if (context.mounted) context.go('/login'); })]),
      body: SafeArea(
        child: MaxWidthContainer(
          child: cardsAsync.when(
            data: (cards) {
              if (cards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: AppColors.mediumGray),
                      const SizedBox(height: 16),
                      Text('まだカードがありません', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('最初のカードを投稿しましょう！', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return _CardTile(card: cards[index], myUid: user.uid);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
          ),
        ),
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  final CardModel card;
  final String myUid;
  const _CardTile({required this.card, required this.myUid});

  static const _reactionEmojis = ['❤️', '👍', '🎉', '✨', '🙏'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMine = card.senderId == myUid;

    return Dismissible(
      key: Key(card.cardId),
      direction: (!isMine && !card.isAcknowledged)
          ? DismissDirection.startToEnd
          : DismissDirection.none,
      confirmDismiss: (_) async {
        ref.read(cardControllerProvider.notifier).acknowledgeCard(
              card.cardId,
              '❤️',
            );
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.pastelPinkLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.favorite, color: AppColors.pastelPinkDark),
            SizedBox(width: 8),
            Text('褒める！', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      child: Card(
        color: isMine ? Colors.white : AppColors.softBeige,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isMine ? AppColors.mintGreen : AppColors.pastelPinkLight,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isMine
                        ? AppColors.mintGreen
                        : AppColors.pastelPinkLight,
                    child: Text(
                      (card.senderName?.isNotEmpty == true)
                          ? card.senderName![0].toUpperCase()
                          : (isMine ? '私' : '?'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isMine
                            ? Colors.white
                            : AppColors.pastelPinkDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    card.senderName ?? (isMine ? '私' : 'パートナー'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMine
                          ? AppColors.mintGreen.withValues(alpha: 0.2)
                          : AppColors.pastelPinkLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CardModel.typeLabel(card.type),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isMine
                            ? AppColors.darkText
                            : AppColors.pastelPinkDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CardModel.categoryLabel(card.category),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  const Spacer(),
                  if (card.isAcknowledged)
                    Text(
                      card.acknowledgementEmoji ?? '❤️',
                      style: const TextStyle(fontSize: 20),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.stamp != null) ...[
                    Text(card.stamp!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: Text(card.content, style: theme.textTheme.bodyLarge)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(card.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
              if (!isMine && !card.isAcknowledged) ...[
                const SizedBox(height: 12),
                Row(
                  children: _reactionEmojis.map((emoji) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          ref.read(cardControllerProvider.notifier).acknowledgeCard(
                                card.cardId,
                                emoji,
                              );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inDays < 1) return '${diff.inHours}時間前';
    if (diff.inDays < 7) return '${diff.inDays}日前';
    return '${dt.month}/${dt.day}';
  }
}




















