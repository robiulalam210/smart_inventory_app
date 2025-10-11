import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../../core/configs/configs.dart';
import '../../../data/models/inventory_model/inventory_model.dart';
import '../../bloc/lab_billing/lab_billing_bloc.dart';

class InventorySearchField extends StatefulWidget {
  final List<InventoryLocalProduct> inventoryList;
  final LabBillingBloc labBillingBloc;
  final TextEditingController controller;
  final FocusNode focusNode;

  const InventorySearchField({
    super.key,
    required this.inventoryList,
    required this.labBillingBloc,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<InventorySearchField> createState() => _InventorySearchFieldState();
}

class _InventorySearchFieldState extends State<InventorySearchField> {
  late ValueNotifier<bool> showClearButton;

  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.labBillingBloc.selectedInventory?.name ?? '';
    showClearButton = ValueNotifier(widget.controller.text.isNotEmpty);
    widget.controller.addListener(() {
      showClearButton.value = widget.controller.text.isNotEmpty;
    });
  }

  void clearSelection() {
    widget.controller.clear();
    widget.labBillingBloc.selectedInventory = null;
    showClearButton.value = false;
    widget.focusNode.requestFocus();
  }
// Shared method
  void _addInventoryItem(InventoryLocalProduct item) {
    widget.labBillingBloc.add(
      AddTestItem(
        id: item.webId.toString(),
        name: item.name ?? "",
        code: item.itemCode ?? "",
        type: "Inventory",
        price: item.price ?? 0,
        quantity: 1,
        discountApplied: 0,
        discountPercentage: 0.0,
        testGroupName: null,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return TypeAheadField<InventoryLocalProduct>(
      controller: widget.controller,
      focusNode: widget.focusNode,
      debounceDuration: const Duration(milliseconds: 300),
      hideOnError: true,
      hideOnSelect: true,
      hideOnLoading: true,
      suggestionsCallback: (pattern) {
        final query = pattern.toLowerCase().trim();

        final matches = widget.inventoryList.where((item) {
          return item.name.toString().toLowerCase().contains(query);
        }).toList();

        matches.sort((a, b) {
          final aName = a.name.toString().toLowerCase();
          final bName = b.name.toString().toLowerCase();

          final aStartsWith = aName.startsWith(query) ? 0 : 1;
          final bStartsWith = bName.startsWith(query) ? 0 : 1;

          if (aStartsWith == bStartsWith) {
            return aName.compareTo(bName);
          }

          return aStartsWith.compareTo(bStartsWith);
        });

        return matches;
      },

      itemBuilder: (context, item) {
        return      Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSizes.bodyPadding,
              vertical: AppSizes.bodyPadding),
          color: AppColors.white.withValues(alpha: 0.6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.name.toString().capitalize()),
              Text(item.price.toString()),
            ],
          ),
        );
      },
      onSelected: (item) {
        _addInventoryItem(item);
      },

      builder: (context, controller, focusNode) {
        return ValueListenableBuilder<bool>(
          valueListenable: showClearButton,
          builder: (context, isNotEmpty, _) {
            return SizedBox(
              height: 35,
              child: TextFormField(
                onFieldSubmitted: (value) {
                  final query = value.toLowerCase().trim();

                  // Filter inventory list for matching name
                  final matches = widget.inventoryList.where(
                        (item) => item.name.toString().toLowerCase() == query,
                  );

                  if (matches.isNotEmpty) {
                    // Add the first matching item
                    _addInventoryItem(matches.first);

                    // Clear input & unfocus
                    widget.controller.clear();
                    widget.labBillingBloc.selectedInventory = null;
                    widget.focusNode.unfocus();
                  }
                },
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      top: 4.0, bottom: 4.0, left: 6),
                  hintText: 'Search by Inventory',
                  hintStyle: TextStyle(
                    color: AppColors.matteBlack,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                  suffixIcon: isNotEmpty
                      ? InkWell(
                    onTap: clearSelection,
                    child: const Icon(Icons.clear_rounded,
                        size: 16),
                  )
                      : const Icon(Icons.search_rounded, size: 16),
                  errorBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(AppSizes.radius),
                      borderSide: BorderSide(
                          color: AppColors.error, width: 0.7)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(AppSizes.radius),
                      borderSide: BorderSide(
                          color: AppColors.matteBlack, width: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(AppSizes.radius),
                    borderSide: BorderSide(
                        color: AppColors.border, width: 0.7),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(AppSizes.radius),
                    borderSide: BorderSide(
                        color: AppColors.error, width: 0.7),
                  ),
                ),


              ),
            );
          },
        );
      },
      constraints: BoxConstraints(
        maxHeight: 250,
        minWidth: MediaQuery.of(context).size.width * 0.5,
      ),
    );
  }
}
