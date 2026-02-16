import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/utils/thousand_separator_formatter.dart';
import 'package:finguard_app/core/utils/currency_formatter.dart';
import 'package:finguard_app/features/category/viewmodel/category_viewmodel.dart';
import 'package:finguard_app/features/transaction/data/model/transaction_model.dart';
import 'package:finguard_app/features/transaction/data/model/update_transaction_request.dart';
import 'package:finguard_app/features/transaction/viewmodel/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = ModalRoute.of(context)!.settings.arguments as TransactionModel;

    final settings = context.watch<AppSettings>();

    final formatted = CurrencyFormatter.format(
      amount: tx.amount,
      currencyCode: settings.currency,
      locale: settings.locale.languageCode,
    );

    final isExpense = tx.type == "EXPENSE";

    HapticFeedback.lightImpact();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0xFFF5F6FA),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: const Color(0xFFF5F6FA),
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(),
          title: const Text(
            "Transaction",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            _buildAmountHero(formatted, isExpense, tx.categoryName),
            const SizedBox(height: 28),
            _buildInfoCard(tx),
            const SizedBox(height: 28),
            _buildActionButtons(context, tx),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHero(String formatted, bool isExpense, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(
            "${isExpense ? '-' : '+'} $formatted",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(category, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(TransactionModel tx) {
    final isExpense = tx.type == "EXPENSE";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          _infoRow("Category", tx.categoryName),
          _divider(),
          _infoRow("Type", isExpense ? "Expense" : "Income"),
          _divider(),
          _infoRow("Date", tx.occurredAt),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 0.6, color: Colors.grey.withOpacity(0.12));

  Widget _buildActionButtons(BuildContext context, TransactionModel tx) {
    final vm = context.watch<TransactionViewModel>();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showEditBottomSheet(context, tx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E5CE6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("Edit"),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: vm.isLoading
                ? null
                : () async {
                    final confirmed = await _showDeleteConfirmation(context);
                    if (confirmed == true && context.mounted) {
                      await vm.deleteTransaction(tx.id);
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5E5CE6),
              side: const BorderSide(color: Color(0xFF5E5CE6)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("Delete"),
          ),
        ),
      ],
    );
  }

  void _showEditBottomSheet(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditTransactionForm(tx: tx),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EditTransactionForm extends StatefulWidget {
  final TransactionModel tx;

  const _EditTransactionForm({required this.tx});

  @override
  State<_EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<_EditTransactionForm> {
  late TextEditingController amountController;
  late FocusNode amountFocusNode;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: ThousandsSeparatorInputFormatter.formatAmountFixed(
        widget.tx.amount,
        decimalDigits: 2,
      ),
    );
    amountFocusNode = FocusNode();

    selectedCategoryId = widget.tx.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().load();
      amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txVM = context.watch<TransactionViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();

    final categories = categoryVM.categories
        .where((c) => c.type == widget.tx.type)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Edit Transaction",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          /// AMOUNT
          TextField(
            controller: amountController,
            focusNode: amountFocusNode,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              ThousandsSeparatorInputFormatter(
                allowDecimal: true,
                maxIntegerDigits: 12,
              ),
            ],
            decoration: InputDecoration(
              labelText: "Amount",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// CATEGORY
          if (categoryVM.isLoading)
            const CircularProgressIndicator()
          else
            DropdownButtonFormField<int>(
              value: categories.any((c) => c.id == selectedCategoryId)
                  ? selectedCategoryId
                  : null,
              decoration: InputDecoration(
                labelText: "Category",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              items: categories
                  .map(
                    (c) =>
                        DropdownMenuItem<int>(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

          const SizedBox(height: 28),

          /// SAVE
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: txVM.isLoading
                  ? null
                  : () async {
                      final cleanAmount = amountController.text.replaceAll(
                        ',',
                        '',
                      );
                      final parsedAmount = double.tryParse(cleanAmount);
                      if (parsedAmount == null || parsedAmount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a valid amount"),
                          ),
                        );
                        return;
                      }

                      final request = UpdateTransactionRequest(
                        type: widget.tx.type,
                        amount: parsedAmount,
                        categoryId: selectedCategoryId!,
                        occurredAt: widget.tx.occurredAt,
                      );

                      await txVM.updateTransaction(
                        id: widget.tx.id,
                        request: request,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E5CE6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: txVM.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
