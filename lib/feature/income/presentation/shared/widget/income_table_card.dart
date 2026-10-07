import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../../../responsive.dart';
import '../../../data/model/income_model.dart';
import '../../IncomeBloc/income_bloc.dart';
import '../income_create_screen/income_create_screen.dart';

class IncomeTableCard extends StatelessWidget {
  final List<IncomeModel> incomes;
  final VoidCallback? onIncomeTap;

  const IncomeTableCard({Key? key, required this.incomes, this.onIncomeTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      return Center(child: Text('No Incomes Found'));
    }

    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _IncomeDesktopTable(
        incomes: incomes,
        onEdit: (i) => _showEditDialog(context, i, false),
        onView: (i) => _showViewDialog(context, i, false),
        onDelete: (i) => _confirmDelete(context, i),
      );
    }
  }

  // Mobile / Tablet Cards
  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return _buildIncomeCard(income, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildIncomeCard(
      IncomeModel income, int index, BuildContext context, bool isMobile) {
    final amountValue = double.tryParse(income.amount ?? '0') ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0.0 : 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            income.invoiceNumber?.capitalize() ?? 'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF16A34A),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '৳${amountValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.category,
                  label: 'Income Head',
                  value: income.headName ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.calendar,
                  label: 'Date',
                  value: AppWidgets().convertDateTimeDDMMYYYY(
                      DateTime.tryParse(income.incomeDate ?? '')),
                ),
                const SizedBox(height: 8),
                if (income.note?.isNotEmpty == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.note, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Note:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          income.note!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewDialog(context, income, true),
                    icon: const Icon(HugeIcons.strokeRoundedView, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(color: Colors.green.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditBottomSheet(context, income),
                    icon: const Icon(Iconsax.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, income),
                    icon: const Icon(HugeIcons.strokeRoundedDeleteThrow, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.text(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop Table
  Future<void> _confirmDelete(BuildContext context, IncomeModel income) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    if (context.mounted) {
      context.read<IncomeBloc>().add(DeleteIncome(id: income.id.toString()));
    }
  }
  void _showEditBottomSheet(BuildContext context, IncomeModel income) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // প্রথমে 70% of screen
          minChildSize: 0.4,     // minimum 40%
          maxChildSize: 0.95,    // maximum 95%
          expand: false,         // content অনুযায়ী expand
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radius),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radius),
                ),
                child: MobileIncomeCreate(
                  incomeModel: income,
                  scrollController: scrollController,
                  // id: income.id.toString(),

                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, IncomeModel income, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.5,
            ),
            child: MobileIncomeCreate(
              incomeModel: income,
              id: income.id.toString(),

              // accountId: income.account.toString(),
              // name: "Update",
            ),
          ),
        );
      },
    );
  }

  void _showViewDialog(BuildContext context, IncomeModel income, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.4,
              maxHeight: AppSizes.height(context) * 0.7,
            ),
            child: Container(
              color: AppColors.bottomNavBg(context),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildViewDetailRow(context, 'Invoice No:', income.invoiceNumber ?? 'N/A'),
                  _buildViewDetailRow(context, 'Income Head:', income.headName ?? 'N/A'),
                  _buildViewDetailRow(context, 'Account:', income.accountName ?? 'N/A'),
                  _buildViewDetailRow(context, 'Date:', AppWidgets().convertDateTimeDDMMYYYY(
                      DateTime.tryParse(income.incomeDate ?? ''))),
                  _buildViewDetailRow(context, 'Amount:', income.amount ?? 'N/A'),
                  if (income.note?.isNotEmpty == true)
                    _buildViewDetailRow(context, 'Note:', income.note ?? 'N/A'),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.text(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.text(context)),
            ),
          ),
        ],
      ),
    );
  }
}


// ───────────────────────── Desktop table (নতুন ডিজাইন) ─────────────────────────
class _IncomeDesktopTable extends StatefulWidget {
  final List<IncomeModel> incomes;
  final void Function(IncomeModel) onEdit;
  final void Function(IncomeModel) onView;
  final void Function(IncomeModel) onDelete;

