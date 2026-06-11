

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/couple/presentation/link_partner_screen.dart';
import '../../features/cards/presentation/timeline_screen.dart';
import '../../features/cards/presentation/post_card_screen.dart';
import '../../features/report/presentation/report_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => null,
        error: (_, _) => false,
      );
      final isAuthRoute = state.matchedLocation == '/login';

      // ローディング中は現在の画面を維持
      if (isLoggedIn == null) return null;

      // 未ログイン: ログイン画面以外はログインへリダイレクト（元のページをクエリに保持）
      if (!isLoggedIn && !isAuthRoute) {
        return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
      }

      // ログイン済み: ログイン画面は元のページ（またはタイムライン）へリダイレクト
      if (isLoggedIn && isAuthRoute) {
        final redirectTo = state.uri.queryParameters['redirect'];
        return redirectTo ?? '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/link-partner',
        builder: (context, state) => const LinkPartnerScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/post',
                builder: (context, state) => const PostCardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/report',
                builder: (context, state) => const ReportScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: '投稿',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'レポート',
          ),
        ],
      ),
    );
  }
}

