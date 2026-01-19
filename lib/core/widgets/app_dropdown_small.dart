import '../configs/configs.dart';

/// -----------------------------
/// UI Dropdown (With FormField)
/// -----------------------------
class AppDropdownSmall<T> extends FormField<T> {
  AppDropdownSmall({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.initialValue,
    this.validator,
    this.isLabel = false,
    this.isSearch = false,
    this.isEnabled = true,
  }) : super(
    initialValue: initialValue,
    validator: validator,
    builder: (FormFieldState<T> state) {
      /// Convert items to string map
      final Map<String, T> itemMap = {
        for (final item in items) item.toString(): item
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LABEL
          if (!isLabel)
            Row(
              children: [
                Text(
                  label,
                  style: AppTextStyle.labelDropdownTextStyle(
                      state.context),
                ),
                if (isRequired)
                  const Text(
                    " *",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),

          if (!isLabel) const SizedBox(height: 4),

          /// DROPDOWN
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(state.context),
              borderRadius:
              BorderRadius.circular(AppSizes.radius),
              border: Border.all(
                color: state.hasError
                    ? AppColors.error
                    : AppColors.border,
                width: 0.6,
              ),
            ),
            child: isSearch
                ? CustomDropdown.search(
              enabled: isEnabled,
              hintText: hint,
              items: itemMap.keys.toList(),
              onChanged: (value) {
                final selected = itemMap[value];
                state.didChange(selected);
                onChanged(selected);
              },
            )
                : CustomDropdown(
              enabled: isEnabled,
              hintText: hint,
              items: itemMap.keys.toList(),
              onChanged: (value) {
                final selected = itemMap[value];
                state.didChange(selected);
                onChanged(selected);
              },
            ),
          ),

          /// ERROR
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                state.errorText!,
                style: AppTextStyle.errorTextStyle(
                    state.context),
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
  final bool isEnabled;

  final List<T> items;
  final T? initialValue;
  final String? Function(T?)? validator;
  final ValueChanged<T?> onChanged;
}

/// -----------------------------
/// NON-UI SIMPLE DROPDOWN
/// -----------------------------
class AppDropdownNONUI<T> extends StatelessWidget {
  const AppDropdownNONUI({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.label,
    this.isRequired = false,
    this.showLabel = true,
  });

  final T? value;
  final String? hint;
  final String? label;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final bool isRequired;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel && label != null)
          Row(
            children: [
              Text(
                label!,
                style: AppTextStyle.labelDropdownTextStyle(context),
              ),
              if (isRequired)
                const Text(
                  " *",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),

        const SizedBox(height: 4),

        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius:
            BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: AppColors.border,
              width: 0.6,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            hint: hint != null
                ? Text(
              hint!,
              overflow: TextOverflow.ellipsis,
              style:
              AppTextStyle.cardTitle(context)
                  .copyWith(fontSize: 12),
            )
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                value: e,
                child: Text(
                  e.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
