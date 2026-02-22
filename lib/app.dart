import 'dart:io' show Platform;

import 'package:alice/alice.dart';
import 'package:finguard/features/app_version/data/app_version_repository.dart';
import 'package:finguard/features/app_version/data/model/app_version_response.dart';
import 'package:finguard/features/activity/data/activity_repository.dart';
import 'package:finguard/features/activity/viewmodel/activity_viewmodel.dart';
import 'package:finguard/features/auth/view/login_screen.dart';
import 'package:finguard/features/budget/data/budget_repository.dart';
import 'package:finguard/features/budget/viewmodel/budget_viewmodel.dart';
import 'package:finguard/features/category/data/category_repository.dart';
import 'package:finguard/features/category/viewmodel/category_viewmodel.dart';
import 'package:finguard/features/dashboard/view/onboarding_dashboard.dart';
import 'package:finguard/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:finguard/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:finguard/features/risk/data/risk_repository.dart';
import 'package:finguard/features/risk/view/risk_detail_screen.dart';
import 'package:finguard/features/risk/viewmodel/risk_detail_viewmodel.dart';
import 'package:finguard/features/risk/viewmodel/risk_trend_viewmodel.dart';
import 'package:finguard/features/transaction/data/transaction_repository.dart';
import 'package:finguard/features/transaction/view/add_transaction_screen.dart';
import 'package:finguard/features/transaction/view/transaction_detail_screen.dart';
import 'package:finguard/features/transaction/viewmodel/transaction_viewmodel.dart';
import 'package:finguard/l10n/app_localizations.dart';
import 'package:finguard/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/ui/app_colors.dart';
import 'core/app_settings.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/user/data/user_repository.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/splash/view/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FinguardApp extends StatelessWidget {
  const FinguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings();
    final navigatorKey = GlobalKey<NavigatorState>();
    final alice = Alice(
      showNotification: true,
      showInspectorOnShake: true,
      navigatorKey: navigatorKey,
    );

    return MultiProvider(
      providers: [
        Provider(create: (_) => LocalStorage()),
        Provider(create: (_) => alice),
        Provider(
          create: (context) =>
              ApiClient(context.read<LocalStorage>(), alice: alice),
        ),
        Provider(
          create: (context) => AuthRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) =>
              UserRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create: (context) =>
              DashboardRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create: (context) =>
              AppVersionRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create: (context) =>
              RiskRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => CategoryRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => TransactionRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => ActivityRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => BudgetRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(create: (_) => settings),
        ChangeNotifierProxyProvider4<AuthRepository, UserRepository,
            LocalStorage, AppSettings, AuthViewmodel>(
          create: (context) => AuthViewmodel(
            context.read<AuthRepository>(),
            context.read<UserRepository>(),
            context.read<LocalStorage>(),
            context.read<AppSettings>(),
          ),
          update: (context, authRepo, userRepo, storage, settings, previous) =>
              previous ?? AuthViewmodel(authRepo, userRepo, storage, settings),
        ),
        ChangeNotifierProxyProvider<DashboardRepository, DashboardViewmodel>(
          create: (context) => DashboardViewmodel(
            dashboardRepository: context.read<DashboardRepository>(),
          ),
          update: (context, repo, previous) =>
              previous ?? DashboardViewmodel(dashboardRepository: repo),
        ),
        ChangeNotifierProxyProvider<RiskRepository, RiskTrendViewmodel>(
          create: (context) =>
              RiskTrendViewmodel(context.read<RiskRepository>()),
          update: (_, repo, previous) => previous ?? RiskTrendViewmodel(repo),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RiskDetailViewmodel(repository: context.read<RiskRepository>()),
        ),
        ChangeNotifierProxyProvider<CategoryRepository, CategoryViewModel>(
          create: (context) =>
              CategoryViewModel(context.read<CategoryRepository>()),
          update: (_, repo, previous) => previous ?? CategoryViewModel(repo),
        ),
        ChangeNotifierProxyProvider3<TransactionRepository, AuthRepository,
            LocalStorage, TransactionViewModel>(
          create: (context) => TransactionViewModel(
            context.read<TransactionRepository>(),
            context.read<AuthRepository>(),
            context.read<LocalStorage>(),
          ),
          update: (context, repo, authRepo, storage, previous) =>
              previous ?? TransactionViewModel(repo, authRepo, storage),
        ),
        ChangeNotifierProxyProvider<ActivityRepository, ActivityViewmodel>(
          create: (context) => ActivityViewmodel(
            activityRepository: context.read<ActivityRepository>(),
          ),
          update: (_, repo, previous) =>
              previous ?? ActivityViewmodel(activityRepository: repo),
        ),
        ChangeNotifierProxyProvider<BudgetRepository, BudgetViewmodel>(
          create: (context) =>
              BudgetViewmodel(repository: context.read<BudgetRepository>()),
          update: (_, repo, previous) =>
              previous ?? BudgetViewmodel(repository: repo),
        ),
        ChangeNotifierProxyProvider5<UserRepository, AuthRepository,
            LocalStorage, ApiClient, AppVersionRepository, ProfileViewmodel>(
          create: (context) => ProfileViewmodel(
            userRepository: context.read<UserRepository>(),
            authRepository: context.read<AuthRepository>(),
            localStorage: context.read<LocalStorage>(),
            apiClient: context.read<ApiClient>(),
            appVersionRepository: context.read<AppVersionRepository>(),
          ),
          update: (context, userRepo, authRepo, storage, apiClient,
                  appVersionRepo, previous) =>
              previous ??
              ProfileViewmodel(
                userRepository: userRepo,
                authRepository: authRepo,
                localStorage: storage,
                apiClient: apiClient,
                appVersionRepository: appVersionRepo,
              ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        locale: settings.locale,
        supportedLocales: const [Locale('en'), Locale('id')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'Finguard',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ).copyWith(primary: AppColors.primary),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const _RootDecider(),
          '/main': (_) => const MainNavigationScreen(),
          '/risk-detail': (_) => const RiskDetailScreen(),
          '/transaction-detail': (_) => const TransactionDetailScreen(),
          '/create-transaction': (_) => const AddTransactionScreen(),
        },
      ),
    );
  }
}

