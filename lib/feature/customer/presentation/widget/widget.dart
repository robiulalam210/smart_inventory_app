
import '../../../../core/configs/configs.dart';
import '../../../../core/utilities/app_url_launcher.dart';
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 8, vertical: 4),
      itemCount: customers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildCustomerCard(customers[index], context),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.text(context);
    final primary = AppColors.primaryColor(context);
    final special = customer.specialCustomer;
    final active = customer.isActive ?? false;
    final name = (customer.name ?? '').trim();
    final phone = (customer.phone ?? '').trim();
    final address = (customer.address ?? '').trim();
    final accent = special ? AppColors.warning : primary;
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    // ── বকেয়া / অগ্রিম হিসাব (আগের নিয়মই) ──
    final dueAnalysis = customer.paymentBreakdown?.calculation?.dueAnalysis;
    final double netDue =
        (dueAnalysis?.netDueAfterAdvance as num?)?.toDouble() ?? 0.0;
    final double remainingAdvance =
        (dueAnalysis?.remainingAdvanceBalance as num?)?.toDouble() ?? 0.0;

    double amount;
    String label;
    Color balanceColor;
    if (netDue > 0) {
      amount = netDue;
      label = 'Due';
      balanceColor = AppColors.danger;
    } else if (remainingAdvance > 0) {
      amount = remainingAdvance;
      label = 'Advance';
      balanceColor = AppColors.success;
    } else {
      amount = 0.0;
      label = 'Settled';
      balanceColor = textColor.withValues(alpha: 0.5);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: special ? AppColors.warning.withValues(alpha: 0.5) : divider,
          width: special ? 1.2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── অবতার, নাম, ফোন, মেনু ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  name.isEmpty
                      ? '?'
                      : String.fromCharCode(name.runes.first).toUpperCase(),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isEmpty ? 'N/A' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (special) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Iconsax.call,
                          size: 13,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            phone.isEmpty ? 'No phone' : phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: textColor.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (phone.isNotEmpty)
                _roundAction(
                  icon: Iconsax.call,
                  color: AppColors.success,
                  onTap: () => _call(phone),
                ),
              PopupMenuButton<String>(
                tooltip: 'Actions',
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: textColor.withValues(alpha: 0.6),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      _showEditDialogMobile(context, customer, true);
                      break;
                    case 'special':
                      _toggleSpecialCustomer(context, customer);
                      break;
                    case 'delete':
                      _confirmDelete(context, customer);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  _menuItem('edit', Iconsax.edit, 'Edit', AppColors.info),
                  _menuItem(
                    'special',
                    special ? Icons.star_border_rounded : Icons.star_rounded,
                    special ? 'Remove special' : 'Mark as special',
                    AppColors.warning,
                  ),
                  _menuItem('delete', Iconsax.trash, 'Delete', AppColors.danger),
                ],
              ),
            ],
          ),

          // ── ট্যাগ: অবস্থা, ক্লায়েন্ট নং, ধরন ──
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppStatusPill(
                active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger,
              ),
              if ((customer.clientNo ?? '').isNotEmpty)
                _tag(context, '#${customer.clientNo}'),
              _tag(context, special ? 'Special' : 'Regular'),
            ],
          ),

          if (address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.location,
                  size: 14,
                  color: textColor.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ── বকেয়া / অগ্রিম ──
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: amount > 0
                  ? balanceColor.withValues(alpha: 0.09)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.65),
                  ),
                ),
                Text(
                  '৳${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: balanceColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String text) {
    final c = AppColors.text(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: c.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Future<void> _call(String phone) async {
    try {
      await appLaunchUrl(scheme: 'tel', path: phone);
    } catch (_) {
      // ডিভাইসে ফোন অ্যাপ না থাকলে চুপচাপ বাদ
    }
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