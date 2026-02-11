import 'package:finguard_app/core/theme/app_theme.dart';
import 'package:finguard_app/features/dashboard/data/dashboard_repository.dart';
import 'package:finguard_app/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/splash/view/splash_screen.dart';
import 'features/auth/data/auth_repository.dart';

class FinguardApp extends StatelessWidget {
  const FinguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final localStorage = LocalStorage();
    final dashboardRepository = DashboardRepository(apiClient: apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewmodel(AuthRepository(apiClient), localStorage),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DashboardViewmodel(dashboardRepository: dashboardRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Finguard',
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
