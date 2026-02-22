import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:finguard/core/app_settings.dart';
import 'package:finguard/core/storage/local_storage.dart';
import 'package:finguard/core/utils/currency_symbol.dart';
import 'package:finguard/core/utils/thousand_separator_formatter.dart';
import 'package:finguard/features/transaction/data/enum/transaction_type_enum.dart';
import 'package:finguard/features/transaction/data/model/create_transaction_request.dart';
import 'package:finguard/features/transaction/viewmodel/transaction_viewmodel.dart';
import 'package:finguard/features/user/data/user_repository.dart';
import 'package:finguard/main_navigation.dart';
import 'package:finguard/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:finguard/core/network/api_client.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final int initialStep;

  const OnboardingFlowScreen({super.key, this.initialStep = 0});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late int step;
  bool isLoading = false;
  String? error;

  final TextEditingController incomeController = TextEditingController(
    text: "0",
  );
  final FocusNode incomeFocusNode = FocusNode();

  String selectedCurrency = "USD";
  final List<String> currencies = ["USD", "EUR", "JPY", "SGD", "IDR"];

  double? get _incomeValue {
    final cleanText = incomeController.text.replaceAll(',', '');
    return double.tryParse(cleanText);
  }

  bool get _canSubmitIncome {
    final income = _incomeValue;
    return !isLoading && income != null && income > 0;
  }

  void _next() {
    setState(() => step++);
    if (step == 2) {
      Future.delayed(const Duration(milliseconds: 250), () {
        incomeFocusNode.requestFocus();
      });
    }
  }

  void _back() {
    if (step > 0) {
      setState(() => step--);
    }
  }

  Future<void> _finish() async {
    final income = _incomeValue;
    if (income == null || income <= 0) {
      setState(() => error = "Income can't be empty");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final txVM = context.read<TransactionViewModel>();
      final settings = context.read<AppSettings>();
      final storage = LocalStorage();
      final userRepo = context.read<UserRepository>();

      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      await txVM.createTransaction(
        request: CreateTransactionRequest(
          type: TransactionTypeEnum.INCOME.name,
          amount: income,
          categoryId: 1,
          occurredAt: formattedDate,
        ),
      );

      await storage.saveCurrency(selectedCurrency);
      await storage.markFirstLoginCoachmarkPending();
      await storage.markOnboardingCompleted();
      settings.setCurrency(selectedCurrency);
      try {
        await userRepo.updatePreferences(
          selectedCurrency,
          settings.locale.languageCode,
        );
      } catch (_) {}

      try {
        await userRepo.completeOnboarding();
      } catch (_) {}

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        final errorMsg = e.toString();
        if (errorMsg.contains('401')) {
          error = "Authentication error. Please restart the app.";
        } else if (errorMsg.contains('404')) {
          error = "Service not available. Please skip onboarding for now.";
        } else if (errorMsg.contains('400')) {
          error = "Invalid data. Please check your income amount.";
        } else {
          error = "Failed to save income. Please try again.";
        }
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final authVM = context.read<AuthViewmodel>();
      final localStorage = context.read<LocalStorage>();
      final userRepo = context.read<UserRepository>();

      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
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

      try {
        await context.read<ApiClient>().refreshCachedSessionFromStorage();
      } catch (_) {}

      if (!authResponse.onboardingCompleted) {
        if (!authResponse.initialIncomeSet) {
          await localStorage.setPendingOnboardingStep(2);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  OnboardingFlowScreen(key: UniqueKey(), initialStep: 2),
            ),
            (route) => false,
          );
          return;
        } else {
          try {
            await userRepo.completeOnboarding();
          } catch (_) {}

          await localStorage.markOnboardingCompleted();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
          return;
        }
      }

      await localStorage.markOnboardingCompleted();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
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
  void dispose() {
    incomeController.dispose();
    incomeFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    step = widget.initialStep;
    if (step == 0) {
      Future.microtask(() async {
        final storage = LocalStorage();
        final pending = await storage.getPendingOnboardingStep();

        if (pending != null && pending > 0 && mounted) {
          setState(() => step = pending);
          await storage.clearPendingOnboardingStep();
        }
      });
    }
    if (widget.initialStep > 0) {
      Future.microtask(() async {
        final storage = LocalStorage();
        await storage.clearPendingOnboardingStep();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAE6FF), Color(0xFFF6F7FB), Color(0xFFDDE5FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (step > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
              Expanded(
                child: IndexedStack(
                  index: step,
                  children: [_intro(), _login(), _income()],
                ),
              ),
              _stepIndicator(),
              const SizedBox(height: 12),
              if (step == 2) _incomeActionBar(),
              if (step != 2) const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // STEP INDICATOR
  // =====================================================

  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == step;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 20 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF5E5CE6)
                : const Color(0xFF5E5CE6).withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  Widget _intro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
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
        const SizedBox(height: 40),
        const Text(
          "Welcome to Finguard",
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 14),
        const Text(
          "Your Money\nUnder Control.",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Track spending. Detect risky habits.\nBuild financial clarity.",
          style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.6),
        ),
        const SizedBox(height: 80),
        _primaryButton("Get Started", _next),
      ],
    );
  }

  Widget _login() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Center(
            child: Icon(Icons.lock_outline, size: 90, color: Colors.black),
          ),
          const SizedBox(height: 50),
          const Text(
            "Save your progress 🔐",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const Text(
            "Sign in to sync across devices and\nkeep your money data safe.",
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 80),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleGoogleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E5CE6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/image/google_logo.svg", height: 20),
                  const SizedBox(width: 12),
                  Text(
                    isLoading ? "Signing in..." : "Sign in with Google",
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
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Sign in is required to continue",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _income() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Center(
            child: Icon(Icons.trending_up, size: 90, color: Colors.black),
          ),
          const SizedBox(height: 50),
          const Text(
            "Set your monthly income",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 110,
            child: CupertinoPicker(
              itemExtent: 36,
              scrollController: FixedExtentScrollController(
                initialItem: currencies.indexOf(selectedCurrency),
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedCurrency = currencies[index];
                });
              },
              children: currencies
                  .map(
                    (c) => Center(
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Income amount",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        CurrencySymbol.of(
                          selectedCurrency,
                          trailingSpace: false,
                        ),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E5CE6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        focusNode: incomeFocusNode,
                        controller: incomeController,
                        onTap: () {
                          if (incomeController.text == "0") {
                            incomeController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: incomeController.text.length,
                            );
                          }
                        },
                        onChanged: (_) {
                          setState(() {
                            error = null;
                          });
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          ThousandsSeparatorInputFormatter(
                            allowDecimal: true,
                            maxIntegerDigits: 12,
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: null,
              child: const Text(
                "This step is required",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _incomeActionBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
        child: _primaryButton(
          isLoading ? "Processing..." : "Finish",
          _canSubmitIncome ? _finish : null,
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5E5CE6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
