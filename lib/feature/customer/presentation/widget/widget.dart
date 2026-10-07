
import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../data/model/customer_model.dart';
import '../bloc/customer/customer_bloc.dart';
import '../shared/create_customer_screen.dart';
import '../shared/mobile_create_customer_screen.dart';

class CustomerTableCard extends StatelessWidget {
  final List<CustomerModel> customers;
  final void Function(dynamic)
  ? onCustomerTap;

  const CustomerTableCard({
    super.key,
    required this.customers,
    this.onCustomerTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _buildDesktopDataTable(context);
    }
  }

  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildCustomerCard(
      CustomerModel customer,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    final dueAnalysis = customer.paymentBreakdown?.calculation?.dueAnalysis;
    final double netDue =
        (dueAnalysis?.netDueAfterAdvance as num?)?.toDouble() ?? 0.0;
    final double remainingAdvance =
        (dueAnalysis?.remainingAdvanceBalance as num?)?.toDouble() ?? 0.0;

    double amount;
    String label;
    Color color;

    if (netDue > 0) {
      amount = netDue;
      label = "Due";
      color = AppColors.danger;
    } else if (remainingAdvance > 0) {
      amount = remainingAdvance;
      label = "Advance";
      color = AppColors.success;
    } else {
      amount = 0.0;
      label = "Paid";
      color = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0.0 : 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(
          color: customer.specialCustomer
              ? Colors.amber.withOpacity(0.3)
              : AppColors.greyColor(context).withValues(alpha: 0.5),
          width: customer.specialCustomer ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Client No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: customer.specialCustomer
                  ? Colors.amber.withOpacity(0.1)
                  : AppColors.primaryColor(context).withValues(alpha: 0.05),
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
                    // Client No Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: customer.specialCustomer
                            ? Colors.amber
                            : AppColors.primaryColor(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          if (customer.specialCustomer)
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                          if (customer.specialCustomer)
                            const SizedBox(width: 4),
                          Text(
                            '#${customer.clientNo}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (customer.isActive ?? false)
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (customer.isActive ?? false)
                              ? AppColors.success
                              : AppColors.danger,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        customer.isActive ?? false ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: (customer.isActive ?? false)
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),


                  ],
                ),

                // Balance/Amount Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '৳${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Customer Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with Special Icon
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        icon: Iconsax.user,
                        label: 'Name',
                        value: customer.name ?? 'N/A',
                        isImportant: true,
                        context: context,
                      ),
                    ),
                    if (customer.specialCustomer)
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Phone
                _buildDetailRow(
                  icon: Iconsax.call,
                  label: 'Phone',
                  context: context,
                  value: customer.phone ?? 'N/A',
                  onTap: customer.phone != null
                      ? () {
                    // Handle phone call
                  }
                      : null,
                ),
                const SizedBox(height: 4),

