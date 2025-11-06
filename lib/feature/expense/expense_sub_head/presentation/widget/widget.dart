import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../expense_head/data/model/expense_head_model.dart';
import '../../data/model/expense_sub_head_model.dart';
import '../bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../pages/expense_sub_head_create.dart';

class ExpenseSubHeadTableCard extends StatelessWidget {
  final List<ExpenseSubHeadModel> expenseSubHeads;
  final VoidCallback? onExpenseSubHeadTap;

  const ExpenseSubHeadTableCard({
    super.key,
    required this.expenseSubHeads,
    this.onExpenseSubHeadTap,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseSubHeads.isEmpty) {
      return _buildEmptyState();
    }

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 5; // No., Sub Head Name, Head Name, Status, Actions
        const minColumnWidth = 120.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 8,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: expenseSubHeads.asMap().entries.map((entry) {
                            final expenseSubHead = entry.value;
                            return DataRow(
                              cells: [
                                _buildDataCell('${entry.key + 1}', dynamicColumnWidth * 0.6),
                                _buildDataCell(expenseSubHead.name?.capitalize() ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(expenseSubHead.headName?.capitalize() ?? "N/A", dynamicColumnWidth),
                                _buildStatusCell(_getExpenseSubHeadStatus(expenseSubHead), dynamicColumnWidth),
                                _buildActionCell(expenseSubHead, context, dynamicColumnWidth),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text('No.', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Sub Head Name', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Head Name', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Status', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataCell _buildDataCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  bool _getExpenseSubHeadStatus(ExpenseSubHeadModel expenseSubHead) {
    // Handle different possible status representations
    if (expenseSubHead.isActive != null) {
      if (expenseSubHead.isActive is bool) {
        return expenseSubHead.isActive as bool;
      }
    }

    // Fallback to isActive if available
    return expenseSubHead.isActive ?? false;
  }

  DataCell _buildStatusCell(bool isActive, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionCell(ExpenseSubHeadModel expenseSubHead, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Edit Button
            _buildActionButton(
              icon: Iconsax.edit,
              color: Colors.blue,
              tooltip: 'Edit expense sub head',
              onPressed: () => _showEditDialog(context, expenseSubHead),
            ),

            // Delete Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedDeleteThrow,
              color: Colors.red,
              tooltip: 'Delete expense sub head',
              onPressed: () => _confirmDelete(context, expenseSubHead),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }

  void _showLoadingDialog(BuildContext context, {String message = 'Deleting...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, ExpenseSubHeadModel expenseSubHead) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    // Show loading dialog
    _showLoadingDialog(context, message: 'Deleting...');

    // Send delete event
    if (context.mounted) {
      context.read<ExpenseSubHeadBloc>().add(
        DeleteSubExpenseHead(id: expenseSubHead.id.toString()),
      );
    }
  }

  void _showEditDialog(BuildContext context, ExpenseSubHeadModel expenseSubHead) {
    // Pre-fill the form
    final expenseSubHeadBloc = context.read<ExpenseSubHeadBloc>();
    expenseSubHeadBloc.name.text = expenseSubHead.name ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: AppSizes.width(context) * 0.50,
            child: ExpenseSubCreateScreen(
              id: expenseSubHead.id.toString(),
              name: expenseSubHead.name,
              selectedHead: ExpenseHeadModel(
                id: expenseSubHead.head,
                name: expenseSubHead.headName,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Expense Sub Heads Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expense sub head to get started',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}