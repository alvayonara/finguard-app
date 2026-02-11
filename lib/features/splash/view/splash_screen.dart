import 'package:finguard_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:finguard_app/features/dashboard/view/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authViewmodel = context.read<AuthViewmodel>();
      final userUid = await authViewmodel.initUser();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userUid: userUid)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewmodel>();

    return Scaffold(
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : const Text('Finguard Ready'),
      ),
    );
  }
}