class _RootDecider extends StatefulWidget {
  const _RootDecider();

  @override
  State<_RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<_RootDecider> {
  static const _optionalUpdateSnooze = Duration(days: 3);
  bool? isOnboardingCompleted;
  bool _hasActiveSession = false;
  bool _wasLoggedOut = false;
  int? onboardingInitialStep;
  bool isBootstrapping = true;
  bool _hasInitialized = false;
  bool _isVersionBlocked = false;
  bool _isMaintenanceMode = false;
  String? _versionMessage;
  String? _storeUrl;
  bool _isLaunchingStore = false;
  bool _showOptionalUpdatePrompt = false;
  bool _optionalUpdatePromptShown = false;
  String? _optionalUpdateMessage;
  String? _optionalUpdateStoreUrl;
  String? _optionalUpdateLatestVersion;

  @override
  void initState() {
    super.initState();
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initialize();
      });
    }
  }

  Future<void> _initialize() async {
    final canProceed = await _checkAppVersionGate();
    if (!mounted) return;

    if (!canProceed) {
      setState(() {
        isBootstrapping = false;
      });
      return;
    }

    final authVM = context.read<AuthViewmodel>();
    final storage = context.read<LocalStorage>();

    await authVM.bootstrap();
    while (!authVM.isBootstrapComplete) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    final completed = await storage.isOnboardingCompleted();
    final pendingStep = await storage.getPendingOnboardingStep();
    final wasLoggedOut = await storage.wasLoggedOut();
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();
    final userUid = await storage.getUserUid();
    final hasSession = accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty &&
        userUid != null &&
        userUid.isNotEmpty;

    if (mounted) {
      setState(() {
        _isVersionBlocked = false;
        _isMaintenanceMode = false;
        _versionMessage = null;
        _storeUrl = null;
        isOnboardingCompleted = completed;
        onboardingInitialStep = pendingStep;
        _wasLoggedOut = wasLoggedOut;
        _hasActiveSession = hasSession;
        isBootstrapping = false;
      });
    }
  }

  Future<bool> _checkAppVersionGate() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    final repository = context.read<AppVersionRepository>();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await repository.checkVersion(
        platform: Platform.isAndroid ? 'android' : 'ios',
        version: packageInfo.version,
      );

      if (!mounted) return false;

      return await _applyVersionGateResponse(
        response,
        currentVersion: packageInfo.version,
      );
    } catch (_) {
      // Fail-open so temporary API issues do not block app startup.
      return true;
    }
  }

  Future<bool> _applyVersionGateResponse(
    AppVersionResponse response, {
    required String currentVersion,
  }) async {
    final storage = context.read<LocalStorage>();

    if (response.maintenanceMode) {
      setState(() {
        _isVersionBlocked = true;
        _isMaintenanceMode = true;
        _versionMessage = response.maintenanceMessage ??
            'We are currently under maintenance. Please try again later.';
        _storeUrl = null;
      });
      return false;
    }

    final needsForceUpdate = response.forceUpdate || response.mustUpdate;
    if (!needsForceUpdate) {
      final hasOptionalUpdate = response.latestVersion.isNotEmpty &&
          _compareVersion(response.latestVersion, currentVersion) > 0;

      if (hasOptionalUpdate) {
        final isSuppressed = await storage.shouldSuppressOptionalUpdate(
          response.latestVersion,
        );
        if (isSuppressed) {
          return true;
        }

        setState(() {
          _showOptionalUpdatePrompt = true;
          _optionalUpdateMessage =
              'A newer version (${response.latestVersion}) is available. '
              'Update now for the latest improvements.';
          _optionalUpdateStoreUrl = response.storeUrl;
          _optionalUpdateLatestVersion = response.latestVersion;
        });
      } else {
        await storage.clearOptionalUpdateSnooze();
      }
      return true;
    }

    setState(() {
      _isVersionBlocked = true;
      _isMaintenanceMode = false;
      _versionMessage =
          'A new version is required to continue. Please update the app to '
          '${response.latestVersion.isEmpty ? response.minSupportedVersion : response.latestVersion}.';
      _storeUrl = response.storeUrl;
    });
    return false;
  }

  int _compareVersion(String a, String b) {
    final aParts = _normalizeVersion(a);
    final bParts = _normalizeVersion(b);
    final maxLength =
        aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < maxLength; i++) {
      final left = i < aParts.length ? aParts[i] : 0;
      final right = i < bParts.length ? bParts[i] : 0;
      if (left > right) return 1;
      if (left < right) return -1;
    }
    return 0;
  }

  List<int> _normalizeVersion(String value) {
    final normalized = value
        .split('+')
        .first
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .split('.')
        .where((part) => part.isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .toList();

    if (normalized.isEmpty) return [0];
    return normalized;
  }

  Future<void> _openStore() async {
    final rawUrl = _storeUrl;
    if (rawUrl == null || rawUrl.trim().isEmpty || _isLaunchingStore) {
      return;
    }

    setState(() {
      _isLaunchingStore = true;
    });

    try {
      final uri = Uri.tryParse(rawUrl.trim());
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunchingStore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVersionBlocked &&
        !isBootstrapping &&
        _showOptionalUpdatePrompt &&
        !_optionalUpdatePromptShown) {
      _optionalUpdatePromptShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Update Available'),
              content: Text(
                _optionalUpdateMessage ??
                    'A newer version of the app is available.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final latestVersion = _optionalUpdateLatestVersion;
                    if (latestVersion != null && latestVersion.isNotEmpty) {
                      await context.read<LocalStorage>().snoozeOptionalUpdate(
                            latestVersion: latestVersion,
                            duration: _optionalUpdateSnooze,
                          );
                    }
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    final previousUrl = _storeUrl;
                    _storeUrl = _optionalUpdateStoreUrl;
                    await _openStore();
                    _storeUrl = previousUrl;
                  },
                  child: const Text('Update now'),
                ),
              ],
            );
          },
        );
      });
    }

    if (_isVersionBlocked) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isMaintenanceMode
                          ? 'Maintenance Mode'
                          : 'Update Required',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _versionMessage ??
                          (_isMaintenanceMode
                              ? 'Please try again in a few minutes.'
                              : 'Please update the app to continue.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (!_isMaintenanceMode &&
                        (_storeUrl ?? '').trim().isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLaunchingStore ? null : _openStore,
                          child: Text(
                            _isLaunchingStore
                                ? 'Opening store...'
                                : 'Update now',
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          setState(() {
                            isBootstrapping = true;
                          });
                          await _initialize();
                        },
                        child: const Text('Check again'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isBootstrapping || isOnboardingCompleted == null) {
      return const SplashScreen();
    }

    if (!isOnboardingCompleted!) {
      if (_hasActiveSession) {
        return const OnboardingFlowScreen(initialStep: 2, allowBack: false);
      }
      if (_wasLoggedOut) {
        return const LoginScreen();
      }
      return OnboardingFlowScreen(initialStep: onboardingInitialStep ?? 0);
    }

    if (!_hasActiveSession) {
      return const LoginScreen();
    }

    return const MainNavigationScreen();
  }
}
