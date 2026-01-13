// lib/account_transfer/presentation/screens/account_transfer_screen.dart
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../data/model/account_transfer_model.dart';
import '../bloc/account_transfer/account_transfer_bloc.dart';
import 'account_transfer_form.dart';
import 'widget/account_transfer_card.dart';

class AccountTransferScreen extends StatefulWidget {
  const AccountTransferScreen({super.key});

  @override
  State<AccountTransferScreen> createState() => _AccountTransferScreenState();
}

class _AccountTransferScreenState extends State<AccountTransferScreen> {
  TextEditingController filterTextController = TextEditingController();
  ValueNotifier<String?> selectedStatusNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedTransferTypeNotifier = ValueNotifier(null);
  ValueNotifier<bool?> isReversalNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedFromAccountNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedToAccountNotifier = ValueNotifier(null);
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    _fetchApi();
  }

  void _fetchApi({
    String filterText = '',
    String? fromAccountId,
    String? toAccountId,
    String? status,
    String? transferType,
    bool? isReversal,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    context.read<AccountTransferBloc>().add(
      FetchAccountTransferList(
        context: context,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        status: status,
        transferType: transferType,
        isReversal: isReversal,
        startDate: startDate,
        endDate: endDate,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchTransferList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: filterTextController.text,
      status: selectedStatusNotifier.value,
      transferType: selectedTransferTypeNotifier.value,
      isReversal: isReversalNotifier.value,
      fromAccountId: selectedFromAccountNotifier.value,
      toAccountId: selectedToAccountNotifier.value,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Select',
      helpText: 'Select Date Range',
      confirmText: 'Done',
      cancelText: 'Cancel',
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _fetchTransferList();
    }
  }

  void _clearDateFilter() {
    setState(() {
      startDate = null;
      endDate = null;
    });
    _fetchTransferList();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: ResponsiveRow(
          spacing: 0,
          runSpacing: 0,
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return ResponsiveCol(
      xs: 0,
      sm: 1,
      md: 1,
      lg: 2,
      xl: 2,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: RefreshIndicator(
        color: AppColors.primaryColor(context),
        onRefresh: () async {
          _fetchApi();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<AccountTransferBloc, AccountTransferState>(
            listener: (context, state) {
              if (state is ExecuteTransferLoading) {
                appLoader(context, "Executing transfer, please wait...");
              } else if (state is ExecuteTransferSuccess) {

                Navigator.pop(context);
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: 'Transfer executed successfully',
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );
                _fetchApi();
              } else if (state is ExecuteTransferFailed) {
                Navigator.pop(context);                _fetchApi();

                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              } else if (state is ReverseTransferLoading) {
                appLoader(context, "Reversing transfer, please wait...");
              } else if (state is ReverseTransferSuccess) {
                Navigator.pop(context);
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: 'Transfer reversed successfully',
                  icon: Icons.refresh,
                  primaryColor: Colors.orange,
                );
                _fetchApi();
              } else if (state is ReverseTransferFailed) {
                Navigator.pop(context);
                _fetchApi();

                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              } else if (state is CancelTransferLoading) {
                appLoader(context, "Cancelling transfer, please wait...");
              } else if (state is CancelTransferSuccess) {
                Navigator.pop(context);
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: 'Transfer cancelled successfully',
                  icon: Icons.cancel,
                  primaryColor: Colors.grey,
                );
                _fetchApi();
              } else if (state is CancelTransferFailed) {
                Navigator.pop(context);
                _fetchApi();

                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }
            },
            child: Column(
              children: [
                _buildFilterRow(),
                const SizedBox(height: 16),
                _buildDateFilterRow(),
                const SizedBox(height: 16),
                SizedBox(
                  child: BlocBuilder<AccountTransferBloc, AccountTransferState>(
                    builder: (context, state) {
                      if (state is AccountTransferListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is AccountTransferListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(child: Lottie.asset(AppImages.noData));
                        } else {
                          return Column(
                            children: [
                              AccountTransferCard(
                                transfers: state.list,
                                onExecute: (transfer) {
                                  context.read<AccountTransferBloc>().add(
                                    ExecuteTransfer(
                                      context: context,
                                      transferId: transfer.id.toString(),
                                    ),
                                  );
                                },
                                onReverse: (transfer) {
                                  _showReverseDialog(context, transfer);
                                },
                                onCancel: (transfer) {
                                  _showCancelDialog(context, transfer);
                                },
                              ),
                              PaginationBar(
                                count: state.count,
                                totalPages: state.totalPages,
                                currentPage: state.currentPage,
                                pageSize: state.pageSize,
                                from: state.from,
                                to: state.to,
                                onPageChanged: (page) => _fetchTransferList(
                                  pageNumber: page,
                                  pageSize: state.pageSize,
                                ),
                                onPageSizeChanged: (newSize) =>
                                    _fetchTransferList(
                                      pageNumber: 1,
                                      pageSize: newSize,
                                    ),
                              ),
                            ],
                          );
                        }
                      } else if (state is AccountTransferListFailed) {
                        return Center(
                          child: Text(
                            'Failed to load transfers: ${state.content}',
                          ),
                        );
                      } else {
                        return Center(child: Lottie.asset(AppImages.noData));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReverseDialog(BuildContext context, AccountTransferModel transfer) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.refresh, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'Reverse Transfer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reverse this transfer?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
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
                    'Transfer #${transfer.transferNo}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From: ${transfer.fromAccount?.name ?? "Unknown"}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'To: ${transfer.toAccount?.name ?? "Unknown"}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Amount: ${transfer.amount ?? "0.00"}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reason (optional):',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason for reversal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AccountTransferBloc>().add(
                ReverseTransfer(
                  context: context,
                  transferId: transfer.id!,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
            ),
            child: Text(
              'Reverse',
              style: GoogleFonts.inter(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AccountTransferModel transfer) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Cancel Transfer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this transfer?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
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
                    'Transfer #${transfer.transferNo}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${transfer.status?.toUpperCase() ?? "UNKNOWN"}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _getStatusColor(transfer.status),
                    ),
                  ),
                  Text(
                    'Amount: ${transfer.amount ?? "0.00"}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reason (optional):',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason for cancellation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AccountTransferBloc>().add(
                CancelTransfer(
                  context: context,
                  transferId: transfer.id!,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade50,
            ),
            child: Text(
              'Cancel Transfer',
              style: GoogleFonts.inter(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔍 Search Field
        Expanded(
          child: CustomSearchTextFormField(
            isRequiredLabel: false,
            controller: filterTextController,
            onChanged: (value) => _fetchApi(filterText: value),
            onClear: () {
              filterTextController.clear();
              _fetchApi();
            },
            hintText: "Search Transfer No or Description",
          ),
        ),
        const SizedBox(width: 10),

        // 📋 Status Dropdown
        Expanded(
          child: AppDropdown<String>(
            hint: "Select Status",
            isNeedAll: true,
            isLabel: false,
            isRequired: false,
            value: selectedStatusNotifier.value,
            itemList: ['pending', 'completed', 'failed', 'cancelled'],
            onChanged: (newVal) {
              selectedStatusNotifier.value = newVal;
              _fetchApi(status: newVal);
            },
            validator: (value) => null,

            label: '',
          ),
        ),
        const SizedBox(width: 10),

        // 🔄 Transfer Type Dropdown
        Expanded(
          child: AppDropdown<String>(
            hint: "Transfer Type",
            isNeedAll: true,
            isLabel: false,
            isRequired: false,
            value: selectedTransferTypeNotifier.value,
            itemList: ['internal', 'external', 'adjustment'],
            onChanged: (newVal) {
              selectedTransferTypeNotifier.value = newVal;
              _fetchApi(transferType: newVal);
            },
            validator: (value) => null,

            label: '',
          ),
        ),
        const SizedBox(width: 10),

        // ➕ Create Transfer Button
        AppButton(
          name: "Create Transfer",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: SizedBox(
                    width: AppSizes.width(context) * 0.60,
                    height: 550,
                    child: const AccountTransferForm(),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(width: 10),

        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildDateFilterRow() {
    return Row(
      children: [
        // Date Range Picker Button
        AppButton(
          name: startDate != null && endDate != null
              ? "${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}"
              : "Select Date Range",
          onPressed: () => _showDateRangePicker(context),
          color: startDate != null && endDate != null
              ? AppColors.primaryColor(context).withValues(alpha: 0.8)
              : AppColors.primaryColor(context),
        ),

        // Clear Date Button (only shown when date is selected)
        if (startDate != null && endDate != null) ...[
          const SizedBox(width: 10),
          AppButton(
            name: "Clear Date",
            color: AppColors.secondary(context),
            onPressed: _clearDateFilter,
          ),
        ],

        const Spacer(),

        // Reversal Filter
        Row(
          children: [
            const Text("Reversal Only:"),
            const SizedBox(width: 8),
            Switch(
              value: isReversalNotifier.value ?? false,
              onChanged: (value) {
                isReversalNotifier.value = value;
                _fetchApi(isReversal: value);
              },
              activeThumbColor: AppColors.primaryColor(context),
            ),
          ],
        ),
      ],
    );
  }
}