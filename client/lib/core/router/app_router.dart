import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papersafe/core/providers/auth_provider.dart';

// Screens
import 'package:papersafe/views/login_signup.dart';
import 'package:papersafe/views/mobile_otp.dart';
import 'package:papersafe/views/tell_more.dart';
import 'package:papersafe/views/your_documents.dart';
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
import 'package:papersafe/views/profile_details_page.dart';

class AppRoutes {
  static const login = '/login';
  static const otp = '/otp';
  static const tellMore = '/tell-more';
  static const home = '/';
  static const profileDetails = '/profile-details';
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
            builder: (context, state) => const YourDocuments(),
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
          GoRoute(
            path: AppRoutes.qrScanner,
            name: 'qrScanner',
            builder: (context, state) => const QRScannerPage(),
          ),
          GoRoute(
            path: AppRoutes.scanner,
            name: 'scanner',
            builder: (context, state) => const ScannerPage(),
          ),
          GoRoute(
            path: AppRoutes.nearbyShare,
            name: 'nearbyShare',
            builder: (context, state) => const NearbySharingPage(),
          ),
        ],
      ),
      // Full-screen routes
      GoRoute(
        path: AppRoutes.profileDetails,
        name: 'profileDetails',
        builder: (context, state) => const ProfileDetailsPage(),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        name: 'aiChat',
        builder: (context, state) => const AIAssistantPage(),
      ),

      GoRoute(
        path: AppRoutes.qrGenerator,
        name: 'qrGenerator',
        builder: (context, state) => const QRGeneratorPage(),
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
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [0];

  final _destinations = const [
    (icon: Icons.folder_rounded,          label: 'Vault',     route: AppRoutes.home),
    (icon: Icons.document_scanner_rounded, label: 'Scan',      route: AppRoutes.scanner),
    (icon: Icons.qr_code_2_rounded,       label: 'QR tools',  route: AppRoutes.qrScanner),
    (icon: Icons.near_me_rounded,         label: 'Nearby',    route: AppRoutes.nearbyShare),
    (icon: Icons.settings_rounded,        label: 'Settings',  route: AppRoutes.settings),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Lock app on minimizing
      ref.read(isAppLockedProvider.notifier).state = true;
    }
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      _navigationHistory.remove(index);
      _navigationHistory.add(index);
    });
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Never let the OS handle the pop — we always intercept it
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_navigationHistory.length > 1) {
          // Go back to the previously visited tab
          setState(() {
            _navigationHistory.removeLast();
            _selectedIndex = _navigationHistory.last;
          });
          context.go(_destinations[_selectedIndex].route);
        } else {
          // Already at the root Documents tab — go home cleanly
          setState(() {
            _selectedIndex = 0;
            _navigationHistory
              ..clear()
              ..add(0);
          });
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D1424),
            border: Border(
              top: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: const Color(0xFF0D1424),
              indicatorColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Color(0xFF5B7FFF), size: 22);
                }
                return const IconThemeData(color: Color(0xFF64748B), size: 20);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: Color(0xFF5B7FFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  );
                }
                return const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                );
              }),
            ),
            child: NavigationBar(
              height: 62,
              elevation: 0,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: _destinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        label: d.label,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
