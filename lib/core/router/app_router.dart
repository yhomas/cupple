

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
        path: '/',
        builder: (context, state) => const TimelineScreen(),
      ),
      GoRoute(
        path: '/link-partner',
        builder: (context, state) => const LinkPartnerScreen(),
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) => const PostCardScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const ReportScreen(),
      ),
    ],
  );
});

