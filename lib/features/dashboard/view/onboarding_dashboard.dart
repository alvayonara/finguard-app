import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/storage/local_storage.dart';
import 'package:finguard_app/features/transaction/data/enum/transaction_type_enum.dart';
import 'package:finguard_app/features/transaction/data/model/create_transaction_request.dart';
import 'package:finguard_app/features/transaction/viewmodel/transaction_viewmodel.dart';
import 'package:finguard_app/main_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int step = 0;
  bool isLoading = false;
  String? error;

  final TextEditingController incomeController = TextEditingController();
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
    final income = double.tryParse(incomeController.text);

    if (income == null || income <= 0) {
      setState(() => error = "Income can't be empty");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final txVM = context.read<TransactionViewModel>();
    final settings = context.read<AppSettings>();
    final storage = LocalStorage();

    await txVM.createTransaction(
      request: CreateTransactionRequest(
        type: TransactionTypeEnum.INCOME.name,
        amount: income,
        categoryId: 1,
        occurredAt: DateTime.now().toIso8601String(),
      ),
    );

    await storage.saveCurrency(selectedCurrency);
    await storage.markOnboardingCompleted();
    settings.setCurrency(selectedCurrency);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _buildStep(),
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

  Widget _buildStep() {
    switch (step) {
      case 0:
        return _intro();
      case 1:
        return _login();
      default:
        return _income();
    }
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
            color: isActive ? Colors.black : Colors.black26,
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
      key: const ValueKey(0),
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
      key: const ValueKey(1),
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
              backgroundColor: Colors.black,
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
      key: const ValueKey(2),
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
                  .map((c) => Center(
                        child: Text(
                          c,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            focusNode: incomeFocusNode,
            controller: incomeController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: "${currencySymbols[selectedCurrency]} ",
              labelText: "Income amount",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 60),

          _primaryButton(
            isLoading ? "Processing..." : "Finish",
            isLoading ? null : _finish,
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
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