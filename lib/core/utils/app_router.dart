import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/features/auth/presetation/views/auth_view.dart';
import 'package:physio_app/features/auth/presetation/views/login_view.dart';
import 'package:physio_app/features/auth/presetation/views/register_view.dart';
import 'package:physio_app/features/body_part_selector/presentation/views/body_part_selector_view.dart';
import 'package:physio_app/features/home/presentation/views/home_view.dart';
import 'package:physio_app/features/home/presentation/views/page_view.dart';
import 'package:physio_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:physio_app/features/splash/presentation/views/splash_view.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String bodyPartSelector = '/body-part-selector';
  static const String pageView = '/page-view';
  static final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: splash,
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SplashView(),
        ),
      ),
      GoRoute(
        path: onboarding,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: const OnboardingView(),
        ),
      ),
      GoRoute(
        path: auth,
        pageBuilder: (context, state) => buildPageWithSlideUpTransition(
          context: context,
          state: state,
          child: AuthView(),
        ),
      ),
      GoRoute(
        path: login,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: LoginView(),
        ),
      ),
      GoRoute(
        path: register,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: RegisterView(),
        ),
      ),
      GoRoute(
        path: bodyPartSelector,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: BodyPartSelectorView(),
        ),
      ),
      GoRoute(
        path: home,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: HomeView(),
        ),
      ),
      GoRoute(
        path: pageView,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: SelectorPageView(),
        ),
      ),
    ],
  );
}

CustomTransitionPage buildPageWithFadeTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage buildPageWithSlideLeftTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );
}

CustomTransitionPage buildPageWithSlideUpTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );
}
