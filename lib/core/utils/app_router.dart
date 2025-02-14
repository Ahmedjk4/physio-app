import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/features/auth/presetation/views/auth_view.dart';
import 'package:physio_app/features/auth/presetation/views/forgot_password_view.dart';
import 'package:physio_app/features/auth/presetation/views/login_view.dart';
import 'package:physio_app/features/auth/presetation/views/register_view.dart';
import 'package:physio_app/features/body_part_selector/presentation/views/body_part_selector_view.dart';
import 'package:physio_app/features/home/presentation/view_models/cubit/chat_cubit.dart';
import 'package:physio_app/features/home/presentation/views/change_name_view.dart';
import 'package:physio_app/features/home/presentation/views/change_password_view.dart';
import 'package:physio_app/features/home/presentation/views/page_view.dart';
import 'package:physio_app/features/home/presentation/views/videos_admin_view.dart';
import 'package:physio_app/features/home/presentation/views/widgets/chat_view_body.dart';
import 'package:physio_app/features/home/presentation/views/widgets/diet_list.dart';
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
  static const String forgotPassword = '/forgot-password';
  static const String chatPage = '/chat';
  static const String nameChangePage = '/name-change';
  static const String passwordChangePage = '/password-change';
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
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ChatCubit>.value(
                value:
                    ChatCubit(FirebaseAuth.instance.currentUser?.email ?? ''),
              )
            ],
            child: SelectorPageView(),
          ),
        ),
      ),
      GoRoute(
        path: forgotPassword,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: ForgotPasswordView(),
        ),
      ),
      GoRoute(
        path: chatPage,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white12,
              body: ChatViewBody(
                  currentUserEmail: state.extra as String,
                  hasAnsweredQuestions: false),
            ),
          ),
        ),
      ),
      GoRoute(
        path: nameChangePage,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: ChangeNameView(),
        ),
      ),
      GoRoute(
        path: passwordChangePage,
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: ChangePasswordView(),
        ),
      ),
      GoRoute(
        path: '/diet-list',
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: DietListView(),
        ),
      ),
      GoRoute(
        path: '/videos-admin',
        pageBuilder: (context, state) => buildPageWithSlideLeftTransition(
          context: context,
          state: state,
          child: VideosAdminView(),
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
