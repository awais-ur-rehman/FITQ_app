import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/scan/bloc/scan_bloc.dart';
import 'features/scan/data/scan_api.dart';
import 'features/scan/data/scan_repository.dart';

class FITQApp extends StatefulWidget {
  final PrefsService prefsService;
  final ApiClient apiClient;

  const FITQApp({
    super.key,
    required this.prefsService,
    required this.apiClient,
  });

  @override
  State<FITQApp> createState() => _FITQAppState();
}

class _FITQAppState extends State<FITQApp> {
  late final AuthRepository _authRepository;
  late final ScanRepository _scanRepository;
  late final AuthBloc _authBloc;
  late final ScanBloc _scanBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      api: AuthApi(client: widget.apiClient),
      prefs: widget.prefsService,
    );
    _scanRepository = ScanRepository(
      api: ScanApi(client: widget.apiClient),
    );
    _authBloc = AuthBloc(authRepository: _authRepository);
    _scanBloc = ScanBloc(scanRepository: _scanRepository);
    _router = AppRouter.createRouter(
      authBloc: _authBloc,
      prefs: widget.prefsService,
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _scanBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.prefsService),
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _scanRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _scanBloc),
        ],
        child: MaterialApp.router(
          title: 'FITQ',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
