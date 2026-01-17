import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/purchase_return_model.dart';
import '/core/configs/configs.dart';
import '/feature/supplier/data/model/supplier_active_model.dart';
import '/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/date_range.dart';
import '../../../../products/product/presentation/widget/pagination.dart';
import '../bloc/purchase_return/purchase_return_bloc.dart';
import 'create_purchase_return/create_purchase_return_screen.dart';

class MobilePurchaseReturnScreen extends StatefulWidget {
  const MobilePurchaseReturnScreen({super.key});

  @override
  State<MobilePurchaseReturnScreen> createState() =>
      _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<MobilePurchaseReturnScreen> {
  DateTime? startDate;
  DateTime? endDate;
  late DateTime now;
  final TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;
  SupplierActiveModel? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();

    // Safe "last 30 days" default (avoids month index subtraction bugs)
    endDate = DateTime(now.year, now.month, now.day);
    startDate = endDate!.subtract(const Duration(days: 30));

    // Load initial data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
      context.read<SupplierListBloc>().add(FetchSupplierList(context));
      _fetchPurchaseReturnList(from: startDate, to: endDate);
    });
  }

  @override
  void dispose() {
    filterTextController.dispose();
    super.dispose();
  }

  void _fetchPurchaseReturnList({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 0,
    String? supplierId,
  }) {
    // Keep filterText null when empty to match existing backend expectations
    context.read<PurchaseReturnBloc>().add(
      FetchPurchaseReturn(
        context,
        startDate: from,
        endDate: to,
        filterText: filterText.isNotEmpty ? filterText : null,
        pageNumber: pageNumber,
        // supplierId: supplierId // uncomment if your event supports this
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppSizes.width(context) * 0.90,
                    maxHeight: AppSizes.height(context) * 0.85,
                  ),
                  child: const CreatePurchaseReturnScreen(),
                ),
              );
            },
          ).then((_) {
            _fetchPurchaseReturnList(from: startDate, to: endDate);
          });
        },
        child: Icon(Icons.add,color: AppColors.whiteColor(context),),
      ),
      appBar: AppBar(
        title: Text(
          "Purchase Return",
          style: AppTextStyle.titleMedium(context),
        ),
      ),
      body: SafeArea(child: _buildContentArea()),
    );
  }

  Widget _buildContentArea() {
    return ResponsiveCol(
      xs: 12,
      lg: 10,
      child: RefreshIndicator(
        onRefresh: () async {
          _fetchPurchaseReturnList(
            filterText: filterTextController.text,
            from: selectedDateRange?.start ?? startDate,
            to: selectedDateRange?.end ?? endDate,
          );
          return Future.delayed(const Duration(milliseconds: 500));
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
            listener: (context, state) {
              if (state is PurchaseReturnCreateLoading) {
                appLoader(context, "Creating Purchase Return...");
              } else if (state is PurchaseReturnCreateSuccess) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.pop(context);
                }
                _fetchPurchaseReturnList(
                  filterText: filterTextController.text,
                  from: selectedDateRange?.start ?? startDate,
                  to: selectedDateRange?.end ?? endDate,
                );
                appAlertDialog(
                  context,
                  state.message,
                  title: "Success",
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (Navigator.of(context, rootNavigator: true).canPop()) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              } else if (state is PurchaseReturnDeleteLoading) {
                appLoader(context, "Deleting Purchase Return...");
              } else if (state is PurchaseReturnDeleteSuccess) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.pop(context);
                }
                _fetchPurchaseReturnList(
                  filterText: filterTextController.text,
                  from: selectedDateRange?.start ?? startDate,
                  to: selectedDateRange?.end ?? endDate,
                );
                appAlertDialog(
                  context,
                  state.message,
                  title: "Success",
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (Navigator.of(context, rootNavigator: true).canPop()) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              } else if (state is PurchaseReturnError) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.pop(context);
                }
                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (Navigator.of(context, rootNavigator: true).canPop()) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }

              // Refresh list on status change success events
              if (state is PurchaseReturnApproveSuccess ||
                  state is PurchaseReturnRejectSuccess ||
                  state is PurchaseReturnCompleteSuccess) {
                _fetchPurchaseReturnList(
                  filterText: filterTextController.text,
                  from: selectedDateRange?.start ?? startDate,
                  to: selectedDateRange?.end ?? endDate,
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and clear filters
                _buildFilterRow(),
                const SizedBox(height: 8),
                SizedBox(child: _buildDataTable()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Responsive filter row: stacked on narrow screens, wrap on wider screens
  Widget _buildFilterRow() {
    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {

            void refreshWithCurrentFilters() {
              _fetchPurchaseReturnList(
                filterText: filterTextController.text,
                from: selectedDateRange?.start ?? startDate,
                to: selectedDateRange?.end ?? endDate,
                // supplierId: _selectedSupplier?.id?.toString(),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomSearchTextFormField(
                  isRequiredLabel: false,
                  controller: filterTextController,
                  onChanged: (value) {
                    if (value.length > 2 || value.isEmpty) {
                      _fetchPurchaseReturnList(
                        filterText: value,
                        from: selectedDateRange?.start ?? startDate,
                        to: selectedDateRange?.end ?? endDate,
                      );
                    }
                  },
                  onClear: () {
                    filterTextController.clear();
                    _fetchPurchaseReturnList(
                      filterText: '',
                      from: selectedDateRange?.start ?? startDate,
                      to: selectedDateRange?.end ?? endDate,
                    );
                  },
                  hintText: "Search by Receipt No, Supplier, or Reason",
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child:
                          BlocBuilder<
                            SupplierInvoiceBloc,
                            SupplierInvoiceState
                          >(
                            builder: (context, state) {
                              List<SupplierActiveModel> suppliers = [];
                              if (state is SupplierActiveListSuccess) {
                                suppliers = state.list;
                              }
                              if (state is SupplierInvoiceLoading) {
                                return const Center(
                                  child: SizedBox(
                                    height: 40,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final allSuppliersList = [
                                SupplierActiveModel(
                                  id: null,
                                  name: 'All Suppliers',
                                  phone: '',
                                ),
                                ...suppliers,
                              ];
                              return AppDropdown<SupplierActiveModel>(
                                label: "Supplier",
                                isSearch: true,
                                hint: "Select Supplier",
                                isNeedAll: false,
                                isRequired: false,
                                isLabel: true,
                                value: _selectedSupplier,
                                itemList: allSuppliersList,
                                onChanged: (newVal) {
                                  setState(() {
                                    _selectedSupplier = newVal?.id != null
                                        ? newVal
                                        : null;
                                  });
                                  _fetchPurchaseReturnList(
                                    from: selectedDateRange?.start ?? startDate,
                                    to: selectedDateRange?.end ?? endDate,
                                    supplierId: _selectedSupplier?.id
                                        ?.toString(),
                                  );
                                },
                              );
                            },
                          ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: refreshWithCurrentFilters,
                      icon: const Icon(Icons.refresh),
                      tooltip: "Refresh",
                    ),
                  ],
                ),
                CustomDateRangeField(
                  isLabel: true,
                  selectedDateRange: selectedDateRange,
                  onDateRangeSelected: (value) {
                    setState(() => selectedDateRange = value);
                    if (value != null) {
                      _fetchPurchaseReturnList(
                        from: value.start,
                        to: value.end,
                      );
                    } else {
                      _fetchPurchaseReturnList(from: startDate, to: endDate);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
      builder: (context, state) {
        if (state is PurchaseReturnLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading purchase returns..."),
              ],
            ),
          );
        } else if (state is PurchaseReturnSuccess) {
          if (state.list.isEmpty) {
            return _noDataWidget("No purchase returns found");
          }
          return Column(
            children: [
              SizedBox(
                child: PurchaseReturnTableCard(purchaseReturns: state.list),
              ),
              const SizedBox(height: 16),
              PaginationBar(
                count: state.count,
                totalPages: state.totalPages,
                currentPage: state.currentPage,
                pageSize: state.pageSize,
                from: state.from,
                to: state.to,
                onPageChanged: (page) {
                  _fetchPurchaseReturnList(
                    pageNumber: page,
                    from: selectedDateRange?.start ?? startDate,
                    to: selectedDateRange?.end ?? endDate,
                  );
                },
                onPageSizeChanged: (newSize) {
                  _fetchPurchaseReturnList(pageNumber: 0);
                },
              ),
            ],
          );
        } else if (state is PurchaseReturnError) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget _noDataWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppImages.noData,
            width: 200,
            height: 200,
            repeat: false,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _fetchPurchaseReturnList(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor(context),
              foregroundColor: Colors.white,
            ),
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error: $error",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _fetchPurchaseReturnList(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------------------------
   PurchaseReturnTableCard
   (keeps the same UI as before but includes a mobile-friendly list view)
   --------------------------------------------------------------------------- */

class PurchaseReturnTableCard extends StatelessWidget {
  final List<PurchaseReturnModel> purchaseReturns;
  final VoidCallback? onPurchaseReturnTap;

  const PurchaseReturnTableCard({
    super.key,
    required this.purchaseReturns,
    this.onPurchaseReturnTap,
  });

  @override
  Widget build(BuildContext context) {
    if (purchaseReturns.isEmpty) return _buildEmptyState();


    return _buildMobileList(context);


  }

  // Mobile list view
  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purchaseReturns.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pr = purchaseReturns[index];
        final statusColor = _getStatusColor(pr.status ?? '');
        return Card(

          color: AppColors.bottomNavBg(context),
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor(
                        context,
                      ).withValues(alpha: 0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pr.invoiceNo ?? 'N/A',
                            style:  TextStyle(
                              fontSize: 14,                color: AppColors.text(context),

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pr.supplier ?? 'N/A',
                            style:  TextStyle(
                              fontSize: 12,
                              color: AppColors.text(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          pr.returnAmount != null
                              ? pr.returnAmount!.toString()
                              : '0.00',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            (pr.status ?? 'N/A').toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if ((pr.reason ?? '').isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Reason:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      pr.reason ?? 'No reason provided',
                      style:  TextStyle(fontSize: 13,                color: AppColors.text(context),
                      ),
                    ),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _mobileActionButtons(context, pr),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _mobileActionButtons(
    BuildContext context,
    PurchaseReturnModel pr,
  ) {
    final List<Widget> actions = [];
    actions.add(
      _mobileIconButton(
        icon: Icons.visibility,
        color: Colors.green,
        tooltip: 'View',
        onPressed: () => _showViewDialog(context, pr),
      ),
    );
    final status = pr.status?.toLowerCase() ?? 'pending';
    if (status == 'pending') {
      actions.add(const SizedBox(width: 8));
      actions.add(
        _mobileIconButton(
          icon: Icons.edit,
          color: Colors.blue,
          tooltip: 'Edit',
          onPressed: () => _showEditDialog(context, pr),
        ),
      );
      actions.add(const SizedBox(width: 8));
      actions.add(
        _mobileIconButton(
          icon: Icons.check,
          color: Colors.green,
          tooltip: 'Approve',
          onPressed: () => _confirmApprove(context, pr),
        ),
      );
      actions.add(const SizedBox(width: 8));
      actions.add(
        _mobileIconButton(
          icon: Icons.close,
          color: Colors.red,
          tooltip: 'Reject',
          onPressed: () => _confirmReject(context, pr),
        ),
      );
    } else if (status == 'approved') {
      actions.add(const SizedBox(width: 8));
      actions.add(
        _mobileIconButton(
          icon: Icons.done,
          color: Colors.green,
          tooltip: 'Complete',
          onPressed: () => _confirmComplete(context, pr),
        ),
      );
    }
    if (status == 'pending' || status == 'rejected') {
      actions.add(const SizedBox(width: 8));
      actions.add(
        _mobileIconButton(
          icon: Icons.delete,
          color: Colors.red,
          tooltip: 'Delete',
          onPressed: () => _confirmDelete(context, pr),
        ),
      );
    }
    return actions;
  }

  Widget _mobileIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }




  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'approved':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateSafe(String dateString) {
    try {
      final d = DateTime.parse(dateString);
      return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
    } catch (_) {
      return dateString;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PurchaseReturnModel pr,
  ) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
        DeletePurchaseReturn(context, id: pr.id.toString()),
      );
    }
  }

  Future<void> _confirmApprove(
    BuildContext context,
    PurchaseReturnModel pr,
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Approve Purchase Return',
      content: 'Are you sure you want to approve this purchase return?',
    );
    if (confirmed && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
        PurchaseReturnApprove(id: pr.id.toString()),
      );
    }
  }

  Future<void> _confirmReject(
    BuildContext context,
    PurchaseReturnModel pr,
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Reject Purchase Return',
      content: 'Are you sure you want to reject this purchase return?',
    );
    if (confirmed && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
        PurchaseReturnReject(id: pr.id.toString()),
      );
    }
  }

  Future<void> _confirmComplete(
    BuildContext context,
    PurchaseReturnModel pr,
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Complete Purchase Return',
      content:
          'Are you sure you want to mark this purchase return as complete?',
    );
    if (confirmed && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
        PurchaseReturnComplete(id: pr.id.toString()),
      );
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bottomNavBg(context),
        title: Text(title,style: AppTextStyle.titleMedium(context),),
        content: Text(content,style: AppTextStyle.body(context),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor(context),
            ),
            child:  Text('Confirm',style: AppTextStyle.body(context),),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  void _showViewDialog(BuildContext context, PurchaseReturnModel pr) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.bottomNavBg(context),
          child: Container(
            width: AppSizes.width(context) * 0.50,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase Return Details - ${pr.invoiceNo ?? "N/A"}',
                    style: AppTextStyle.cardLevelHead(context),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Return No:', pr.invoiceNo ?? 'N/A'),
                  _buildDetailRow('Supplier:', pr.supplier ?? 'N/A'),
                  _buildDetailRow(
                    'Return Date:',
                    pr.returnDate != null
                        ? _formatDateSafe(pr.returnDate!)
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    'Total Amount:',
                    pr.returnAmount != null
                        ? pr.returnAmount!.toString()
                        : '0.00',
                  ),
                  _buildDetailRow(
                    'Status:',
                    pr.status?.toUpperCase() ?? 'PENDING',
                  ),
                  _buildDetailRow('Reason:', pr.reason ?? 'No reason provided'),
                  if (pr.items?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Returned Items:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...pr.items!.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.productName ?? 'Unknown Product',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text('Qty: ${item.quantity ?? 0}'),
                            const SizedBox(width: 16),
                            Text(
                              '\$${item.total?.toString() ?? "0.00"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  void _showEditDialog(BuildContext context, PurchaseReturnModel pr) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: AppSizes.width(context) * 0.60,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Purchase Return - ${pr.invoiceNo}',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 20),
                const Text('Edit functionality would be implemented here'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
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
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 16),
          Text(
            'No Purchase Returns Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase returns will appear here when created',
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
