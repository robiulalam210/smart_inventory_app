import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../configs/app_colors.dart';
import '../configs/app_sizes.dart';
import '../configs/app_text.dart';

class CustomDateRangeField extends StatefulWidget {
  final DateRange? selectedDateRange;
  final void Function(DateRange?) onDateRangeSelected;
  final bool isLabel; // New parameter to control label visibility

  const CustomDateRangeField({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
    this.isLabel = true, // Default to true for backward compatibility
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

  @override
  void didUpdateWidget(covariant CustomDateRangeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDateRange != oldWidget.selectedDateRange) {
      setState(() {
        selectedDateRange = widget.selectedDateRange;
      });
    }
  }

  Widget datePickerBuilder(
      BuildContext context, void Function(DateRange?) onDateRangeChanged,
      [bool doubleMonth = true]) {
    return SizedBox(
      height: 320, // Fixed height to prevent overflow
      child: DateRangePickerWidget(
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
        disabledDates: [],
        maxDate: DateTime.now().add(const Duration(days: 365 * 2)),
        initialDisplayedDate: selectedDateRange?.start ?? DateTime.now(),
        onDateRangeChanged: onDateRangeChanged,
        theme: const CalendarTheme(
          selectedColor: Colors.blue,
          dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
          inRangeColor: Color(0xFFD9EDFA),
          inRangeTextStyle: TextStyle(color: Colors.blue),
          selectedTextStyle: TextStyle(color: Colors.white),
          todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
          defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
          radius: 10,
          tileSize: 32, // Reduced tile size for better fit
          disabledTextStyle: TextStyle(color: Colors.grey),
          quickDateRangeBackgroundColor: Colors.white,
          selectedQuickDateRangeColor: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conditionally show the label based on isLabel parameter
        if (widget.isLabel) ...[
          Text("Date Filter", style: AppTextStyle.labelDropdownTextStyle(context)),
          const SizedBox(height: 2),
        ],

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
                  color: AppColors.matteBlack.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
                errorMaxLines: 2,
                suffixIcon: const Icon(Icons.date_range, size: 16), // Smaller icon
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
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
                            : AppColors.matteBlack.withValues(alpha: 0.5),
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85, // Limit to 85% of screen height
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Draggable handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select Date Range',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Single month view for mobile (removed doubleMonth)
                  Expanded( // Use Expanded to take available space
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: datePickerBuilder(context, (range) {
                          tempRange = range;
                        }, false), // Use single month view for mobile
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context, null),
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text("Clear"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context, tempRange),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text("Apply"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}