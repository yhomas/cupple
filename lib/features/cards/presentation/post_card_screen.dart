





















import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/max_width_container.dart';
import '../../../../core/theme/app_colors.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.coupleId == null) return;
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
          );
      if (mounted) context.go('/');
    } catch (e) {
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
      body: MaxWidthContainer(
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
                const SizedBox(height: 24),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
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
      ),
    );
  }
}

























