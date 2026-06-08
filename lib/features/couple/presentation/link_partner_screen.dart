

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/max_width_container.dart';
import 'couple_controller.dart';
import '../../auth/presentation/auth_controller.dart';

class LinkPartnerScreen extends ConsumerStatefulWidget {
  const LinkPartnerScreen({super.key});

  @override
  ConsumerState<LinkPartnerScreen> createState() => _LinkPartnerScreenState();
}

class _LinkPartnerScreenState extends ConsumerState<LinkPartnerScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _generatedCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createCouple() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final couple = await ref.read(coupleControllerProvider.notifier).createCouple(user.uid);
      if (mounted) {
        setState(() => _generatedCode = couple.inviteCode);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinCouple() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final couple = await ref.read(coupleControllerProvider.notifier).joinCouple(
            _codeController.text.trim(),
            user.uid,
          );
      if (couple == null && mounted) {
        setState(() => _errorMessage = '招待コードが無効です');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('パートナー連携')),
      body: MaxWidthContainer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.people_alt_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  'パートナーと連携しましょう',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '招待コードを共有してパートナーとつなぎます',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                if (_generatedCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('招待コード', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SelectableText(
                          _generatedCode!,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'このコードをパートナーに共有してください',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createCouple,
                  icon: const Icon(Icons.add),
                  label: const Text('招待コードを生成'),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'パートナーの招待コードがある場合',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '招待コード',
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _joinCouple,
                  icon: const Icon(Icons.login),
                  label: const Text('パートナーに参加'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


