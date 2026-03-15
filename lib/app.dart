import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/connectivity_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/closet/bloc/closet_cubit.dart';
import 'features/closet/data/closet_repository.dart';
import 'features/profile/bloc/profile_cubit.dart';
import 'features/profile/data/profile_api.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/scan/bloc/scan_bloc.dart';
import 'features/scan/data/scan_api.dart';
import 'features/scan/data/scan_repository.dart';

class FITQApp extends StatefulWidget {
  final PrefsService prefsService;
  final ApiClient apiClient;
  final ConnectivityService connectivity;

  const FITQApp({
    super.key,
    required this.prefsService,
    required this.apiClient,
    required this.connectivity,
  });

  @override
  State<FITQApp> createState() => _FITQAppState();
}

class _FITQAppState extends State<FITQApp> {
  late final AuthRepository _authRepository;
  late final ScanRepository _scanRepository;
  late final ClosetRepository _closetRepository;
  late final ProfileRepository _profileRepository;
  late final AuthBloc _authBloc;
  late final ScanBloc _scanBloc;
  late final ClosetCubit _closetCubit;
  late final ProfileCubit _profileCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      api: AuthApi(client: widget.apiClient),
      prefs: widget.prefsService,
    );

    final scanApi = ScanApi(client: widget.apiClient);
    _scanRepository = ScanRepository(api: scanApi);
    _closetRepository = ClosetRepository(api: scanApi);
    _profileRepository = ProfileRepository(
      api: ProfileApi(client: widget.apiClient),
    );

    _authBloc = AuthBloc(authRepository: _authRepository);
    _scanBloc = ScanBloc(scanRepository: _scanRepository);
    _closetCubit = ClosetCubit(repo: _closetRepository);
    _profileCubit = ProfileCubit(
      repo: _profileRepository,
      authBloc: _authBloc,
    );

    _router = AppRouter.createRouter(
      authBloc: _authBloc,
      prefs: widget.prefsService,
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _scanBloc.close();
    _closetCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.prefsService),
        RepositoryProvider.value(value: widget.connectivity),
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _scanRepository),
        RepositoryProvider.value(value: _closetRepository),
        RepositoryProvider.value(value: _profileRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _scanBloc),
          BlocProvider.value(value: _closetCubit),
          BlocProvider.value(value: _profileCubit),
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
