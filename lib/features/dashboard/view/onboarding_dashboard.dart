import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/storage/local_storage.dart';
import 'package:finguard_app/core/utils/thousand_separator_formatter.dart';
import 'package:finguard_app/features/transaction/data/enum/transaction_type_enum.dart';
import 'package:finguard_app/features/transaction/data/model/create_transaction_request.dart';
import 'package:finguard_app/features/transaction/viewmodel/transaction_viewmodel.dart';
import 'package:finguard_app/features/user/data/user_repository.dart';
import 'package:finguard_app/main_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int step = 0;
  bool isLoading = false;
  String? error;

  final TextEditingController incomeController = TextEditingController(
    text: "0",
  );
  final FocusNode incomeFocusNode = FocusNode();

  String selectedCurrency = "USD";

  final List<String> currencies = ["USD", "EUR", "JPY", "SGD", "IDR"];

  final Map<String, String> currencySymbols = {
    "USD": "\$",
    "IDR": "Rp",
    "JPY": "¥",
    "EUR": "€",
    "SGD": "S\$",
  };

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
      debugPrint("Onboarding finish error: $e");
    }
  }

  @override
  void dispose() {
    incomeController.dispose();
    incomeFocusNode.dispose();
    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

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
              const SizedBox(height: 24),
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

  // =====================================================
  // STEP 1
  // =====================================================

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

  // =====================================================
  // STEP 2
  // =====================================================

  Widget _login() {
    return Column(
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
            onPressed: () {},
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
                const Text(
                  "Sign in with Google",
                  style: TextStyle(
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
          child: GestureDetector(
            onTap: _next,
            child: const Text(
              "Continue as guest",
              style: TextStyle(
                color: Colors.black54,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // STEP 3
  // =====================================================

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
                        currencySymbols[selectedCurrency] ?? "",
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
          const SizedBox(height: 60),
          _primaryButton(
            isLoading ? "Processing..." : "Finish",
            _canSubmitIncome ? _finish : null,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: isLoading ? null : _skipOnboarding,
              child: const Text(
                "Skip this step",
                style: TextStyle(
                  color: Colors.black54,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _skipOnboarding() async {
    final settings = context.read<AppSettings>();
    final storage = LocalStorage();
    final userRepo = context.read<UserRepository>();

    await storage.saveCurrency(selectedCurrency);
    await storage.markOnboardingCompleted();
    settings.setCurrency(selectedCurrency);
    try {
      await userRepo.updatePreferences(
        selectedCurrency,
        settings.locale.languageCode,
      );
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
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
