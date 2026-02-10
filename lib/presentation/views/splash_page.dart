import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AuthViewmodel>().init()
    );
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