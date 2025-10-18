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
            // Add "All" and "Text" options if needed
            List<T> modifiedItemList = [...itemList];
            if (isNeedAll ?? false) {
              modifiedItemList.insert(0, "All" as T);
            }
            if (isNeedText ?? false) {
              modifiedItemList.insert(0, "Text" as T);
            }

            return Container(
              // padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(2))
              ),
           
              height:
                  isLabel == true ? 50 : 70, // ✅ Fixed height for the dropdown
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isLabel!) // ✅ Only show label if enabled

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyle.labelDropdownTextStyle(context),
                        ),
                        const SizedBox(width: 4),
                        if (isRequired) // ✅ Only show * if required
                          Text(
                            "*",
                            style: AppTextStyle.labelDropdownTextStyle(context)
                                .copyWith(color: AppColors.error),
                          ),
                      ],
                    ),
                  if (!isLabel) const SizedBox(height: 2),

                  // Dropdown with fixed height
                  SizedBox(

                     height: 30,
                      child: Container(
                    padding: EdgeInsets.all(5), // 👈 Removed extra padding
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
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
                                top: 6, left: 8, right: 6, bottom: 6),
                            listItemPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            itemsListPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: CustomDropdownDecoration(
                              closedFillColor: AppColors.whiteColor,
                              expandedBorderRadius: BorderRadius.circular(2),
                              searchFieldDecoration: SearchFieldDecoration(
                                hintStyle: AppTextStyle.cardLevelHead(context),
                                textStyle: AppTextStyle.cardLevelText(context),
                                // contentPadding: EdgeInsets.zero
                              ),
                              listItemStyle:
                                  AppTextStyle.cardLevelText(context),
                              headerStyle: AppTextStyle.cardLevelText(context),
                              hintStyle: TextStyle(
                                color: AppColors.matteBlack,
                                fontWeight: FontWeight.w300,
                                fontSize: 14,
                              ),
                            ),
                            hintText: hint,
                            items: modifiedItemList
                                .map((item) => item.toString())
                                .toList(),
                            onChanged: (newValue) {
                              final selectedItem = modifiedItemList.firstWhere(
                                  (item) => item.toString() == newValue);
                              state.didChange(selectedItem);
                              onChanged(selectedItem);
                            },
                          )
                        : CustomDropdown.search(
                            closedHeaderPadding: EdgeInsets.only(
                                top: 6, left: 8, right: 6, bottom: 6),
                            closeDropDownOnClearFilterSearch: false,
                            // expandedHeaderPadding: EdgeInsets.zero,

                            listItemPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),

                            itemsListPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: CustomDropdownDecoration(
                              closedFillColor: AppColors.whiteColor,
                              expandedBorderRadius: BorderRadius.circular(2),
                              searchFieldDecoration: SearchFieldDecoration(
                                hintStyle: AppTextStyle.cardLevelHead(context),
                                textStyle: AppTextStyle.cardLevelText(context),
                                // contentPadding: EdgeInsets.zero
                              ),
                              listItemStyle:
                                  AppTextStyle.cardLevelText(context),
                              headerStyle: AppTextStyle.cardLevelText(context),
                              hintStyle: TextStyle(
                                color: AppColors.matteBlack,
                                fontWeight: FontWeight.w300,
                                fontSize: 14,
                              ),
                            ),
                            hintText: hint,
                            items: modifiedItemList
                                .map((item) => item.toString())
                                .toList(),
                            onChanged: (newValue) {
                              final selectedItem = modifiedItemList.firstWhere(
                                  (item) => item.toString() == newValue);
                              state.didChange(selectedItem);
                              onChanged(selectedItem);
                            },
                          ),
                  )),

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
