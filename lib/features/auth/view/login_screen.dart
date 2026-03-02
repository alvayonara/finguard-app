import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/core/ui/app_colors.dart';
import 'package:finguard/core/storage/local_storage.dart';
import 'package:finguard/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:finguard/features/dashboard/view/onboarding_dashboard.dart';
import 'package:finguard/features/user/data/user_repository.dart';
import 'package:finguard/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? error;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final authVM = context.read<AuthViewmodel>();
      final localStorage = context.read<LocalStorage>();
      final userRepo = context.read<UserRepository>();
      final apiClient = context.read<ApiClient>();

      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          error = "Google sign-in failed: No idToken.";
        });
        return;
      }

      final authResponse = await authVM.authRepository.loginWithGoogle(
        idToken: idToken,
      );

      await localStorage.saveAuthSession(
        userUid: authResponse.userUid,
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      await localStorage.clearLoggedOutFlag();

      await apiClient.refreshCachedSessionFromStorage();
      await authVM.syncPreferences();

      if (!authResponse.onboardingCompleted) {
        if (!authResponse.initialIncomeSet) {
          await localStorage.setPendingOnboardingStep(2);
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  const OnboardingFlowScreen(initialStep: 2, allowBack: false),
            ),
            (route) => false,
          );
          return;
        }

        try {
          await userRepo.completeOnboarding();
        } catch (_) {}

        await localStorage.markOnboardingCompleted();
        await localStorage.clearPendingOnboardingStep();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
        return;
      }

      await localStorage.markOnboardingCompleted();
      await localStorage.clearPendingOnboardingStep();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = "Google sign-in failed. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAE6FF), Color(0xFFF6F7FB), Color(0xFFDDE5FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 25,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          "assets/image/onboarding_intro.svg",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 34),
                      const Text(
                        "Welcome to Finguard",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Track spending,\ncontrol risk.",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Sign in to sync your data and continue securely across devices.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 42),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/image/google_logo.svg",
                                height: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isLoading
                                    ? "Signing in..."
                                    : "Sign in with Google",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          "Sign in is required to continue",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
