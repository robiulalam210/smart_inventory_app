import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../configs/app_colors.dart';
import '../configs/app_sizes.dart';
import '../configs/app_text.dart';

class CustomDateRangeField extends StatefulWidget {
  final DateRange? selectedDateRange;
  final void Function(DateRange?) onDateRangeSelected;

  const CustomDateRangeField({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
  });

  @override
  State<CustomDateRangeField> createState() => _CustomDateRangeFieldState();
}

class _CustomDateRangeFieldState extends State<CustomDateRangeField> {
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    selectedDateRange = widget.selectedDateRange;
  }

  Widget datePickerBuilder(
      BuildContext context, void Function(DateRange?) onDateRangeChanged,
      [bool doubleMonth = true]) {
    return DateRangePickerWidget(
      firstDayOfWeek: 1,
      doubleMonth: doubleMonth,
      maximumDateRangeLength: 10,
      quickDateRanges: [
        QuickDateRange(dateRange: null, label: "Remove date range"),
        QuickDateRange(
          label: 'Last 3 days',
          dateRange: DateRange(
            DateTime.now().subtract(const Duration(days: 3)),
            DateTime.now(),
          ),
        ),
        QuickDateRange(
          label: 'Last 7 days',
          dateRange: DateRange(
            DateTime.now().subtract(const Duration(days: 7)),
            DateTime.now(),
          ),
        ),
        QuickDateRange(
          label: 'Last 30 days',
          dateRange: DateRange(
            DateTime.now().subtract(const Duration(days: 30)),
            DateTime.now(),
          ),
        ),
        QuickDateRange(
          label: 'Last 3 Months',
          dateRange: DateRange(
            DateTime.now().subtract(const Duration(days: 90)),
            DateTime.now(),
          ),
        ),
        QuickDateRange(
          label: 'Last 6 Months',
          dateRange: DateRange(
            DateTime.now().subtract(const Duration(days: 180)),
            DateTime.now(),
          ),
        ),
        QuickDateRange(
          label: 'Last 1 Year',
          dateRange: DateRange(
            DateTime.now().subtract(const Duration(days: 365)),
            DateTime.now(),
          ),
        ),
      ],
      minimumDateRangeLength: 3,
      initialDateRange: selectedDateRange,
      disabledDates: [
        // Example disabled dates, change or remove as needed:
        // DateTime.now().subtract(const Duration(days: 5)),
        // DateTime.now().subtract(const Duration(days: 10)),
      ],
      maxDate: DateTime.now().add(const Duration(days: 365*2)),
      initialDisplayedDate: selectedDateRange?.start ?? DateTime.now(),
      onDateRangeChanged: onDateRangeChanged,
      // height: 350,
      theme: const CalendarTheme(
        selectedColor: Colors.blue,
        dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
        inRangeColor: Color(0xFFD9EDFA),
        inRangeTextStyle: TextStyle(color: Colors.blue),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
        defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
        radius: 10,
        tileSize: 40,
        disabledTextStyle: TextStyle(color: Colors.grey),
        quickDateRangeBackgroundColor: Colors.white,
        selectedQuickDateRangeColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date Filter", style: AppTextStyle.labelDropdownTextStyle(context)),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () async {
            final result = await _showCustomDateRangePicker(context);
            if (result != null) {
              setState(() {
                selectedDateRange = result;
              });
              widget.onDateRangeSelected(result);
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 35, // Small compact height
              minHeight: 30,
            ),
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Please select a start end date',
                hintStyle: TextStyle(
                  color: AppColors.matteBlack.withOpacity(0.5),
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
                errorMaxLines: 2,
                suffixIcon: const Icon(Icons.date_range, size: 18), // Smaller icon
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8, // Reduced vertical padding
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  borderSide: BorderSide(color: AppColors.matteBlack),
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDateRange != null
                          ? '${selectedDateRange!.start.toString().split(' ')[0]} → ${selectedDateRange!.end.toString().split(' ')[0]}'
                          : 'Please select a start end date',
                      style: TextStyle(
                        color: selectedDateRange != null
                            ? AppColors.matteBlack
                            : AppColors.matteBlack.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<DateRange?> _showCustomDateRangePicker(BuildContext context) async {
    DateRange? tempRange = selectedDateRange;

    return showModalBottomSheet<DateRange>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 800),
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Select Date Range',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                        ),
                        child: datePickerBuilder(context, (range) {
                          tempRange = range;
                        }),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.redAccent),
                          ),
                          onPressed: () => Navigator.pop(context, null),
                          icon: const Icon(Icons.clear),
                          label: const Text("Clear"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context, tempRange),
                          icon: const Icon(Icons.check),
                          label: const Text("Apply"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}