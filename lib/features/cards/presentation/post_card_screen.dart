import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/user_model.dart';
import '../../../../core/widgets/max_width_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/debug/debug_log.dart';
import '../domain/card_model.dart';
import 'card_controller.dart';
import '../../auth/presentation/auth_controller.dart';

class PostCardScreen extends ConsumerStatefulWidget {
  const PostCardScreen({super.key});

  @override
  ConsumerState<PostCardScreen> createState() => _PostCardScreenState();
}

class _PostCardScreenState extends ConsumerState<PostCardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _contentController = TextEditingController();
  CardCategory _selectedCategory = CardCategory.housework;
  String? _selectedStamp;
  bool _isLoading = false;

  static const _thankYouStamps = ['💐', '🍰', '☕', '🎁', '🌸'];
  static const _didItStamps = ['💪', '🏆', '✅', '🔥', '⭐'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedStamp = null);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit(UserModel user) async {
    dlog("_submit: START, coupleId=${user.coupleId}");
    if (user.coupleId == null) {
      dlog("_submit: coupleId is null");
      return;
    }
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final type = _tabController.index == 0 ? CardType.thankYou : CardType.didIt;
      await ref.read(cardControllerProvider.notifier).createCard(
            coupleId: user.coupleId!,
            senderId: user.uid,
            type: type,
            category: _selectedCategory,
            content: _contentController.text.trim(),
            stamp: _selectedStamp,
          );
      dlog("_submit: createCard DONE");
      if (mounted) context.go('/');
    } catch (e, st) {
      dlog("_submit: ERROR: $e");
      dlog("_submit: STACK: $st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stamps = _tabController.index == 0 ? _thankYouStamps : _didItStamps;
    final asyncUser = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('カードを投稿'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'ありがとう'),
            Tab(icon: Icon(Icons.star), text: 'やったよ'),
          ],
        ),
      ),
      body: asyncUser.when(
        data: (user) {
          if (user == null || user.coupleId == null) {
            return const Center(child: Text('ユーザー情報を取得できません'));
          }
          return MaxWidthContainer(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: _tabController.index == 0
                            ? '感謝の内容を書く'
                            : 'やったことを書く',
                        hintText: '例: 今日の夕飯を作りました！',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    Text('カテゴリー', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: CardCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(CardModel.categoryLabel(cat)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppColors.mintGreen.withValues(alpha: 0.5),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('スタンプ', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: stamps.map((stamp) {
                        final isSelected = _selectedStamp == stamp;
                        return InkWell(
                          onTap: () => setState(() => _selectedStamp = isSelected ? null : stamp),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.pastelPinkLight
                                  : AppColors.lightGray,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: AppColors.pastelPink, width: 2)
                                  : null,
                            ),
                            child: Text(stamp, style: const TextStyle(fontSize: 28)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _submit(user),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('投稿する'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }
}
