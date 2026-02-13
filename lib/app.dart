import 'package:finguard_app/features/category/data/category_repository.dart';
import 'package:finguard_app/features/category/viewmodel/category_viewmodel.dart';
import 'package:finguard_app/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:finguard_app/features/risk/data/risk_repository.dart';
import 'package:finguard_app/features/risk/view/risk_detail_screen.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_detail_viewmodel.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_trend_viewmodel.dart';
import 'package:finguard_app/features/transaction/data/transaction_repository.dart';
import 'package:finguard_app/features/transaction/view/transaction_detail_screen.dart';
import 'package:finguard_app/features/transaction/viewmodel/transaction_viewmodel.dart';
import 'package:finguard_app/l10n/app_localizations.dart';
import 'package:finguard_app/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return MultiProvider(
      providers: [
        // Core
        Provider(create: (_) => LocalStorage()),
        Provider(create: (context) => ApiClient(context.read<LocalStorage>())),

        // Repositories
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
              RiskRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => CategoryRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => TransactionRepository(context.read<ApiClient>()),
        ),

        // Global App Settings
        ChangeNotifierProvider(create: (_) => settings),

        // Auth ViewModel
        ChangeNotifierProxyProvider4<
          AuthRepository,
          UserRepository,
          LocalStorage,
          AppSettings,
          AuthViewmodel
        >(
          create: (context) => AuthViewmodel(
            context.read<AuthRepository>(),
            context.read<UserRepository>(),
            context.read<LocalStorage>(),
            context.read<AppSettings>(),
          ),
          update: (context, authRepo, userRepo, storage, settings, previous) =>
              previous ?? AuthViewmodel(authRepo, userRepo, storage, settings),
        ),

        // Dashboard ViewModel
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

        // Risk detail ViewModel
        ChangeNotifierProvider(
          create: (context) =>
              RiskDetailViewmodel(repository: context.read<RiskRepository>()),
        ),

        // Category ViewModel
        ChangeNotifierProxyProvider<CategoryRepository, CategoryViewModel>(
          create: (context) =>
              CategoryViewModel(context.read<CategoryRepository>()),
          update: (_, repo, previous) => previous ?? CategoryViewModel(repo),
        ),

        ChangeNotifierProxyProvider<
          TransactionRepository,
          TransactionViewModel
        >(
          create: (context) =>
              TransactionViewModel(context.read<TransactionRepository>()),
          update: (_, repo, previous) => previous ?? TransactionViewModel(repo),
        ),
      ],

      child: MaterialApp(
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
        theme: ThemeData(useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/home': (_) => const MainNavigationScreen(),
          '/risk-detail': (_) => const RiskDetailScreen(),
          '/transaction-detail': (_) => const TransactionDetailScreen(),
          // '/categories': (_) => const CategoryScreen(),
        },
      ),
    );
  }
}
