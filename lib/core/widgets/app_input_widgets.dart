import 'package:phone_form_field/phone_form_field.dart';

import '../core.dart';

class AppPhoneFormField extends StatelessWidget {
  const AppPhoneFormField({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
    required this.labelText,
    this.focusNode,
  });

  final PhoneController? controller;
  final dynamic Function(PhoneNumber)? onChanged;
  final String? Function(PhoneNumber?)? validator;
  final String labelText;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 60, // Adjust max height as needed
        minHeight: 36, // Adjust max height as needed
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                labelText,
                style: AppTextStyle.labelDropdownTextStyle(context),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                "*",
                style: AppTextStyle.errorTextStyle(context),
              )
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          PhoneFormField(
            focusNode: focusNode,  shouldLimitLengthByCountry: true, // Enable country-based length limits

            style: AppTextStyle.cardLevelText(context),
            strutStyle: StrutStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            countryButtonStyle: CountryButtonStyle(
                textStyle: AppTextStyle.cardLevelText(context),
                showFlag: false,
                showDialCode: true,
                showIsoCode: false),
            controller: controller ??
                PhoneController(
                  initialValue: const PhoneNumber(
                    isoCode: IsoCode.BD,
                    nsn: '',
                  ),
                ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            scrollPadding: EdgeInsets.zero,
            enableSuggestions: false,
            onChanged: onChanged,
            // validator: (number) {
            //   print("Validating: $number");
            //
            //   if (number == null) {
            //     return 'Phone number is required';
            //   }
            //
            //   if (number.countryCode == null ||
            //       number.countryCode.toString().isEmpty) {
            //     return 'Select a country code';
            //   }
            //
            //   if (number.nsn.isEmpty || number.nsn.length < 6) {
            //     return 'Enter a valid phone number';
            //   }
            //
            //   return null;
            // },
            cursorColor: AppColors.primaryColor(context),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "phone number",
              hintStyle: TextStyle(
                color:  AppColors.text(context),
                fontWeight: FontWeight.w300,
                fontSize: 12,
              ),
              isDense: true,
              constraints: BoxConstraints(
                maxHeight: 36, // Adjust max height as needed
                minHeight: 36, // Adjust max height as needed
              ),
              maintainHintSize: true,
              contentPadding: EdgeInsets.zero,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide: BorderSide(color: AppColors.error),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide: BorderSide(color:  AppColors.text(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
                borderSide: BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<DateTimeRange?> appDateRangePicker(
  BuildContext context, {
  DateTime? firstDate,
  DateTime? lastDate,
  DateTimeRange? initialDateRange,
}) async {
  final now = DateTime.now();
  firstDate ??= now.subtract(const Duration(days: 360 * 90));
  lastDate ??= now.add(const Duration(days: 365 * 20));

  // Provide a default initial range if not set
  initialDateRange ??= DateTimeRange(
    start: now,
    end: now.add(const Duration(days: 7)),
  );

  // Adjust initialDateRange to stay within bounds
  if (initialDateRange.start.isBefore(firstDate)) {
    initialDateRange = DateTimeRange(
      start: firstDate,
      end: firstDate.add(const Duration(days: 7)),
    );
  } else if (initialDateRange.end.isAfter(lastDate)) {
    initialDateRange = DateTimeRange(
      start: lastDate.subtract(const Duration(days: 7)),
      end: lastDate,
    );
  }

  final pickedRange = await showDateRangePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
  );

  // Only return if user selects a range; otherwise null
  return pickedRange;
}

Future<void> appBottomSheet(BuildContext context,
    {required Widget child}) async {
  await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => Container(
          margin: EdgeInsets.only(
            left: AppSizes.bodyPadding,
            bottom: AppSizes.bodyPadding,
            right: AppSizes.bodyPadding,
          ),
          decoration: BoxDecoration(
              color: AppColors.scaffoldBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppSizes.radius)),
          child: child));
}

Future<XFile?> appImagePicker(BuildContext context) async {
  XFile? photo;
  final ImagePicker picker = ImagePicker();
  await showModalBottomSheet(
    showDragHandle: true,
    context: context,
    builder: (_) => Container(
      padding: const EdgeInsets.all(AppSizes.paddingInside),
      margin: const EdgeInsets.only(
        left: AppSizes.bodyPadding,
        bottom: AppSizes.bodyPadding,
        right: AppSizes.bodyPadding,
      ),
      decoration: BoxDecoration(
          color: AppColors.scaffoldBackgroundColor(context),
          borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Wrap(
        spacing: 15,
        children: [
          ListTile(
            onTap: () async {
              await picker.pickImage(source: ImageSource.gallery).then((value) {
                if (value != null) {
                  photo = value;
                }
                if (context.mounted) {
                  Navigator.pop(context, photo);
                }
              });
            },
            leading: HugeIcon(
                icon: HugeIcons.strokeRoundedImage02,
                color: AppColors.onSurface(context)),
            title: const Text(
              "From Gallery",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(
            thickness: 0.5,
          ),
          ListTile(
            onTap: () async {
              await picker.pickImage(source: ImageSource.camera).then((value) {
                if (value != null) {
                  photo = value;
                }
                if (context.mounted) {
                  Navigator.pop(context, photo);
                }
              });
            },
            leading: HugeIcon(
                icon: HugeIcons.strokeRoundedCamera01,
                color: AppColors.onSurface(context)),
            title: const Text("Take a Picture",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );

  return photo;
}

class AppSheetInput<T> extends FormField<T> {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) getLabel;
  final String hint;
  final String label;
  final bool isSearchable;
  final double? height;
  final bool readOnly;

  AppSheetInput({
    this.readOnly = false,
    super.key,
    required this.items,
    this.height,
    required this.selectedItem,
    super.initialValue,
    required this.getLabel,
    required void Function(T?) onChanged,
    this.isSearchable = false,
    required this.hint,
    required this.label,
    super.validator,
    bool autovalidateMode = false,
  }) : super(
          autovalidateMode: autovalidateMode
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          builder: (FormFieldState<T> state) {
            return _AppSheetContent<T>(
              label: label,
              items: items,
              height: height,
              selectedItem: selectedItem,
              getLabel: getLabel,
              onChanged: (T? value) {
                state.didChange(value);
                onChanged(value);
              },
              hint: hint,
              isSearchable: isSearchable,
              errorText: state.errorText,
              state: state,
              readOnly: readOnly,
            );
          },
        );
}

class _AppSheetContent<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final String hint;
  final String label;
  final bool isSearchable;
  final bool readOnly;
  final String? errorText;
  final double? height;
  final FormFieldState<T> state;

  const _AppSheetContent({
    required this.items,
    required this.height,
    required this.selectedItem,
    required this.getLabel,
    required this.onChanged,
    required this.hint,
    required this.label,
    required this.readOnly,
    required this.isSearchable,
    required this.errorText,
    required this.state,
  });

  @override
  State<_AppSheetContent<T>> createState() => _AppSheetContentState<T>();
}

class _AppSheetContentState<T> extends State<_AppSheetContent<T>> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<T>> _filteredItems = ValueNotifier<List<T>>([]);

  @override
  void initState() {
    super.initState();
    _filteredItems.value = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AppSheetContent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems.value = widget.items;
    }
  }

  void _showDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: widget.height,
              margin: const EdgeInsets.only(
                left: AppSizes.bodyPadding,
                bottom: AppSizes.bodyPadding,
                right: AppSizes.bodyPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.onPrimary(context),
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isSearchable) ...[
                    const SizedBox(height: AppSizes.paddingInside),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.bodyPadding),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search...",
                          fillColor: AppColors.onInverseSurface(context),
                          prefixIcon: HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            color: AppColors.outline(context),
                            size: 20,
                          ),
                        ),
                        onChanged: (value) {
                          _filteredItems.value = widget.items
                              .where((item) => widget
                                  .getLabel(item)
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        },
                      ),
                    ),
                  ],
                  Expanded(child: _buildListView()),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _searchController.clear();
      _filteredItems.value = widget.items;
    });
  }

  Widget _buildListView() {
    return ValueListenableBuilder<List<T>>(
      valueListenable: _filteredItems,
      builder: (context, filteredItems, _) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isSelected = widget.selectedItem == item;
            return ListTile(
              title: Text(
                widget.getLabel(item),
                style: TextStyle(
                  color: isSelected ? AppColors.primaryColor(context) : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: isSelected
                  ? Icon(Icons.check, color: AppColors.primaryColor(context))
                  : const SizedBox(width: 24),
              onTap: () {
                widget.onChanged(item);
                Navigator.pop(context);
                _searchController.clear();
                _filteredItems.value = widget.items;
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.readOnly ? null : _showDropdown,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingInside + 1),
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.focusColor(context),
                        width: AppSizes.boarderWidth),
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    color: widget.readOnly
                        ? AppColors.onInverseSurface(context)
                        : null),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.selectedItem != null
                            ? widget.getLabel(widget.selectedItem as T)
                            : widget.hint,
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.selectedItem != null
                              ? AppColors.onSurface(context)
                              : AppColors.disabledColor(context),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 15,
                      color: AppColors.outline(context),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -2,
                left: 10,
                child: Text(
                  " ${widget.label} ",
                  style: AppSizes.xSmallLight(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

PhoneController? phoneCountryController(
  String? raw, {
  IsoCode defaultCountry = IsoCode.BD, // 🇧🇩 change if needed
}) {
  if (raw == null || raw.trim().isEmpty) return null;

  String cleaned = raw.trim();

  // 1️⃣ convert `00‍...` → `+‍...`
  if (cleaned.startsWith('00')) {
    cleaned = '+${cleaned.substring(2)}';
  }

  // 2️⃣ if still no '+' assume default country dial-code
  if (!cleaned.startsWith('+')) {
    cleaned = _applyDefaultDialCode(cleaned, defaultCountry);
  }

  try {
    final parsed = PhoneNumber.parse(cleaned); // ✅ current API
    return PhoneController(initialValue: parsed);
  } catch (e) {
    debugPrint('Phone parsing failed for "$raw": $e');
    return null;
  }
}

/// Converts a local number (possibly starting with 0) to
String _applyDefaultDialCode(String number, IsoCode iso) {
  // strip a single leading 0 (common local format)
  if (number.startsWith('0')) number = number.substring(1);

  const dialCodes = {
    IsoCode.BD: '880', // Bangladesh
    IsoCode.AU: '61', // Australia
    IsoCode.US: '1', // United States
    IsoCode.IN: '91', // India
    IsoCode.PK: '92', // Pakistan
    IsoCode.MY: '60', // Malaysia
  };

  final dial = dialCodes[iso] ?? '880'; // fallback to BD
  return '+$dial$number';
}

