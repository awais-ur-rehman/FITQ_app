import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/prefs_service.dart';
import 'core/theme/app_theme.dart';

class FITQApp extends StatelessWidget {
  final PrefsService prefsService;
  final ApiClient apiClient;

  const FITQApp({
    super.key,
    required this.prefsService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: const [
        // Repositories added progressively as features are built:
        // RepositoryProvider(create: (_) => AuthRepository(...)),
        // RepositoryProvider(create: (_) => ScanRepository(...)),
        // RepositoryProvider(create: (_) => ProfileRepository(...)),
      ],
      child: MultiBlocProvider(
        providers: const [
          // BLoCs added progressively as features are built:
          // BlocProvider(create: (ctx) => AuthBloc(
          //   authRepository: ctx.read<AuthRepository>(),
          // )),
        ],
        child: MaterialApp.router(
          title: 'FITQ',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
