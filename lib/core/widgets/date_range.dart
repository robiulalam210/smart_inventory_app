import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../configs/app_colors.dart';
import '../configs/app_sizes.dart';
import '../configs/app_text.dart';

class CustomDateRangeField extends StatefulWidget {
  final DateRange? selectedDateRange;
  final void Function(DateRange?) onDateRangeSelected;
  final bool isLabel;

  const CustomDateRangeField({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
    this.isLabel = true,
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
      selectedDateRange = widget.selectedDateRange;
    }
  }

  Widget _datePicker(
      BuildContext context,
      void Function(DateRange?) onDateRangeChanged,
      ) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;

    return SizedBox(
      height: 320,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: DateRangePickerWidget(
              firstDayOfWeek: 1,
              doubleMonth: false,
              minimumDateRangeLength: 3,
              maximumDateRangeLength: 10,
              initialDateRange: selectedDateRange,
              initialDisplayedDate:
              selectedDateRange?.start ?? DateTime.now(),
              maxDate:
              DateTime.now().add(const Duration(days: 365 * 2)),
              disabledDates: const [],
              onDateRangeChanged: onDateRangeChanged,

              /// Disable quick ranges on small screens
              quickDateRanges: isSmallScreen
                  ? const []
                  :  [
               QuickDateRange(
              dateRange: null,
              label: "Clear",
            ),

              ...[7, 10, 15, 30, 60, 90].map(
              (days) => QuickDateRange(
        label: 'Last $days days',
          dateRange: DateRange(
            DateTime.now().subtract(Duration(days: days)),
            DateTime.now(),
          ),
        ),
      ),
        ],


    theme: const CalendarTheme(
                selectedColor: Colors.blue,
                inRangeColor: Color(0xFFD9EDFA),
                inRangeTextStyle: TextStyle(color: Colors.blue),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                disabledTextStyle: TextStyle(color: Colors.grey),
                defaultTextStyle: TextStyle(fontSize: 12),
                dayNameTextStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: 10,
                ),
                radius: 10,
                tileSize: 32,
                quickDateRangeBackgroundColor: Colors.white,
                selectedQuickDateRangeColor: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isLabel) ...[
          Text(
            "Date Filter",
            style: AppTextStyle.labelDropdownTextStyle(context),
          ),
          const SizedBox(height: 2),
        ],
        GestureDetector(
          onTap: () async {
            final result = await _showPicker(context);
            if (result != null) {
              setState(() => selectedDateRange = result);
              widget.onDateRangeSelected(result);
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 30,
              maxHeight: 35,
            ),
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Please select a start end date',
                hintStyle: TextStyle(
                  color: AppColors.matteBlack.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                suffixIcon:
                const Icon(Icons.date_range, size: 16),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(AppSizes.radius),
                  borderSide:
                  BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(AppSizes.radius),
                  borderSide:
                  BorderSide(color: AppColors.matteBlack),
                ),
              ),
              child: Text(
                selectedDateRange != null
                    ? '${selectedDateRange!.start.toString().split(' ')[0]} → '
                    '${selectedDateRange!.end.toString().split(' ')[0]}'
                    : 'Please select a start end date',
                style: TextStyle(
                  fontSize: 14,
                  color: selectedDateRange != null
                      ? AppColors.matteBlack
                      : AppColors.matteBlack
                      .withValues(alpha: 0.5),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<DateRange?> _showPicker(BuildContext context) {
    DateRange? tempRange = selectedDateRange;

    return showModalBottomSheet<DateRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ClipRRect(
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            color: Colors.white,
            height:
            MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    child: _datePicker(
                      context,
                          (range) => tempRange = range,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(context, null),
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, tempRange),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
