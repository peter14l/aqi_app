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
import 'scaffold_with_navbar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
