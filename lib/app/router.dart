import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/gameplay/gameplay_screen.dart';
import '../features/profile/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/play',
      name: 'play',
      builder: (context, state) => const GameplayScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