  const _IncomeDesktopTable({
    required this.incomes,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  @override
  State<_IncomeDesktopTable> createState() => _IncomeDesktopTableState();
}

class _IncomeDesktopTableState extends State<_IncomeDesktopTable> {
  // ScrollController আগে build এর ভেতরে প্রতি rebuild এ নতুন হতো (scroll হারাত + leak)।
  final ScrollController _hScroll = ScrollController();

  static const _green = Color(0xFF16A34A);
  static const _weights = [0.6, 1.2, 1.3, 1.1, 1.1, 1.2, 1.8, 1.3];
  static const _minTableWidth = 1000.0;
  static const _margin = 16.0;
  static const _spacing = 12.0;

  @override
  void dispose() {
    _hScroll.dispose();
    super.dispose();
  }

  String _money(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '৳$whole.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            constraints.maxWidth.isFinite ? constraints.maxWidth : _minTableWidth;
        final tableWidth = available < _minTableWidth ? _minTableWidth : available;
        final usable =
            tableWidth - _margin * 2 - _spacing * (_weights.length - 1);
        final sum = _weights.reduce((a, b) => a + b);
        double w(int i) => usable * _weights[i] / sum;

        Widget head(String t, int i, {Alignment a = Alignment.centerLeft}) =>
            SizedBox(width: w(i), child: Align(alignment: a, child: Text(t)));

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Scrollbar(
              controller: _hScroll,
              thumbVisibility: tableWidth > available,
              child: SingleChildScrollView(
                controller: _hScroll,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: DataTable(
                    horizontalMargin: _margin,
                    columnSpacing: _spacing,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    headingRowHeight: 46,
                    dividerThickness: 0.6,
                    headingRowColor:
                        WidgetStateProperty.all(primary.withValues(alpha: 0.10)),
                    headingTextStyle: TextStyle(
                      color: AppColors.text(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    dataTextStyle: TextStyle(
                      color: AppColors.text(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    columns: [
                      DataColumn(label: head('No.', 0, a: Alignment.center)),
                      DataColumn(label: head('Invoice No.', 1)),
                      DataColumn(label: head('Income Head', 2)),
                      DataColumn(label: head('Account', 3)),
                      DataColumn(label: head('Date', 4, a: Alignment.center)),
                      DataColumn(label: head('Amount', 5, a: Alignment.center)),
                      DataColumn(label: head('Note', 6)),
                      DataColumn(label: head('Actions', 7, a: Alignment.center)),
                    ],
                    rows: [
                      for (var k = 0; k < widget.incomes.length; k++)
                        _row(context, k, widget.incomes[k], w, primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _row(BuildContext context, int k, IncomeModel income,
      double Function(int) w, Color primary) {
    final amount = double.tryParse(income.amount ?? '') ?? 0;
    final note = (income.note ?? '').trim();
    final date = AppWidgets()
        .convertDateTimeDDMMYYYY(DateTime.tryParse(income.incomeDate ?? ''));

    Widget cell(int i, Widget child) => SizedBox(width: w(i), child: child);
    Widget text(String t) => Text(t, maxLines: 1, overflow: TextOverflow.ellipsis);

    return DataRow(
      color: WidgetStateProperty.all(
        k.isOdd ? Colors.grey.withValues(alpha: 0.045) : Colors.transparent,
      ),
      cells: [
        DataCell(cell(0, Center(child: text('${k + 1}')))),
        DataCell(cell(
          1,
          Text(
            income.invoiceNumber?.isNotEmpty == true ? income.invoiceNumber! : 'N/A',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        )),
        DataCell(cell(
          2,
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                income.headName?.isNotEmpty == true ? income.headName! : 'N/A',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        )),
        DataCell(cell(3, text(income.accountName ?? 'N/A'))),
        DataCell(cell(4, Center(child: text(date)))),
        DataCell(cell(
          5,
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: (amount > 0 ? _green : Colors.grey).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _money(amount),
                style: TextStyle(
                  color: amount > 0 ? _green : Colors.grey,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        )),
        DataCell(cell(
          6,
          note.isEmpty
              ? Text('—', style: TextStyle(color: Colors.grey.shade500))
              : Tooltip(message: note, child: text(note)),
        )),
        DataCell(cell(
          7,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _action(Iconsax.edit, 'Edit', AppColors.info, () => widget.onEdit(income)),
              const SizedBox(width: 6),
              _action(HugeIcons.strokeRoundedView, 'View', _green,
                  () => widget.onView(income)),
              const SizedBox(width: 6),
              _action(HugeIcons.strokeRoundedDeleteThrow, 'Delete', AppColors.danger,
                  () => widget.onDelete(income)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _action(IconData icon, String tip, Color color, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
