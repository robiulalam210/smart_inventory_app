import 'package:flutter/material.dart';
import '../configs/configs.dart';

class AppDropdown<T> extends FormField<T> {
  AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    T? value,
    required this.itemList,
    required this.onChanged,
    this.isSearch = false,
    this.isNeedAll = false,
    this.allItem,
    this.isLabel = true,
    super.validator,
  }) : super(
    initialValue: value,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (FormFieldState<T> state) {
      final context = state.context;
      final TextEditingController controller =
      TextEditingController(text: state.value?.toString() ?? '');

      /// ---------- ITEMS ----------
      final List<T> items = [...itemList];
      if (isNeedAll && allItem != null) {
        items.insert(0, allItem as T);
      }

      // Show dropdown as a bottom sheet
      void _showDropdown() {
        // Unfocus any active focus to prevent keyboard issues
        FocusScope.of(context).unfocus();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          useSafeArea: true,
          builder: (sheetContext) {
            return _DropdownBottomSheet<T>(
              items: items,
              selectedValue: state.value,
              controller: controller,
              hint: hint,
              isSearch: isSearch,
              onChanged: (value) {
                if (value != null) {
                  controller.text = value.toString();
                  state.didChange(value);
                  onChanged(value);
                }
                Navigator.pop(sheetContext);
              },
            );
          },
        );
      }

      void _handleClear() {
        controller.clear();
        state.didChange(null);
        onChanged(null);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- LABEL ----------
          if (isLabel) ...[
            Row(
              children: [
                Text(
                  label,
                  style: AppTextStyle.labelDropdownTextStyle(context),
                ),
                if (isRequired)
                  const Text('*', style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 4),
          ],

          /// ---------- FIELD ----------
          SizedBox(
            height: 55,
            child: InkWell(
              onTap: _showDropdown,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.hasError
                        ? Colors.red
                        : AppColors.greyColor(context),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.text.isEmpty ? hint : controller.text,
                        style: TextStyle(
                          color: controller.text.isEmpty
                              ? AppColors.greyColor(context)
                              : AppColors.text(context),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.text.isNotEmpty)
                          InkWell(
                            onTap: _handleClear,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.greyColor(context),
                              ),
                            ),
                          ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.greyColor(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ---------- ERROR ----------
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6),
              child: Text(
                state.errorText!,
                style: AppTextStyle.errorTextStyle(context),
              ),
            ),
        ],
      );
    },
  );

  final String label;
  final String hint;
  final bool isRequired;
  final bool isLabel;
  final bool isSearch;
  final bool isNeedAll;
  final T? allItem;
  final List<T> itemList;
  final void Function(T?) onChanged;
}

class _DropdownBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final TextEditingController controller;
  final String hint;
  final bool isSearch;
  final ValueChanged<T?> onChanged;

  const _DropdownBottomSheet({
    required this.items,
    required this.selectedValue,
    required this.controller,
    required this.hint,
    required this.isSearch,
    required this.onChanged,
  });

  @override
  State<_DropdownBottomSheet<T>> createState() => _DropdownBottomSheetState<T>();
}

class _DropdownBottomSheetState<T> extends State<_DropdownBottomSheet<T>> {
  late List<T> filteredItems;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController = TextEditingController();

    // If search is enabled, initialize with current value
    if (widget.isSearch && widget.controller.text.isNotEmpty) {
      searchController.text = widget.controller.text;
      _filterItems(widget.controller.text);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where((item) => item.toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration:  BoxDecoration(
            color:AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search field (if enabled)
              if (widget.isSearch)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.hint}',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: _filterItems,
                  ),
                ),

              // Items list
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.greyColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.greyColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isSelected = item == widget.selectedValue;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      elevation: 0,
                      color: isSelected
                          ? AppColors.primaryColor(context).withValues(alpha: 0.1)
                          : AppColors.bottomNavBg(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: isSelected
                            ? Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor(context),
                        )
                            : null,
                        title: Text(
                          item.toString(),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: AppColors.text(context),
                          ),
                        ),
                        onTap: () => widget.onChanged(item),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}