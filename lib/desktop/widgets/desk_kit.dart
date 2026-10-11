import 'package:flutter/material.dart';

import '../../core/configs/app_colors.dart';
import '../../feature/lab_dashboard/presentation/widgets/dash_kit.dart'
    show DashColors;

/// Desktop পেজের সাধারণ কাঠামো — ওয়েবের পেজ-হেডার, filter bar ও কার্ডের মতো।
/// নতুন package লাগে না। Step 1 এর DashColors এর উপর নির্ভর করে (Step 1 আগে বসান)।

/// পেজের মাথা: বড় শিরোনাম + ছোট বিবরণ + ডানে বোতাম
class DeskPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const DeskPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: c.ink)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!,
                  style: TextStyle(fontSize: 13.5, color: c.muted)),
            ],
          ],
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            actions[i],
          ],
        ]),
      ],
    );
  }
}

/// পেজের বাইরের ফ্রেম — ধূসর পটভূমি + সমান padding
class DeskPage extends StatelessWidget {
  final Widget child;
  const DeskPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: AppColors.background(context),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: child,
      );
}

/// সাদা কার্ড (ওয়েবের .panel)
class DeskCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const DeskCard(
      {super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.dark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// প্রধান বোতাম (+ New ...)
class DeskButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;

  const DeskButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final primary = AppColors.primaryColor(context);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink2,
          side: BorderSide(color: c.dark ? const Color(0xFF34425F) : const Color(0xFFCBD5E1)),
          shape: shape,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: AppColors.onColor(primary),
        shape: shape,
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
      child: child,
    );
  }
}

/// filter বারের ভেতরের সার্চ বাক্স
class DeskSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final double width;

  const DeskSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hint = 'Search…',
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return SizedBox(
      width: width,
      height: 42,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: c.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: c.muted, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: c.muted),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(Icons.close_rounded, size: 18, color: c.muted),
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                    },
                  ),
          ),
          filled: true,
          fillColor: c.tint,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: c.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: c.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryColor(context)),
          ),
        ),
      ),
    );
  }
}

/// filter বারের dropdown — "All" সহ, নিজস্ব ছোট popup menu
class DeskFilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const DeskFilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.tint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(10),
          dropdownColor: c.surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: c.muted),
          hint: Text(label, style: TextStyle(fontSize: 14, color: c.muted)),
          style: TextStyle(fontSize: 14, color: c.ink),
          items: [
            DropdownMenuItem<T?>(
                value: null, child: Text('All $label')),
            for (final i in items)
              DropdownMenuItem<T?>(value: i, child: Text(itemLabel(i))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// তারিখের রেঞ্জ বোতাম — চাপলে Flutter এর নিজস্ব date range picker
class DeskDateRangeButton extends StatelessWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;

  const DeskDateRangeButton(
      {super.key, required this.value, required this.onChanged});

  String _f(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final now = DateTime.now();
        final r = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 10),
          lastDate: DateTime(now.year + 1, 12, 31),
          initialDateRange: value,
        );
        if (r != null) onChanged(r);
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.tint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_month_outlined, size: 18, color: c.muted),
          const SizedBox(width: 8),
          Text(
            value == null ? 'Any date' : '${_f(value!.start)} – ${_f(value!.end)}',
            style: TextStyle(fontSize: 14, color: value == null ? c.muted : c.ink),
          ),
          if (value != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: () => onChanged(null),
              child: Icon(Icons.close_rounded, size: 16, color: c.muted),
            ),
          ],
        ]),
      ),
    );
  }
}

/// ফাঁকা / ত্রুটি / লোডিং অবস্থা — কার্ডের ভেতরে
class DeskState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color? color;

  const DeskState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.color,
  });

  factory DeskState.loading() => const DeskState(
      icon: Icons.hourglass_empty_rounded, title: 'Loading…');

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return DeskCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: color ?? c.muted),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: c.ink)),
          if (message != null) ...[
            const SizedBox(height: 4),
            Text(message!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: c.muted)),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// ছোট dialog ফ্রেম — create/edit ফর্ম বসানোর জন্য (bottom sheet এর বদলে)
Future<T?> showDeskDialog<T>(BuildContext context, Widget child,
    {double width = 560}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        ),
        child: child,
      ),
    ),
  );
}
