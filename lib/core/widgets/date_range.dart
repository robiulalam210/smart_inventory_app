import 'package:intl/intl.dart';
import 'web_ui.dart';
import 'package:flutter/material.dart';
import 'package:meherinMart/core/widgets/app_popover_route.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../configs/app_colors.dart';
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
                selectedColor: AppColors.info,
                inRangeColor: Color(0xFFD9EDFA),
                inRangeTextStyle: TextStyle(color: AppColors.info),
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
                selectedQuickDateRangeColor: AppColors.info,
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
          // ওয়েবের .f-date / .combo-btn এর মতো: বাছাই থাকলে নীল রেখা ও নীল-wash
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selectedDateRange != null ? W.blueWash(context) : W.surface(context),
              border: Border.all(
                color: selectedDateRange != null ? W.blue(context) : W.line2(context),
              ),
              borderRadius: BorderRadius.circular(W.rSm),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 15, color: W.muted(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDateRange != null
                        ? '${DateFormat('d MMM yyyy').format(selectedDateRange!.start)} → '
                            '${DateFormat('d MMM yyyy').format(selectedDateRange!.end)}'
                        : 'Select date range',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDateRange != null ? W.ink(context) : W.muted(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<DateRange?> _showPicker(BuildContext context) {
    DateRange? tempRange = selectedDateRange;

    // Desktop: date field এর ঠিক নিচে anchored popover
    return showAppPopoverSheet<DateRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      mode: PopoverAnchorMode.anchored,
      width: 440,
      builder: (_) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: AppColors.bottomNavBg(context),
            height: (MediaQuery.of(context).size.height * 0.7)
                .clamp(420.0, 620.0),
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
