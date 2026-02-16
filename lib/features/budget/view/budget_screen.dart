import 'package:finguard_app/core/app_settings.dart';
import 'package:finguard_app/core/utils/thousand_separator_formatter.dart';
import 'package:finguard_app/features/category/data/model/category_model.dart';
import 'package:finguard_app/features/category/viewmodel/category_viewmodel.dart';
import 'package:finguard_app/features/budget/view/budget_card.dart';
import 'package:finguard_app/features/budget/viewmodel/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      if (!mounted) return;
      context.read<BudgetViewmodel>().loadBudgets();
      context.read<CategoryViewModel>().load();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BudgetViewmodel>().loadMoreBudgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BudgetViewmodel>();
    final settings = context.watch<AppSettings>();
    final categoryVM = context.watch<CategoryViewModel>();
    final expenseCategories =
        categoryVM.categories.where((c) => c.type == "EXPENSE").toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(vm, expenseCategories),
              Expanded(child: _buildBody(vm, settings, expenseCategories)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BudgetViewmodel vm,
    List<CategoryModel> expenseCategories,
  ) {
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);
    final selectedMonth =
        DateTime(vm.selectedMonth.year, vm.selectedMonth.month);
    final isCurrentMonth = selectedMonth.year == nowMonth.year &&
        selectedMonth.month == nowMonth.month;
    final canGoPrev = selectedMonth.isAfter(previousMonth);
    final canGoNext = selectedMonth.isBefore(nowMonth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your monthly spending limits',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: !isCurrentMonth || expenseCategories.isEmpty
                    ? null
                    : () =>
                        _showBudgetForm(expenseCategories: expenseCategories),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text("Add"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: canGoPrev
                      ? () => vm.loadBudgets(
                            month: DateTime(
                              vm.selectedMonth.year,
                              vm.selectedMonth.month - 1,
                            ),
                          )
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _pickMonth,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        DateFormat('yyyy-MM').format(vm.selectedMonth),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: canGoNext
                      ? () => vm.loadBudgets(
                            month: DateTime(
                              vm.selectedMonth.year,
                              vm.selectedMonth.month + 1,
                            ),
                          )
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BudgetViewmodel vm,
    AppSettings settings,
    List<CategoryModel> expenseCategories,
  ) {
    final now = DateTime.now();
    final isCurrentMonth = vm.selectedMonth.year == now.year &&
        vm.selectedMonth.month == now.month;

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Failed to load budgets",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                vm.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.loadBudgets(refresh: true),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.budgets.isEmpty) {
      return const Center(
        child: Text("No budgets set yet", style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadBudgets(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: vm.budgets.length + (vm.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == vm.budgets.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: vm.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }

          final budget = vm.budgets[index];
          final categoryId = budget.categoryId ??
              _resolveCategoryId(
                categoryName: budget.category,
                categories: expenseCategories,
              );

          return BudgetCard(
            budget: budget,
            settings: settings,
            onEdit: !isCurrentMonth || categoryId == null
                ? null
                : () => _showBudgetForm(
                      expenseCategories: expenseCategories,
                      initialCategoryId: categoryId,
                      initialAmount: budget.monthlyLimit,
                    ),
            onDelete: !isCurrentMonth || categoryId == null
                ? null
                : () => _confirmDelete(categoryId: categoryId),
          );
        },
      ),
    );
  }

  int? _resolveCategoryId({
    required String categoryName,
    required List<CategoryModel> categories,
  }) {
    for (final category in categories) {
      if (category.name.toLowerCase() == categoryName.toLowerCase()) {
        return category.id;
      }
    }
    return null;
  }

  Future<void> _pickMonth() async {
    final vm = context.read<BudgetViewmodel>();
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedMonth,
      firstDate: previousMonth,
      lastDate: DateTime(nowMonth.year, nowMonth.month + 1, 0),
      helpText: 'Select Month',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && mounted) {
      final pickedMonth = DateTime(picked.year, picked.month);
      if (pickedMonth.isBefore(previousMonth) ||
          pickedMonth.isAfter(nowMonth)) {
        return;
      }
      await vm.loadBudgets(month: pickedMonth);
    }
  }

  Future<void> _confirmDelete({required int categoryId}) async {
    final vm = context.read<BudgetViewmodel>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Budget"),
        content: const Text("Delete this budget configuration?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await vm.deleteBudget(categoryId: categoryId);
    }
  }

  void _showBudgetForm({
    required List<CategoryModel> expenseCategories,
    int? initialCategoryId,
    double? initialAmount,
  }) {
    final vm = context.read<BudgetViewmodel>();
    final settings = context.read<AppSettings>();
    final amountController = TextEditingController(
      text: initialAmount != null
          ? ThousandsSeparatorInputFormatter.formatAmountFixed(
              initialAmount,
              decimalDigits: 2,
            )
          : "",
    );
    final amountFocusNode = FocusNode();
    int? selectedCategoryId = initialCategoryId;
    final isEditMode = initialCategoryId != null;

    final sheetFuture = showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final cleanAmount = amountController.text.replaceAll(',', '');
          final parsedAmount = double.tryParse(cleanAmount);
          String? selectedCategoryName;
          for (final category in expenseCategories) {
            if (category.id == selectedCategoryId) {
              selectedCategoryName = category.name;
              break;
            }
          }
          final canSubmit = !vm.isSubmitting &&
              selectedCategoryId != null &&
              parsedAmount != null &&
              parsedAmount > 0;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!amountFocusNode.hasFocus) {
              amountFocusNode.requestFocus();
            }
          });

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditMode ? "Edit Budget" : "Add Budget",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                if (isEditMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      selectedCategoryName ?? "Category",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    initialValue: selectedCategoryId,
                    items: expenseCategories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCategoryId = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Category",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  focusNode: amountFocusNode,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setModalState(() {}),
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(
                      allowDecimal: true,
                      maxIntegerDigits: 12,
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: "Monthly limit",
                    prefixText: _currencySymbol(settings.currency),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canSubmit
                        ? () async {
                            await vm.createOrUpdateBudget(
                              categoryId: selectedCategoryId!,
                              monthlyLimit: parsedAmount,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5CE6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: vm.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEditMode ? "Save Changes" : "Create Budget"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    sheetFuture.whenComplete(() {
      amountController.dispose();
      amountFocusNode.dispose();
    });
  }

  String _currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'IDR':
        return 'Rp ';
      case 'USD':
        return '\$ ';
      case 'JPY':
        return '¥ ';
      case 'EUR':
        return '€ ';
      case 'SGD':
        return 'S\$ ';
      default:
        return '${code.toUpperCase()} ';
    }
  }
}
