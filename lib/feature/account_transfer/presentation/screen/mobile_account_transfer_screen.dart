// lib/account_transfer/presentation/screens/account_transfer_screen.dart
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../data/model/account_transfer_model.dart';
import '../bloc/account_transfer/account_transfer_bloc.dart';
import 'mobile_account_transfer_form.dart';
import 'widget/account_transfer_card.dart';

class MobileAccountTransferScreen extends StatefulWidget {
  const MobileAccountTransferScreen({super.key});

  @override
  State<MobileAccountTransferScreen> createState() => _MobileAccountTransferScreenState();
}

class _MobileAccountTransferScreenState extends State<MobileAccountTransferScreen> {
  final TextEditingController filterTextController = TextEditingController();
  final ValueNotifier<String?> selectedStatusNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedTransferTypeNotifier = ValueNotifier(null);
  final ValueNotifier<bool?> isReversalNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedFromAccountNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedToAccountNotifier = ValueNotifier(null);

  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Initialize with default date range (last month)
    DateTime now = DateTime.now();
    selectedDateRange = DateRange(
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month, 0), // Last day of previous month
    );
    filterTextController.clear();
    _fetchApi();
  }

  @override
  void dispose() {
    filterTextController.dispose();
    selectedStatusNotifier.dispose();
    selectedTransferTypeNotifier.dispose();
    isReversalNotifier.dispose();
    selectedFromAccountNotifier.dispose();
    selectedToAccountNotifier.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    String? fromAccountId,
    String? toAccountId,
    String? status,
    String? transferType,
    bool? isReversal,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<AccountTransferBloc>().add(
      FetchAccountTransferList(
        context: context,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        status: status,
        transferType: transferType,
        isReversal: isReversal,
        startDate: selectedDateRange?.start, // Use DateRange values
        endDate: selectedDateRange?.end,     // Use DateRange values
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
    );
  }

  void _clearDateFilter() {
    setState(() {
      selectedDateRange = null;
    });
    _fetchTransferList();
  }

  void _clearAllFilters() {
    filterTextController.clear();
    selectedStatusNotifier.value = null;
    selectedTransferTypeNotifier.value = null;
    isReversalNotifier.value = null;
    selectedFromAccountNotifier.value = null;
    selectedToAccountNotifier.value = null;
    setState(() {
      selectedDateRange = null;
    });
    _fetchApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Account Transfers",style: AppTextStyle.titleMedium(context),),
        actions: [
          IconButton(
            onPressed: () => _fetchApi(),
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
          IconButton(
            onPressed: () => _showMobileFilterSheet(context),
            icon: const Icon(Icons.filter_alt),
            tooltip: "Filters",
          ),
        ],
      ),
      body: _buildContentArea(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MobileAccountTransferForm(),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContentArea() {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        _fetchApi();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMobileHeader(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildTransferList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomSearchTextFormField(
                isRequiredLabel: false,
                controller: filterTextController,
                onChanged: (value) => _fetchApi(filterText: value),
                onClear: () {
                  filterTextController.clear();
                  _fetchApi();
                },
                hintText: "Search transfers...",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (selectedStatusNotifier.value != null)
          Chip(
            label: Text(selectedStatusNotifier.value!.toUpperCase()),
            onDeleted: () {
              selectedStatusNotifier.value = null;
              _fetchApi();
            },
          ),
        if (selectedTransferTypeNotifier.value != null)
          Chip(
            label: Text(selectedTransferTypeNotifier.value!.toUpperCase()),
            onDeleted: () {
              selectedTransferTypeNotifier.value = null;
              _fetchApi();
            },
          ),
        if (isReversalNotifier.value == true)
          Chip(
            label: const Text('REVERSAL'),
            onDeleted: () {
              isReversalNotifier.value = null;
              _fetchApi();
            },
          ),
        if (selectedDateRange != null)
          Chip(
            label: Text(
              '${DateFormat('dd/MM').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(selectedDateRange!.end)}',
            ),
            onDeleted: _clearDateFilter,
          ),
      ],
    );
  }

  Widget _buildTransferList() {
    return BlocListener<AccountTransferBloc, AccountTransferState>(
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
          Navigator.pop(context);
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
      child: BlocBuilder<AccountTransferBloc, AccountTransferState>(
        builder: (context, state) {
          if (state is AccountTransferListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountTransferListSuccess) {
            if (state.list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(AppImages.noData, height: 200),
                    const SizedBox(height: 16),
                    Text(
                      'No transfers found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      name: "Clear Filters",
                      onPressed: _clearAllFilters,
                      color: AppColors.primaryColor.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  MobileAccountTransferCard(
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
                  const SizedBox(height: 16),
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
                    onPageSizeChanged: (newSize) => _fetchTransferList(
                      pageNumber: 1,
                      pageSize: newSize,
                    ),
                  ),
                ],
              );
            }
          } else if (state is AccountTransferListFailed) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load transfers',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.content,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    name: "Retry",
                    onPressed: () => _fetchApi(),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Lottie.asset(AppImages.noData));
          }
        },
      ),
    );
  }

  void _showMobileFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Transfers",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Date Range",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomDateRangeField(
                        isLabel: false,
                        selectedDateRange: selectedDateRange,
                        onDateRangeSelected: (value) {
                          setState(() {
                            selectedDateRange = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Filter
                  const Text(
                    "Status",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["All", "pending", "completed", "failed", "cancelled"].map((status) {
                      final bool isSelected =
                          selectedStatusNotifier.value == status ||
                              (status == "All" && selectedStatusNotifier.value == null);
                      return FilterChip(
                        label: Text(status.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedStatusNotifier.value = selected ? (status == "All" ? null : status) : null;
                          });
                        },
                        selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Transfer Type Filter
                  const Text(
                    "Transfer Type",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["All", "internal", "external", "adjustment"].map((type) {
                      final bool isSelected =
                          selectedTransferTypeNotifier.value == type ||
                              (type == "All" && selectedTransferTypeNotifier.value == null);
                      return FilterChip(
                        label: Text(type.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedTransferTypeNotifier.value = selected ? (type == "All" ? null : type) : null;
                          });
                        },
                        selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Reversal Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Reversal Only",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Switch(
                        value: isReversalNotifier.value ?? false,
                        onChanged: (value) {
                          setState(() {
                            isReversalNotifier.value = value;
                          });
                        },
                        activeThumbColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearAllFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Clear All"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchApi();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Apply Filters"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
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
}