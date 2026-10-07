import 'dart:ui' show FontFeature;

import '../configs/configs.dart';

// ============================================================
// DETAIL PAGE KIT — সব "Details" page এর জন্য একই building block
// ------------------------------------------------------------
//   DetailSection  — শিরোনামসহ সাদা card (Basic Info, Pricing …)
//   DetailGrid     — label/value জোড়া, ২–৩ column এ সাজানো
//   DetailStat     — বড় সংখ্যার KPI card (Stock, Value …)
//   DetailPill     — ছোট রঙিন label (Active, SKU …)
//
// এগুলো একবার বানানো হলে Sales / Purchase / Money Receipt details
// page ও একই চেহারায় আনা যাবে — প্রতিটা page নিজের মতো card বানাবে না।
// ============================================================

Color _border(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

/// শিরোনামসহ card
class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.primaryColor(context)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(height: 1, color: _border(context)),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// একটা label/value জোড়া
class DetailItem {
  const DetailItem(this.label, this.value,
      {this.icon, this.valueColor, this.bold = false, this.fullWidth = false});

  final String label;
  final String? value;
  final IconData? icon;
  final Color? valueColor;
  final bool bold;

  /// লম্বা লেখা (description) — পুরো সারি জুড়ে
  final bool fullWidth;
}

/// label/value গুলো column এ সাজায় — জায়গা বুঝে ১, ২ বা ৩ column
class DetailGrid extends StatelessWidget {
  const DetailGrid({super.key, required this.items, this.maxColumns = 3});

  final List<DetailItem> items;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        int cols = w > 720 ? 3 : (w > 420 ? 2 : 1);
        if (cols > maxColumns) cols = maxColumns;
        const double gap = 16;
        final double cellW = (w - gap * (cols - 1)) / cols;

        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: [
            for (final item in items)
              SizedBox(
                width: item.fullWidth ? w : cellW,
                child: _DetailCell(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({required this.item});
  final DetailItem item;

  @override
  Widget build(BuildContext context) {
    final String raw = (item.value ?? '').trim();
    final bool empty = raw.isEmpty || raw == 'null';
    final Color text = AppColors.text(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.icon != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon,
                size: 16, color: AppColors.primaryColor(context)),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 3),
              Text(
                empty ? 'Not set' : raw,
                maxLines: item.fullWidth ? null : 2,
                overflow: item.fullWidth ? null : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: item.bold ? FontWeight.w600 : FontWeight.w500,
                  fontStyle: empty ? FontStyle.italic : FontStyle.normal,
                  color: empty
                      ? text.withValues(alpha: 0.4)
                      : (item.valueColor ?? text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// বড় সংখ্যার KPI card
class DetailStat extends StatelessWidget {
  const DetailStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.caption,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final Color text = AppColors.text(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: text,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: color),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ছোট রঙিন label
class DetailPill extends StatelessWidget {
  const DetailPill(this.text, {super.key, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// details page এর উপরের bar — back, শিরোনাম + breadcrumb, ডানে action
PreferredSizeWidget detailAppBar(
  BuildContext context, {
  required String title,
  List<String> breadcrumb = const [],
  List<Widget> actions = const [],
}) {
  final Color text = AppColors.text(context);
  return AppBar(
    backgroundColor: AppColors.bottomNavBg(context),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    toolbarHeight: 64,
    titleSpacing: 4,
    leading: IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (breadcrumb.isNotEmpty)
          Text(
            breadcrumb.join('  ›  '),
            style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.55)),
          ),
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: text),
        ),
      ],
    ),
    actions: [...actions, const SizedBox(width: 12)],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(height: 1, color: _border(context)),
    ),
  );
}

// ============================================================
// HERO — page এর একদম উপরের পরিচয় card
// ------------------------------------------------------------
// বাঁয়ে icon + নম্বর (SL-1002) + নিচে ছোট pill গুলো, ডানে সবচেয়ে
// দরকারি টাকার অঙ্ক (Grand Total / Amount)। চোখ প্রথমে এখানেই যায়।
// ============================================================
class DetailHero extends StatelessWidget {
  const DetailHero({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.pills = const [],
    this.amountLabel,
    this.amount,
    this.amountColor,
    this.amountCaption,
    this.amountCaptionColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> pills;
  final String? amountLabel;
  final String? amount;
  final Color? amountColor;
  final String? amountCaption;
  final Color? amountCaptionColor;

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.primaryColor(context);
    final Color text = AppColors.text(context);
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w700, color: text),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13, color: text.withValues(alpha: 0.6)),
                  ),
                ],
                if (pills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6, children: pills),
                ],
              ],
            ),
          ),
          if (amount != null) ...[
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (amountLabel != null)
                  Text(
                    amountLabel!,
                    style: TextStyle(
                        fontSize: 12, color: text.withValues(alpha: 0.55)),
                  ),
                const SizedBox(height: 2),
                Text(
                  amount!,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: amountColor ?? primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (amountCaption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    amountCaption!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: amountCaptionColor ?? text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// টাকার হিসাবের একটা সারি
class DetailAmount {
  const DetailAmount(
    this.label,
    this.value, {
    this.color,
    this.strong = false,
    this.negative = false,
    this.dividerBefore = false,
    this.hideIfZero = false,
  });

  final String label;
  final double value;
  final Color? color;

  /// মোট / চূড়ান্ত — বড় ও গাঢ়
  final bool strong;

  /// বাদ যাওয়া অঙ্ক (discount) — "− ৳" দিয়ে দেখায়
  final bool negative;
  final bool dividerBefore;

  /// ০ হলে সারিটাই দেখাবে না (VAT ০ হলে অকারণ লাইন নয়)
  final bool hideIfZero;
}

/// টাকার হিসাব — label বাঁয়ে, অঙ্ক ডানে, দশমিক এক লাইনে
class DetailAmountList extends StatelessWidget {
  const DetailAmountList({super.key, required this.rows});

  final List<DetailAmount> rows;

  @override
  Widget build(BuildContext context) {
    final Color text = AppColors.text(context);
    final visible = rows.where((r) => !(r.hideIfZero && r.value == 0));
    return Column(
      children: [
        for (final r in visible) ...[
          if (r.dividerBefore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Divider(height: 1, color: _border(context)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    r.label,
                    style: TextStyle(
                      fontSize: r.strong ? 14.5 : 13.5,
                      fontWeight: r.strong ? FontWeight.w700 : FontWeight.w400,
                      color: r.strong ? text : text.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Text(
                  '${r.negative && r.value != 0 ? '− ' : ''}৳${r.value.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: r.strong ? 16 : 14,
                    fontWeight: r.strong ? FontWeight.w700 : FontWeight.w600,
                    color: r.color ??
                        (r.negative && r.value != 0 ? AppColors.danger : text),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// details page এর body — চওড়া পর্দায় দুই column (বাঁয়ে ৩ ভাগ, ডানে
/// ২ ভাগ), ছোট window এ এক column। সব details page একই কাঠামো পায়।
class DetailPageBody extends StatelessWidget {
  const DetailPageBody({
    super.key,
    this.hero,
    required this.left,
    required this.right,
  });

  final Widget? hero;
  final List<Widget> left;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 980;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hero != null) hero!,
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: Column(children: left)),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: Column(children: right)),
                      ],
                    )
                  else ...[
                    ...left,
                    ...right,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// দেখার জন্য ছোট line-item টেবিল (Product / Qty / Price / Total)
class DetailItemsTable extends StatelessWidget {
  const DetailItemsTable({super.key, required this.rows, this.emptyText = 'No items'});

  /// [name, subtitle?, qty, unitPrice, discountText?, total]
  final List<DetailLine> rows;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final Color text = AppColors.text(context);
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(emptyText,
              style: TextStyle(color: text.withValues(alpha: 0.5))),
        ),
      );
    }
    TextStyle head = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: text.withValues(alpha: 0.55),
    );
    Widget cell(String s, {TextAlign align = TextAlign.right, bool bold = false}) =>
        Text(
          s,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: text,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );

    final bool hasDiscount = rows.any((r) => (r.discount ?? '').isNotEmpty);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryColor(context).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(width: 28, child: Text('#', style: head)),
              Expanded(flex: 5, child: Text('Product', style: head)),
              Expanded(flex: 2, child: Text('Qty', style: head, textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text('Unit Price', style: head, textAlign: TextAlign.right)),
              if (hasDiscount)
                Expanded(flex: 2, child: Text('Discount', style: head, textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text('Total', style: head, textAlign: TextAlign.right)),
            ],
          ),
        ),
        for (int i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: i == rows.length - 1
                  ? null
                  : Border(bottom: BorderSide(color: _border(context))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 12.5, color: text.withValues(alpha: 0.5))),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cell(rows[i].name, align: TextAlign.left, bold: true),
                      if ((rows[i].subtitle ?? '').isNotEmpty)
                        Text(
                          rows[i].subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11.5,
                              color: text.withValues(alpha: 0.55)),
                        ),
                    ],
                  ),
                ),
                Expanded(flex: 2, child: cell(rows[i].qty)),
                Expanded(
                    flex: 2,
                    child: cell('৳${rows[i].unitPrice.toStringAsFixed(2)}')),
                if (hasDiscount)
                  Expanded(flex: 2, child: cell(rows[i].discount ?? '-')),
                Expanded(
                    flex: 2,
                    child: cell('৳${rows[i].total.toStringAsFixed(2)}',
                        bold: true)),
              ],
            ),
          ),
      ],
    );
  }
}

class DetailLine {
  const DetailLine({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.total,
    this.subtitle,
    this.discount,
  });

  final String name;
  final String? subtitle;
  final String qty;
  final double unitPrice;
  final String? discount;
  final double total;
}

/// dynamic (String / num / null) → double
double detailNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

/// 2.00 → "2", 1.50 → "1.5"
String detailQty(double q) {
  if (q == q.roundToDouble()) return q.toStringAsFixed(0);
  return q.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
}
