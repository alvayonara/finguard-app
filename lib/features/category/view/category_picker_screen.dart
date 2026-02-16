import 'package:finguard_app/core/utils/category_icon_mapper.dart';
import 'package:finguard_app/features/category/data/category_repository.dart';
import 'package:finguard_app/features/category/data/model/category_model.dart';
import 'package:finguard_app/features/category/viewmodel/category_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPickerScreen extends StatefulWidget {
  final String title;
  final String categoryType;
  final int? selectedCategoryId;

  const CategoryPickerScreen({
    super.key,
    required this.title,
    required this.categoryType,
    this.selectedCategoryId,
  });

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().load();
    });
  }

  void _reloadCategories() {
    context.read<CategoryViewModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<CategoryViewModel>();
    final categories = categoryVM.categories
        .where((c) => c.type == widget.categoryType)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreateCategoryDialog(context, categoryVM),
            tooltip: 'Create Category',
          ),
        ],
      ),
      body: categoryVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              itemCount: categories.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category.id == widget.selectedCategoryId;

          return InkWell(
            onTap: () => Navigator.of(context).pop(category),
            onLongPress: category.isDefault
                ? null
                : () => _showCategoryOptions(context, category),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5E5CE6)
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E5CE6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        CategoryIconMapper.getIcon(category.icon),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (!category.isDefault)
                    Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  if (category.isDefault && isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF5E5CE6),
                    ),
                  if (!category.isDefault && isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF5E5CE6),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryOptions(BuildContext context, CategoryModel category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF5E5CE6)),
              title: const Text(
                'Edit Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEditCategoryDialog(context, category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Category',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteCategory(context, category);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    String? selectedEmoji = category.icon;
    final availableEmojis = CategoryIconMapper.emojisByType(category.type);
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Edit Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Error Message
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => setModalState(() => errorMessage = null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Name Input
                    TextField(
                      controller: nameController,
                      enabled: !isLoading,
                      autofocus: false,
                      onChanged: (_) {
                        if (errorMessage != null) {
                          setModalState(() => errorMessage = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Category Name",
                        hintText: "e.g., Groceries",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF5E5CE6),
                            width: 2,
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 24),

                    // Emoji Selector
                    Text(
                      "Select Icon",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: availableEmojis.length,
                      itemBuilder: (context, index) {
                        final emoji = availableEmojis[index];
                        final isEmojiSelected = selectedEmoji == emoji;

                        return GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  setModalState(() => selectedEmoji = emoji);
                                  if (errorMessage != null) {
                                    setModalState(() => errorMessage = null);
                                  }
                                },
                          child: Opacity(
                            opacity: isLoading ? 0.5 : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isEmojiSelected
                                    ? const Color(0xFF5E5CE6).withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isEmojiSelected
                                      ? const Color(0xFF5E5CE6)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Submit Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) {
                              setModalState(() {
                                errorMessage = "Please enter a category name";
                              });
                              return;
                            }

                            if (selectedEmoji == null) {
                              setModalState(() {
                                errorMessage = "Please select an icon";
                              });
                              return;
                            }

                            setModalState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            try {
                              final vm = context.read<CategoryViewModel>();
                              await vm.updateCategory(
                                id: category.id,
                                name: nameController.text.trim(),
                                type: category.type,
                                icon: selectedEmoji!,
                                color: category.color,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                _reloadCategories();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Category updated successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() {
                                isLoading = false;
                                errorMessage = _formatErrorMessage(e);
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5CE6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Update Category",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final vm = context.read<CategoryViewModel>();
                await vm.deleteCategory(category.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  _reloadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_formatErrorMessage(e)),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context, CategoryViewModel categoryVM) {
    final nameController = TextEditingController();
    String? selectedEmoji;
    final availableEmojis = CategoryIconMapper.emojisByType(widget.categoryType);
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Add Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Error Message
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => setModalState(() => errorMessage = null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Name Input
                    TextField(
                      controller: nameController,
                      enabled: !isLoading,
                      autofocus: false,
                      onChanged: (_) {
                        if (errorMessage != null) {
                          setModalState(() => errorMessage = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Category Name",
                        hintText: "e.g., Groceries",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF5E5CE6),
                            width: 2,
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 24),

                    // Emoji Selector
                    Text(
                      "Select Icon",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: availableEmojis.length,
                      itemBuilder: (context, index) {
                        final emoji = availableEmojis[index];
                        final isEmojiSelected = selectedEmoji == emoji;

                        return GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  setModalState(() => selectedEmoji = emoji);
                                  if (errorMessage != null) {
                                    setModalState(() => errorMessage = null);
                                  }
                                },
                          child: Opacity(
                            opacity: isLoading ? 0.5 : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isEmojiSelected
                                    ? const Color(0xFF5E5CE6).withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isEmojiSelected
                                      ? const Color(0xFF5E5CE6)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Submit Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) {
                              setModalState(() {
                                errorMessage = "Please enter a category name";
                              });
                              return;
                            }

                            if (selectedEmoji == null) {
                              setModalState(() {
                                errorMessage = "Please select an icon";
                              });
                              return;
                            }

                            setModalState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            try {
                              await categoryVM.createCategory(
                                name: nameController.text.trim(),
                                type: widget.categoryType,
                                icon: selectedEmoji!,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                _reloadCategories();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Category created successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() {
                                isLoading = false;
                                errorMessage = _formatErrorMessage(e);
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5CE6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Create Category",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatErrorMessage(Object error) {
    if (error is DuplicateCategoryException) {
      return error.toString();
    }
    if (error is CategoryNotFoundException) {
      return error.toString();
    }
    final errorStr = error.toString();
    final cleanError = errorStr.replaceFirst('Exception: ', '');
    return cleanError.isEmpty ? 'An error occurred' : cleanError;
  }
}
