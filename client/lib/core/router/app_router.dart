import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papersafe/core/providers/auth_provider.dart';

// Screens
import 'package:papersafe/views/login_signup.dart';
import 'package:papersafe/views/mobile_otp.dart';
import 'package:papersafe/views/tell_more.dart';
import 'package:papersafe/views/homepage.dart';
import 'package:papersafe/views/scanner_page.dart';
import 'package:papersafe/views/ai_assistant_page.dart';
import 'package:papersafe/views/qr_scanner_page.dart';
import 'package:papersafe/views/qr_generator_page.dart';
import 'package:papersafe/views/nearby_sharing_page.dart';

import 'package:papersafe/views/search_page.dart';
import 'package:papersafe/views/categories.dart';
import 'package:papersafe/views/settings.dart';
import 'package:papersafe/views/trash_screen.dart';
import 'package:papersafe/views/activity_timeline_page.dart';
import 'package:papersafe/views/maps_page.dart';
import 'package:papersafe/core/providers/biometric_provider.dart';
import 'package:papersafe/views/biometric_lock_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const otp = '/otp';
  static const tellMore = '/tell-more';
  static const home = '/';
  static const documents = '/documents';
  static const categories = '/categories';
  static const favourites = '/favourites';
  static const addDocument = '/add-document';
  static const viewDocument = '/view-document';
  static const settings = '/settings';
  static const scanner = '/scanner';
  static const aiChat = '/ai-chat';
  static const qrScanner = '/qr-scanner';
  static const qrGenerator = '/qr-generator';
  static const nearbyShare = '/nearby-share';
  static const search = '/search';
  static const trash = '/trash';
  static const activityTimeline = '/activity-timeline';
  static const maps = '/maps';
  static const biometricLock = '/biometric-lock';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isBiometricEnabled = ref.watch(biometricEnabledProvider);
  final isAppLocked = ref.watch(isAppLockedProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading = authState.isLoading;

      if (isLoading) return null;

      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.otp ||
          state.matchedLocation == AppRoutes.tellMore;

      if (!isLoggedIn && !isOnAuthRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }

      if (isLoggedIn && isBiometricEnabled && isAppLocked && state.matchedLocation != AppRoutes.biometricLock) {
        return AppRoutes.biometricLock;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.biometricLock,
        name: 'biometricLock',
        builder: (context, state) => const BiometricLockScreen(),
      ),
      // Auth flow
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
      // Main shell
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
            builder: (context, state) => const Categories(),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      // Full-screen routes
      GoRoute(
        path: AppRoutes.scanner,
        name: 'scanner',
        builder: (context, state) => const ScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        name: 'aiChat',
        builder: (context, state) => const AIAssistantPage(),
      ),
      GoRoute(
        path: AppRoutes.qrScanner,
        name: 'qrScanner',
        builder: (context, state) => const QRScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.qrGenerator,
        name: 'qrGenerator',
        builder: (context, state) => const QRGeneratorPage(),
      ),
      GoRoute(
        path: AppRoutes.nearbyShare,
        name: 'nearbyShare',
        builder: (context, state) => const NearbySharingPage(),
      ),
      GoRoute(
        path: AppRoutes.trash,
        name: 'trash',
        builder: (context, state) => const TrashScreen(),
      ),
      GoRoute(
        path: AppRoutes.activityTimeline,
        name: 'activityTimeline',
        builder: (context, state) => const ActivityTimelinePage(),
      ),
      GoRoute(
        path: AppRoutes.maps,
        name: 'maps',
        builder: (context, state) => const MapsPage(),
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
    (icon: Icons.near_me,               label: 'Nearby',    route: AppRoutes.nearbyShare),
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
