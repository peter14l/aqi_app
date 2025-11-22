import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/aqi/presentation/home_screen.dart';
import '../features/aqi/presentation/prediction_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/route/presentation/route_exposure_screen.dart';
import '../features/purifier/presentation/screens/purifier_list_screen.dart';
import '../features/purifier/presentation/screens/add_purifier_screen.dart';
import '../features/purifier/presentation/screens/purifier_detail_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/application/auth_provider.dart';
import 'scaffold_with_navbar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // If not authenticated and not on auth page, redirect to login
      if (!isAuthenticated && !isOnAuthPage) {
        return '/login';
      }

      // If authenticated and on auth page, redirect to home
      if (isAuthenticated && isOnAuthPage) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes (no navbar)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // App routes (with navbar)
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavbar(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/habits',
            builder: (context, state) => const HabitsScreen(),
          ),
          GoRoute(
            path: '/prediction',
            builder: (context, state) => const PredictionScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/route-exposure',
            builder: (context, state) => const RouteExposureScreen(),
          ),
          GoRoute(
            path: '/purifier',
            builder: (context, state) => const PurifierListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddPurifierScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PurifierDetailScreen(purifierId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