                // Email
                if (customer.email?.isNotEmpty == true)
                  Column(
                    children: [
                      _buildDetailRow(
                        icon: Iconsax.sms,
                        context: context,
                        label: 'Email',
                        value: customer.email ?? 'N/A',
                        onTap: () {
                          // Handle email
                        },
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),

                // Address
                if (customer.address?.isNotEmpty == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.location,
                            size: 16,
                            color: AppColors.text(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Address:',
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
                        child: Text(
                          customer.address!,
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                // Customer Type
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      customer.specialCustomer ? Icons.star : Icons.person,
                      size: 16,
                      color: customer.specialCustomer ? Colors.amber : AppColors.text(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customer.specialCustomer ? 'Special Customer' : 'Regular Customer',
                      style: TextStyle(
                        color: customer.specialCustomer ? Colors.amber : AppColors.text(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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
                    onPressed: () => _showEditDialogMobile(context, customer, true),
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

                // Toggle Special Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleSpecialCustomer(context, customer),

                    label: Text(
                      customer.specialCustomer
                          ? 'Remove Special'
                          : 'Mark Special',
                      
                      style: AppTextStyle.body(context).copyWith(
                        fontSize: 10
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      
                      foregroundColor: customer.specialCustomer
                          ? Colors.grey
                          : Colors.amber,
                      side: BorderSide(
                        color: customer.specialCustomer
                            ? Colors.grey.shade300
                            : Colors.amber.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 2),
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
                    onPressed: () => _confirmDelete(context, customer),
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
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isImportant ? FontWeight.w700 : FontWeight.w500,
                    color: isImportant ? AppColors.primaryColor(context) : AppColors.text(context),
                    fontSize: isImportant ? 14 : 13,
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

  // Desktop টেবিল — AppDataTable
  Widget _buildDesktopDataTable(BuildContext context) {
    const columns = [
      AppTableColumn('No.', flex: 1, minWidth: 70),
      AppTableColumn('Name', flex: 3, minWidth: 160),
      AppTableColumn('Phone', flex: 2, minWidth: 120),
      AppTableColumn('Address', flex: 3, minWidth: 150),
      AppTableColumn.center('Status', flex: 2, minWidth: 96),
      AppTableColumn.numeric('Balance', flex: 2, minWidth: 130),
      AppTableColumn.center('Actions', flex: 2, minWidth: 120),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: customers.length,
      cellBuilder: (context, row, col) {
        final c = customers[row];
        switch (col) {
          case 0:
            return AppTableText('#${c.clientNo ?? '-'}', muted: true);
          case 1:
            return Row(
              children: [
                Flexible(child: AppTableText(c.name ?? '-', bold: true)),
                if (c.specialCustomer) ...[
                  const SizedBox(width: 6),
                  const Tooltip(
                    message: 'Special customer',
                    child: Icon(Icons.star_rounded,
                        size: 16, color: AppColors.warning),
                  ),
                ],
              ],
            );
          case 2:
            return AppTableText(c.phone ?? '-');
          case 3:
            return AppTableText(c.address ?? '-', muted: true);
          case 4:
            final active = c.isActive ?? false;
            return AppStatusPill(active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger);
          case 5:
            return _balanceText(c);
          default:
            return AppTableEditDelete(
              onEdit: () => _showEditDialog(context, c, false),
              onDelete: () => _confirmDelete(context, c),
              extra: [
                AppTableAction(
                  icon: c.specialCustomer
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  tooltip: c.specialCustomer
                      ? 'Remove special status'
                      : 'Mark as special',
                  color: c.specialCustomer
                      ? AppColors.warning
                      : AppColors.greyColor(context),
                  onPressed: () => _toggleSpecialCustomer(context, c),
                ),
              ],
            );
        }
      },
    );
  }

  /// Due লাল, Advance সবুজ, শূন্য হলে ধূসর — নিচে ছোট করে কোনটা
  Widget _balanceText(CustomerModel customer) {
    final dueAnalysis = customer.paymentBreakdown?.calculation?.dueAnalysis;
    final double netDue =
        (dueAnalysis?.netDueAfterAdvance as num?)?.toDouble() ?? 0.0;
    final double advance =
        (dueAnalysis?.remainingAdvanceBalance as num?)?.toDouble() ?? 0.0;

    if (netDue > 0) {
      return AppTableText('৳${netDue.toStringAsFixed(2)}',
          align: AppCellAlign.end,
          bold: true,
          color: AppColors.danger,
          subtitle: 'Due');
    }
    if (advance > 0) {
      return AppTableText('৳${advance.toStringAsFixed(2)}',
          align: AppCellAlign.end,
          bold: true,
          color: AppColors.success,
          subtitle: 'Advance');
    }
    return const AppTableText('৳0.00',
        align: AppCellAlign.end, muted: true, subtitle: 'Settled');
  }

  Future<void> _confirmDelete(BuildContext context, CustomerModel customer) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    if (context.mounted) {
      context.read<CustomerBloc>().add(DeleteCustomer(customer.id.toString()));
    }
  }

  void _toggleSpecialCustomer(BuildContext context, CustomerModel customer) {
    final action = customer.specialCustomer ? 'set_false' : 'set_true';
    final message = customer.specialCustomer
        ? 'Remove ${customer.name} from special customers?'
        : 'Mark ${customer.name} as special customer?';

    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverCard(
          title: Text(
            customer.specialCustomer ? 'Remove Special Status' : 'Mark as Special',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<CustomerBloc>().add(
                  ToggleSpecialCustomer(
                    context: context,
                    customerId: customer.id.toString(),
                    action: action,
                  ),
                );
              },
              child: Text(
                customer.specialCustomer ? 'Remove' : 'Mark Special',
                style: TextStyle(
                  color: customer.specialCustomer ? AppColors.danger : Colors.amber,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showEditDialogMobile(BuildContext context, CustomerModel customer, bool isMobile) {
    // Pre-fill form
    final customerBloc = context.read<CustomerBloc>();
    customerBloc.customerNameController.text = customer.name ?? "";
    customerBloc.customerNumberController.text = customer.phone ?? "";
    customerBloc.addressController.text = customer.address ?? "";
    customerBloc.customerEmailController.text = customer.email?.toString() ?? "";
    customerBloc.selectedState = customer.isActive == true ? "Active" : "Inactive";

    // You'll need to update your CreateCustomerScreen to handle specialCustomer
    // For now, we'll pass it in the customer data
    final Map<String, dynamic> customerData = {
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'is_active': customer.isActive,
      'special_customer': customer.specialCustomer,
    };

    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.55,
              maxHeight: AppSizes.height(context) * 0.8,
            ),
            child: MobileCreateCustomerScreen(
              id: customer.id.toString(),
              submitText: "Update Customer",
              customer: customerData,
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, CustomerModel customer, bool isMobile) {
    // Pre-fill form
    final customerBloc = context.read<CustomerBloc>();
    customerBloc.customerNameController.text = customer.name ?? "";
    customerBloc.customerNumberController.text = customer.phone ?? "";
    customerBloc.addressController.text = customer.address ?? "";
    customerBloc.customerEmailController.text = customer.email?.toString() ?? "";
    customerBloc.selectedState = customer.isActive == true ? "Active" : "Inactive";

    // You'll need to update your CreateCustomerScreen to handle specialCustomer
    // For now, we'll pass it in the customer data
    final Map<String, dynamic> customerData = {
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'is_active': customer.isActive,
      'special_customer': customer.specialCustomer,
    };

    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.55,
              maxHeight: AppSizes.height(context) * 0.8,
            ),
            child: CreateCustomerScreen(
              id: customer.id.toString(),
              submitText: "Update Customer",
            ),
          ),
        );
      },
    );
  }
}