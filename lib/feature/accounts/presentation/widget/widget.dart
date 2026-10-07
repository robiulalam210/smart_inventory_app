import '../../../../core/configs/configs.dart';
import '../../data/model/account_model.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class AccountCard extends StatelessWidget {
  final List<AccountModel> accounts;
  final VoidCallback? onAccountTap;
  final Function(AccountModel)? onEdit;
  final Function(AccountModel)? onDelete;

  const AccountCard({
    super.key,
    required this.accounts,
    this.onAccountTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (accounts.isEmpty) {
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _buildAccountCard(account, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildAccountCard(
      AccountModel account,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    final balanceColor = _getBalanceColor(account.balance);

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
      ),      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Account No and Balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                        '#${account.acNo ?? index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      account.acType ?? 'Account',
                      style: TextStyle(
                        color: _getAccountTypeColor(account.acType),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: balanceColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_getBalancePrefix(account.balance)}৳${_getBalanceAmount(account.balance)}',
                    style: TextStyle(
                      color: balanceColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Account Details
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Account Name
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.bank,
                  label: 'Account Name',
                  value: account.name ?? 'N/A',
                  isImportant: true,
                ),
                const SizedBox(height: 4),

                // Account Number
                if (account.acNumber?.isNotEmpty == true)
                  Column(
                    children: [
                      _buildDetailRow(
                        context: context,
                        icon: Iconsax.card,
                        label: 'Account No',
                        value: account.acNumber ?? 'N/A',
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),

                // Bank & Branch
                if (account.bankName?.isNotEmpty == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.building,
                            size: 16,
                            color: AppColors.text(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bank/Branch:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (account.bankName?.isNotEmpty == true)
                              Text(
                                account.bankName!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.text(context)
                                ),
                              ),
                            if (account.branch?.isNotEmpty == true)
                              Text(
                                account.branch!,
                                style: TextStyle(
                                  color: AppColors.text(context),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                // Additional Info
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 16,
                      color:AppColors.text(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Balance: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(context),
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_getBalancePrefix(account.balance)}৳${_getBalanceAmount(account.balance)}',
                        style: TextStyle(
                          color: balanceColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
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
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Edit Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onEdit?.call(account),
                    icon: const Icon(
                      Iconsax.edit,
                      size: 16,
                    ),
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

                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, account, true),
                    icon: const Icon(
                      HugeIcons.strokeRoundedDeleteThrow,
                      size: 16,
                    ),
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
    bool isImportant = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.text(context),
          ),
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
                    color: isImportant ?AppColors.primaryColor(context) : AppColors.text(context),
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

  // Desktop টেবিল — AppDataTable (নাম বাঁয়ে, টাকা ডানে, action মাঝে)
  Widget _buildDesktopDataTable() {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Account Name', flex: 3, minWidth: 160),
      AppTableColumn('Type', flex: 2, minWidth: 100),
      AppTableColumn('Account No.', flex: 2, minWidth: 120),
      AppTableColumn('Bank / Branch', flex: 3, minWidth: 150),
      AppTableColumn.numeric('Balance', flex: 2, minWidth: 120),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: accounts.length,
      cellBuilder: (context, row, col) {
        final a = accounts[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(a.name ?? '-', bold: true, subtitle: a.acNo);
          case 2:
            return AppStatusPill(a.acType ?? '-',
                color: _getAccountTypeColor(a.acType));
          case 3:
            return AppTableText(a.acNumber ?? '-');
          case 4:
            return AppTableText(a.bankName ?? '-', subtitle: a.branch);
          case 5:
            return AppTableText(
              '${_getBalancePrefix(a.balance)}৳${_getBalanceAmount(a.balance)}',
              align: AppCellAlign.end,
              bold: true,
              color: _getBalanceColor(a.balance),
            );
          default:
            return AppTableEditDelete(
              onEdit: onEdit == null ? null : () => onEdit!(a),
              onDelete: () => _showDeleteConfirmation(context, a, false),
            );
        }
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, AccountModel account, bool isMobile) {
    showAppPopover(
      context: context,
      builder: (BuildContext context) {
        return AppPopoverShell(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : 500,
              maxHeight: isMobile
                  ? AppSizes.height(context) * 0.6
                  : 400,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete this account?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name ?? 'Unnamed Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (account.acNumber != null && account.acNumber!.isNotEmpty)
                          Text(
                            'Account: ${account.acNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (account.acType != null && account.acType!.isNotEmpty)
                          Text(
                            'Type: ${account.acType}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This action cannot be undone.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDelete?.call(account);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppImages.noData,
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            'No Accounts Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first account to get started',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getBalanceColor(double? balance) {
    if (balance == null) return Colors.grey;
    if (balance < 0) return AppColors.danger;
    if (balance > 0) return AppColors.success;
    return Colors.grey;
  }

  String _getBalancePrefix(double? balance) {
    if (balance == null) return "";
    if (balance < 0) return "-";
    if (balance > 0) return "+";
    return "";
  }

  String _getBalanceAmount(double? balance) {
    if (balance == null) return "0.00";
    return balance.abs().toStringAsFixed(2);
  }

  Color _getAccountTypeColor(String? accountType) {
    switch (accountType?.toLowerCase()) {
      case 'cash':
        return AppColors.success;
      case 'bank':
        return AppColors.info;
      case 'mobile banking':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}