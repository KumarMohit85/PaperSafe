import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papersafe/core/providers/auth_provider.dart';

// ─── Existing Screens (will be redesigned in Phase 1-A) ──────────────────────
import 'package:papersafe/views/login_signup.dart';
import 'package:papersafe/views/mobile_otp.dart';
import 'package:papersafe/views/tell_more.dart';
import 'package:papersafe/views/homepage.dart';

// ─── Route names ─────────────────────────────────────────────────────────────
class AppRoutes {
  static const login        = '/login';
  static const otp          = '/otp';
  static const tellMore     = '/tell-more';
  static const home         = '/';
  static const documents    = '/documents';
  static const categories   = '/categories';
  static const favourites   = '/favourites';
  static const addDocument  = '/add-document';
  static const viewDocument = '/view-document';
  static const settings     = '/settings';
  static const scanner      = '/scanner';
  static const aiChat       = '/ai-chat';
  static const qrScanner    = '/qr-scanner';
  static const qrGenerator  = '/qr-generator';
  static const nearbyShare  = '/nearby-share';
  static const maps         = '/maps';
  static const search       = '/search';
  static const dashboard    = '/dashboard';
  static const trash        = '/trash';
}

// ─── Router provider ─────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading  = authState.isLoading;

      // While loading auth state, don't redirect
      if (isLoading) return null;

      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.otp ||
          state.matchedLocation == AppRoutes.tellMore;

      // Not logged in → send to login
      if (!isLoggedIn && !isOnAuthRoute) {
        return AppRoutes.login;
      }

      // Already logged in → don't allow going back to login
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ─── Auth flow ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '${AppRoutes.otp}/:email',
        name: 'otp',
        builder: (context, state) {
          final email = state.pathParameters['email'] ?? '';
          return MobileOtpPage(email: email);
        },
      ),
      GoRoute(
        path: '${AppRoutes.tellMore}/:email',
        name: 'tellMore',
        builder: (context, state) {
          final email = state.pathParameters['email'] ?? '';
          return UserInformation(email: email);
        },
      ),

      // ─── Main shell ──────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.categories,
            name: 'categories',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),

      // ─── Full-screen routes ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.scanner,
        name: 'scanner',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoutes.qrScanner,
        name: 'qrScanner',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoutes.qrGenerator,
        name: 'qrGenerator',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoutes.nearbyShare,
        name: 'nearbyShare',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoutes.maps,
        name: 'maps',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const Placeholder(),
      ),
    ],
  );
});

/// Bottom-navigation shell that wraps the 5 main tab destinations.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final _destinations = const [
    (icon: Icons.folder_rounded,        label: 'Documents', route: AppRoutes.home),
    (icon: Icons.search_rounded,         label: 'Search',    route: AppRoutes.search),
    (icon: Icons.qr_code_scanner_rounded,label: 'QR',        route: AppRoutes.qrScanner),
    (icon: Icons.map_rounded,            label: 'Maps',      route: AppRoutes.maps),
    (icon: Icons.settings_rounded,       label: 'Settings',  route: AppRoutes.settings),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations.map((d) => NavigationDestination(
          icon: Icon(d.icon),
          label: d.label,
        )).toList(),
      ),
    );
  }
}
