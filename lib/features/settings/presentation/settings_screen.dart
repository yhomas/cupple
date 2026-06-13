import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/max_width_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/debug/debug_log.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../couple/data/couple_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: MaxWidthContainer(
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('プロフィール', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        key: ValueKey(user.photoUrl),
                        radius: 24,
                        backgroundColor: AppColors.pastelPinkLight,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0]
                                    : '?',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            : null,
                      ),
                      title: const Text('アイコン画像'),
                      subtitle: Text(
                          user.photoUrl != null ? '画像を変更' : '画像を設定'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _pickAndUploadAvatar(context, ref, user),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('表示名'),
                      subtitle: Text(user.displayName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _showDisplayNameDialog(context, ref, user),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('パートナー', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _PartnerInfoCard(user: user),
                  const SizedBox(height: 24),
                  Text('アカウント', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const _AccountSection(),
                ],
              ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(
      BuildContext context, WidgetRef ref, UserModel user) async {
    dlog("_pickAndUploadAvatar: START");
    try {
      final picker = ImagePicker();
      dlog("_pickAndUploadAvatar: calling pickImage...");
      final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      dlog("_pickAndUploadAvatar: xFile=$xFile");
      if (xFile == null) {
        dlog("_pickAndUploadAvatar: xFile is null, returning");
        return;
      }

      dlog("_pickAndUploadAvatar: reading bytes...");
      final bytes = await xFile.readAsBytes();
      dlog("_pickAndUploadAvatar: bytes.length=${bytes.length}");
      if (!context.mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      dlog("_pickAndUploadAvatar: calling updateAvatar...");
      await ref
          .read(authControllerProvider.notifier)
          .updateAvatar(user.uid, bytes);
      dlog("_pickAndUploadAvatar: updateAvatar DONE");

      // Dismiss loading dialog FIRST - always try regardless of mounted state
      dlog("_pickAndUploadAvatar: dismissing loading dialog");
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          dlog("_pickAndUploadAvatar: dialog dismissed successfully");
        } catch (navErr) {
          dlog("_pickAndUploadAvatar: nav pop error (ignored): $navErr");
        }
      }

      // State is already updated by authController, no invalidate needed
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アイコン画像を更新しました')),
        );
      }
    } catch (e, st) {
      dlog("_pickAndUploadAvatar: ERROR: $e");
      dlog("_pickAndUploadAvatar: STACK: $st");
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  void _showDisplayNameDialog(
      BuildContext context, WidgetRef ref, UserModel user) {
    final controller = TextEditingController(text: user.displayName);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('表示名を変更'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '新しい表示名',
              prefixIcon: Icon(Icons.person_outline),
            ),
            autofocus: true,
            enabled: !isLoading,
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;
                      setDialogState(() => isLoading = true);
                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .updateDisplayName(user.uid, name);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('表示名を変更しました')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('エラー: $e')),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerInfoCard extends ConsumerWidget {
  final UserModel user;
  const _PartnerInfoCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (user.coupleId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'パートナーと連携していません',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return FutureBuilder<UserModel?>(
      future: ref
          .read(coupleRepositoryProvider)
          .getPartner(user.coupleId!, user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('エラー: ${snapshot.error}'),
            ),
          );
        }
        final partner = snapshot.data;
        if (partner == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'パートナー情報を取得できません',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.pastelPinkLight,
              backgroundImage: partner.photoUrl != null
                  ? NetworkImage(partner.photoUrl!)
                  : null,
              child: partner.photoUrl == null
                  ? Text(
                      partner.displayName.isNotEmpty
                          ? partner.displayName[0]
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(partner.displayName),
            subtitle: const Text('パートナー'),
          ),
        );
      },
    );
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(authRepositoryProvider);
    final isEmailUser = repo.isEmailUser;

    return Column(
      children: [
        if (isEmailUser)
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('パスワード変更'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPasswordDialog(context, ref),
            ),
          ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ログアウト', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }

  void _showPasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('パスワード変更'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPwController,
                  decoration: const InputDecoration(
                    labelText: '現在のパスワード',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPwController,
                  decoration: const InputDecoration(
                    labelText: '新しいパスワード',
                    prefixIcon: Icon(Icons.lock),
                    helperText: '6文字以上',
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPwController,
                  decoration: const InputDecoration(
                    labelText: '新しいパスワード（確認）',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final currentPw = currentPwController.text;
                      final newPw = newPwController.text;
                      final confirmPw = confirmPwController.text;

                      if (currentPw.isEmpty ||
                          newPw.isEmpty ||
                          confirmPw.isEmpty) {
                        setDialogState(() =>
                            errorMessage = 'すべての項目を入力してください');
                        return;
                      }
                      if (newPw.length < 6) {
                        setDialogState(
                            () => errorMessage = 'パスワードは6文字以上です');
                        return;
                      }
                      if (newPw != confirmPw) {
                        setDialogState(
                            () => errorMessage = '新しいパスワードが一致しません');
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .updatePassword(currentPw, newPw);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('パスワードを変更しました')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isLoading = false;
                          errorMessage = e.toString();
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('変更'),
            ),
          ],
        ),
      ),
    );
  }
}
