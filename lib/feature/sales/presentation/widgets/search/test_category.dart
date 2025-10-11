import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '/core/configs/app_sizes.dart';

import '../../../data/models/tests_model/test_categories_model.dart';


class TestCategorySearch extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<TestCategoriesLocalModel?> selectedCategoryNotifier;
  final List<TestCategoriesLocalModel> categories;
  final void Function(TestCategoriesLocalModel? category)? onCategorySelected;

  const TestCategorySearch({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedCategoryNotifier,
    required this.categories,
    this.onCategorySelected,
  });

  @override
  State<TestCategorySearch> createState() => _TestCategorySearchState();
}

class _TestCategorySearchState extends State<TestCategorySearch> {
  late List<TestCategoriesLocalModel> _categoryList;

  @override
  void initState() {
    super.initState();
    final allOption = TestCategoriesLocalModel(name: 'All', orgTestCategoryId: null);
    _categoryList = [allOption, ...widget.categories];
  }

  void _clearSelection() {
    widget.controller.clear();
    widget.selectedCategoryNotifier.value = null;
    widget.focusNode.requestFocus();
    if (widget.onCategorySelected != null) widget.onCategorySelected!(null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TestCategoriesLocalModel?>(
      valueListenable: widget.selectedCategoryNotifier,
      builder: (context, selectedCategory, child) {
        return TypeAheadField<TestCategoriesLocalModel>(
          controller: widget.controller,
          focusNode: widget.focusNode,
          debounceDuration: const Duration(milliseconds: 300),
          direction: VerticalDirection.down,
          hideOnError: true,
          hideOnLoading: true,
          suggestionsCallback: (pattern) {
            final query = pattern.toLowerCase().trim();

            // Filter matches where name contains query (handle null safely)
            final matches = _categoryList.where((test) {
              final name = test.name?.toLowerCase();
              return name != null && name.contains(query);
            }).toList();

            // Sort so that items starting with query come first
            matches.sort((a, b) {
              final aName = a.name?.toLowerCase() ?? '';
              final bName = b.name?.toLowerCase() ?? '';

              final aStartsWith = aName.startsWith(query) ? 0 : 1;
              final bStartsWith = bName.startsWith(query) ? 0 : 1;

              if (aStartsWith == bStartsWith) {
                return aName.compareTo(bName);
              }

              return aStartsWith.compareTo(bStartsWith);
            });

            return matches;
          },

          itemBuilder: (context, category) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                color: Colors.white.withValues(alpha: 0.6),
                child: Text(
                  category.name ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          },
          onSelected: (category) {
            if (category.name == 'All') {
              widget.selectedCategoryNotifier.value = null;
              widget.controller.clear();
              if (widget.onCategorySelected != null) widget.onCategorySelected!(null);
            } else {
              widget.selectedCategoryNotifier.value = category;
              widget.controller.text = category.name ?? '';
              if (widget.onCategorySelected != null) widget.onCategorySelected!(category);
            }
            FocusScope.of(context).unfocus();
            setState(() {});
          },
          builder: (context, controller, focusNode) {
            return SizedBox(
              height: 35,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 4, bottom: 4, left: 6),
                      hintText: 'Search by Category',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                      suffixIcon: value.text.isNotEmpty
                          ? InkWell(
                        onTap: _clearSelection,
                        child: const Icon(Icons.clear_rounded, size: 16),
                      )
                          : const Icon(Icons.search_rounded, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 0.7),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 0.7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        borderSide: BorderSide(color: Colors.black87, width: 0.7),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        borderSide: BorderSide(color: Colors.red.shade700, width: 0.7),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          constraints: BoxConstraints(
            maxHeight: 250,
            minWidth: MediaQuery.of(context).size.width * 0.5,
          ),
        );
      },
    );
  }
}
