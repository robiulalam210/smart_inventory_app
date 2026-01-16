import 'package:google_fonts/google_fonts.dart';
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
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (expenseSubHeads.isEmpty) {
      return _buildEmptyState();
    }

    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _buildDesktopDataTable();
    }
  }

  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: expenseSubHeads.length,
      itemBuilder: (context, index) {
        final expenseSubHead = expenseSubHeads[index];
        return _buildExpenseSubHeadCard(
          expenseSubHead,
          index + 1,
          context,
          isMobile,
        );
      },
    );
  }

  Widget _buildExpenseSubHeadCard(
    ExpenseSubHeadModel expenseSubHead,
    int index,
    BuildContext context,
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 6.0 : 12.0,
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
          // Header with Index and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (_getExpenseSubHeadStatus(expenseSubHead)
                  ? Colors.green.withValues(alpha: 0.05)
                  : Colors.red.withValues(alpha: 0.05)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                /// 👈 LEFT SIDE (TAKES REMAINING SPACE)
                Expanded(
                  child: Row(
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
                      const SizedBox(width: 8),

                      /// ✅ Flexible (NOT Expanded)
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          expenseSubHead.name?.capitalize() ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:  TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// 👉 RIGHT SIDE (FIXED WIDTH)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getExpenseSubHeadStatus(expenseSubHead)
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                    border: Border.all(
                      color: _getExpenseSubHeadStatus(expenseSubHead)
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Text(
                    _getExpenseSubHeadStatus(expenseSubHead)
                        ? 'ACTIVE'
                        : 'INACTIVE',
                    style: TextStyle(
                      color: _getExpenseSubHeadStatus(expenseSubHead)
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expense Sub Head Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Head Name
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.category,
                  label: 'Parent Head',
                  value: expenseSubHead.headName?.capitalize() ?? "N/A",
                  isImportant: true,
                ),

                // Additional Info

              ],
            ),
          ),

          // Action Buttons - FIXED VERSION
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              children: [
                // Edit Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context, expenseSubHead),
                    icon: const Icon(Iconsax.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, expenseSubHead),
                    icon: const Icon(
                      HugeIcons.strokeRoundedDeleteThrow,
                      size: 16,
                    ),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
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
    bool isImportant = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color:AppColors.text(context)),
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
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isImportant ? FontWeight.w700 : FontWeight.w500,
                    color: isImportant ? AppColors.primaryColor(context) : AppColors.text(context),
                    fontSize: isImportant ? 15 : 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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

  // Keep your existing desktop DataTable code here
  Widget _buildDesktopDataTable() {
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

        final dynamicColumnWidth = (totalWidth / numColumns).clamp(
          minColumnWidth,
          double.infinity,
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
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
                            AppColors.primaryColor(context),
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
                                _buildDataCell(
                                  '${entry.key + 1}',
                                  dynamicColumnWidth * 0.6,
                                ),
                                _buildDataCell(
                                  expenseSubHead.name?.capitalize() ?? "N/A",
                                  dynamicColumnWidth,
                                ),
                                _buildDataCell(
                                  expenseSubHead.headName?.capitalize() ??
                                      "N/A",
                                  dynamicColumnWidth,
                                ),
                                _buildStatusCell(
                                  _getExpenseSubHeadStatus(expenseSubHead),
                                  dynamicColumnWidth,
                                ),
                                _buildActionCell(
                                  expenseSubHead,
                                  context,
                                  dynamicColumnWidth,
                                ),
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

  DataCell _buildStatusCell(bool isActive, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
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

  DataCell _buildActionCell(
    ExpenseSubHeadModel expenseSubHead,
    BuildContext context,
    double width,
  ) {
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

  void _showLoadingDialog(
    BuildContext context, {
    String message = 'Deleting...',
  }) {
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

  Future<void> _confirmDelete(
    BuildContext context,
    ExpenseSubHeadModel expenseSubHead,
  ) async {
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

  void _showEditDialog(
    BuildContext context,
    ExpenseSubHeadModel expenseSubHead,
  ) {
    // Pre-fill the form
    final expenseSubHeadBloc = context.read<ExpenseSubHeadBloc>();
    expenseSubHeadBloc.name.text = expenseSubHead.name ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(

          child: Container(
            color: AppColors.bottomNavBg(context),

            width: Responsive.isMobile(context)
                ? double.infinity
                : AppSizes.width(context) * 0.50,
            // height: Responsive.isMobile(context)
            //     ? AppSizes.height(context) * 0.8
            //     : null,
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
            color: Colors.grey.withValues(alpha: 0.1),
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
            color: Colors.grey.withValues(alpha: 0.5),
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
