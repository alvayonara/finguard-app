import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/views/splash_page.dart';

class FinguardApp extends StatelessWidget {
  const FinguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final localStorage = LocalStorage();
    final remote = AuthRemoteDatasource(apiClient: apiClient);
    final authRepository = AuthRepository(
      authRemoteDatasource: remote,
      localStorage: localStorage,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewmodel(authRepository)),
      ],
      child: MaterialApp(title: 'Finguard', home: SplashPage()),
    );
  }
}
