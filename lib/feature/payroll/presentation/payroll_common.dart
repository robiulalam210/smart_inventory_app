import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meherinMart/core/core.dart';

import '../data/payroll_models.dart';

const payMethods = <(String, String)>[
  ('cash', 'Cash'),
  ('bank', 'Bank'),
  ('mobile', 'Mobile banking'),
  ('card', 'Card'),
  ('other', 'Other'),
];

final _moneyFmt = NumberFormat('#,##0.00');

String taka(num? v) => '৳ ${_moneyFmt.format(v ?? 0)}';

String monthKey(DateTime d) => DateFormat('yyyy-MM').format(d);
String monthName(DateTime d) => DateFormat('MMMM yyyy').format(d);
String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

String fmtDate(String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso);
  return d == null ? '—' : DateFormat('dd MMM yyyy').format(d);
}

DateTime thisMonth() {
  final n = DateTime.now();
  return DateTime(n.year, n.month);
}

void payToast(BuildContext context, String msg, {bool error = false}) {
  showCustomToast(
    context: context,
    title: error ? 'Error' : 'Success',
    description: msg,
    icon: error ? Icons.error : Icons.check_circle,
    primaryColor: error ? AppColors.danger : AppColors.success,
  );
}

/// হ্যাঁ/না নিশ্চিতকরণ — true = নিশ্চিত
Future<bool> payConfirm(BuildContext context,
    {required String title, required String body, required String action}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(action, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  return ok == true;
}

/// উপরের সংখ্যার সারি (ওয়েবের sumbar এর মতো)
class SumBar extends StatelessWidget {
  final List<SumItem> items;
  const SumBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyColor(context).withValues(alpha: 0.35), width: 0.6),
      ),
      child: Row(
        children: [
          for (final i in items)
            Expanded(
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(i.value,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: i.color)),
                  ),
                  const SizedBox(height: 2),
                  Text(i.label,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodySmall(context).copyWith(fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SumItem {
  final String label, value;
  final Color? color;
  const SumItem(this.label, this.value, {this.color});
}

class PayPill extends StatelessWidget {
  final String text;
  final Color color;
  const PayPill(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class PayEmpty extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const PayEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.body = '',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: AppColors.greyColor(context)),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: AppTextStyle.titleMedium(context)),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(body, textAlign: TextAlign.center, style: AppTextStyle.bodySmall(context)),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: 14),
                OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      );
}

/// টাকা লেখার ঘর (শুধু সংখ্যা ও দশমিক)
class MoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  const MoneyField({super.key, required this.controller, required this.label, this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          prefixText: '৳ ',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      );
}

/// account + method + date — Pay ও Give-advance ফর্মে একই
class PayFromFields extends StatelessWidget {
  final List<AccountOption> accounts;
  final int? accountId;
  final String method;
  final DateTime date;
  final double? needed;
  final ValueChanged<int?> onAccount;
  final ValueChanged<String> onMethod;
  final ValueChanged<DateTime> onDate;

  const PayFromFields({
    super.key,
    required this.accounts,
    required this.accountId,
    required this.method,
    required this.date,
    required this.onAccount,
    required this.onMethod,
    required this.onDate,
    this.needed,
  });

  @override
  Widget build(BuildContext context) {
    final acc = accounts.where((a) => a.id == accountId).firstOrNull;
    final short = acc != null && needed != null && needed! > acc.balance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          value: accountId,
          isExpanded: true,
          decoration: const InputDecoration(
              labelText: 'Pay from account *', border: OutlineInputBorder(), isDense: true),
          items: [
            for (final a in accounts) DropdownMenuItem(value: a.id, child: Text(a.name, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: onAccount,
        ),
        if (acc != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Balance ${taka(acc.balance)}${short ? ' — not enough' : ''}',
              style: TextStyle(fontSize: 12, color: short ? AppColors.danger : AppColors.slate500),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: method,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Method', border: OutlineInputBorder(), isDense: true),
                items: [for (final m in payMethods) DropdownMenuItem(value: m.$1, child: Text(m.$2))],
                onChanged: (v) => onMethod(v ?? 'cash'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) onDate(d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Date', border: OutlineInputBorder(), isDense: true),
                  child: Text(fmtDate(isoDate(date))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// নিচ থেকে ওঠা ফর্মের কাঠামো
Future<T?> showPaySheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: SingleChildScrollView(child: child),
      ),
    );
