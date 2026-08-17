import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:papersafe/core/router/app_router.dart';
import 'package:papersafe/core/theme/app_theme.dart';
import 'package:papersafe/core/theme/theme_provider.dart';

// Legacy singletons – still needed until Phase 1-A migration completes
import 'package:papersafe/models/aadhar_frame.dart';
import 'package:papersafe/models/documents_manager.dart';
import 'package:papersafe/models/pan_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix status bar style globally
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-load document frames (legacy – kept for backward compat)
  final aadharFrame = AadharFrame();
  await aadharFrame.loadDetails();

  final panFrame = PanFrame();
  await panFrame.loadDetails();

  DocumentManager().initialize();

  runApp(
    // ProviderScope is required by Riverpod
    const ProviderScope(
      child: PaperSafeApp(),
    ),
  );
}

class PaperSafeApp extends ConsumerWidget {
  const PaperSafeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark  = ref.watch(themeModeProvider);
    final router  = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro baseline
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'PaperSafe',
          debugShowCheckedModeBanner: false,
          theme:      AppTheme.light,
          darkTheme:  AppTheme.dark,
          themeMode:  isDark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
