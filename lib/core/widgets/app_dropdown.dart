import '../configs/configs.dart';

class AppDropdown<T> extends FormField<T> {
  AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    T? value,
    required this.itemList,
    required this.context,
    required this.onChanged,
    this.isOnCreateBtn,
    this.isOnPrefixIconBtn,
    required this.itemBuilder,
    this.isLabel = false,
    this.isCreateBtn = false,
    this.isPrefixIconBtn = false,
    this.isSearch = false,
    this.isNeedAll,
    this.isNeedText,
    super.validator,
  }) : super(
         initialValue: value,
         builder: (FormFieldState<T> state) {
           // Create display list with "All" option if needed
           List<dynamic> displayItems = [...itemList];
           List<String> displayTexts = itemList
               .map((item) => item.toString())
               .toList();

           if (isNeedAll ?? false) {
             displayItems.insert(0, "All");
             displayTexts.insert(0, "All");
           }
           if (isNeedText ?? false) {
             displayItems.insert(0, "Text");
             displayTexts.insert(0, "Text");
           }

           return Container(
             decoration: BoxDecoration(
               color: AppColors.bottomNavBg(context),
               borderRadius: BorderRadius.all(Radius.circular(2)),
             ),
             height: isLabel == true ? 57 : 75,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 if (!isLabel!)
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.center,
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Text(
                         label,
                         style: AppTextStyle.labelDropdownTextStyle(
                           context,
                         ).copyWith(color: AppColors.text(context)),
                       ),
                       const SizedBox(width: 4),
                       if (isRequired)
                         Text(
                           "*",
                           style: AppTextStyle.labelDropdownTextStyle(
                             context,
                           ).copyWith(color: AppColors.error),
                         ),
                     ],
                   ),
                 if (!isLabel) const SizedBox(height: 2),

                 SizedBox(
                   height: 40,
                   child: Container(
                     padding: EdgeInsets.all(5),
                     decoration: BoxDecoration(
                       color: AppColors.bottomNavBg(context),
                       border: Border.all(
                         color: state.hasError
                             ? AppColors.error.withValues(alpha: 0.7)
                             : AppColors.border,
                         width: 0.4,
                       ),
                       borderRadius: BorderRadius.circular(AppSizes.radius),
                     ),
                     child: isSearch == false
                         ? CustomDropdown(
                             closedHeaderPadding: EdgeInsets.only(
                               top: 6,
                               left: 4,
                               right: 4,
                               bottom: 6,
                             ),
                             listItemPadding: EdgeInsets.symmetric(
                               horizontal: 8,
                               vertical: 8,
                             ),
                             
                             itemsListPadding: EdgeInsets.symmetric(
                               horizontal: 8,
                               vertical: 4,
                             ),
                             decoration: CustomDropdownDecoration(
                               expandedFillColor: AppColors.bottomNavBg(context),
                               closedFillColor: AppColors.bottomNavBg(context),
                               expandedBorderRadius: BorderRadius.circular(2),
                               searchFieldDecoration: SearchFieldDecoration(
                                 hintStyle: AppTextStyle.cardLevelHead(
                                   context,
                                 ).copyWith(color: AppColors.text(context)),
                                 textStyle: AppTextStyle.cardLevelText(
                                   context,
                                 ).copyWith(color: AppColors.text(context)),
                               ),
                               listItemStyle: AppTextStyle.cardLevelText(
                                 context,
                               ).copyWith(color: AppColors.text(context)),
                               headerStyle: AppTextStyle.cardLevelText(context),
                               hintStyle: TextStyle(
                                 color: AppColors.text(context),
                                 fontWeight: FontWeight.w300,
                                 fontSize: 14,
                               ),
                             ),
                             hintText: hint,
                             items: displayTexts,
                             // Use display texts for dropdown
                             onChanged: (newValue) {
                               T? selectedItem;

                               if (newValue == "All") {
                                 // Handle "All" selection - return null
                                 selectedItem = null;
                               } else {
                                 // Find the index in display items and get corresponding item
                                 final index = displayTexts.indexOf(newValue!);
                                 if (index != -1) {
                                   final displayItem = displayItems[index];
                                   // If it's a special item ("All", "Text") or actual object
                                   if (displayItem is T) {
                                     selectedItem = displayItem;
                                   } else {
                                     // For special items that aren't type T, return null
                                     selectedItem = null;
                                   }
                                 }
                               }

                               state.didChange(selectedItem);
                               onChanged(selectedItem);
                             },
                           )
                         : CustomDropdown.search(
                             closedHeaderPadding: EdgeInsets.only(
                               top: 6,
                               left: 4,
                               right: 4,
                               bottom: 6,
                             ),

                             closeDropDownOnClearFilterSearch: false,
                             listItemPadding: EdgeInsets.symmetric(
                               horizontal: 4,
                               vertical: 4,
                             ),
                             itemsListPadding: EdgeInsets.symmetric(
                               horizontal: 8,
                               vertical: 4,
                             ),
                             decoration: CustomDropdownDecoration(
                               expandedFillColor: AppColors.bottomNavBg(context),

                               closedFillColor: AppColors.bottomNavBg(context),
                               expandedBorderRadius: BorderRadius.circular(2),
                               searchFieldDecoration: SearchFieldDecoration(
                                 fillColor: AppColors.bottomNavBg(context),

                                 hintStyle: AppTextStyle.cardLevelHead(
                                   context,
                                 ).copyWith(color: AppColors.text(context)),
                                 textStyle: AppTextStyle.cardLevelText(
                                   context,
                                 ).copyWith(color: AppColors.text(context)),
                               ),
                               listItemStyle: AppTextStyle.cardLevelText(
                                 context,
                               ).copyWith(color: AppColors.text(context)),
                               headerStyle: AppTextStyle.cardLevelText(
                                 context,
                               ).copyWith(color: AppColors.text(context)),
                               hintStyle: TextStyle(
                                 color: AppColors.text(context),
                                 fontWeight: FontWeight.w300,
                                 fontSize: 14,
                               ),
                             ),
                             hintText: hint,
                             items: displayTexts,
                             // Use display texts for dropdown
                             onChanged: (newValue) {
                               T? selectedItem;

                               if (newValue == "All") {
                                 // Handle "All" selection - return null
                                 selectedItem = null;
                               } else {
                                 // Find the index in display items and get corresponding item
                                 final index = displayTexts.indexOf(newValue!);
                                 if (index != -1) {
                                   final displayItem = displayItems[index];
                                   // If it's a special item ("All", "Text") or actual object
                                   if (displayItem is T) {
                                     selectedItem = displayItem;
                                   } else {
                                     // For special items that aren't type T, return null
                                     selectedItem = null;
                                   }
                                 }
                               }

                               state.didChange(selectedItem);
                               onChanged(selectedItem);
                             },
                           ),
                   ),
                 ),

                 if (state.hasError)
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 6),
                     child: Text(
                       state.errorText!,
                       style: AppTextStyle.errorTextStyle(context),
                     ),
                   ),
               ],
             ),
           );
         },
       );

  final String label, hint;
  final bool isRequired;
  final bool? isLabel;
  final bool? isCreateBtn;
  final bool? isPrefixIconBtn;
  final bool isSearch;
  final bool? isNeedAll;
  final bool? isNeedText;
  final BuildContext context;
  final List<T> itemList;
  final void Function(T?) onChanged;
  final void Function()? isOnCreateBtn;
  final void Function()? isOnPrefixIconBtn;
  final DropdownMenuItem<T> Function(T item) itemBuilder;
}
