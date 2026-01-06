import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/date_range.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../products/product/presentation/widget/pagination.dart';
import 'bad_stock_list/bad_stock_list_bloc.dart';
import 'data/model/bad_stock_return/bad_stock_return_model.dart';

class MobileBadStockScreen extends StatefulWidget {
  const MobileBadStockScreen({super.key});

  @override
  State<MobileBadStockScreen> createState() => _BadStockScreenState();
}

class _BadStockScreenState extends State<MobileBadStockScreen> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime now = DateTime.now();
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    startDate = DateTime(now.year, now.month - 1, now.day);
    endDate = DateTime(now.year, now.month, now.day);

    // Load initial data
    _fetchBadStockList(from: startDate, to: endDate);
  }

  void _fetchBadStockList({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int? location,
    int pageNumber = 0,
  }) {
    context.read<BadStockListBloc>().add(FetchBadStockList(
      context,
      filterText: filterText,
      from: from,
      to: to,
      location: location,
      pageNumber: pageNumber,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bad Stock", style: AppTextStyle.titleMedium(context)),
      ),
      body: SafeArea(
        child: _buildContentArea(),
      ),
    );
  }

  Widget _buildContentArea() {
    return ResponsiveCol(
      xs: 12,
      lg: 10,
      child: RefreshIndicator(
        onRefresh: () async => _fetchBadStockList(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildFilterRow(),
              const SizedBox(height: 16),
              SizedBox(child: _buildDataTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600; // adjust breakpoint if needed

    void _refreshWithCurrentFilters() {
      _fetchBadStockList(
        filterText: filterTextController.text,
        from: selectedDateRange?.start ?? startDate,
        to: selectedDateRange?.end ?? endDate,
      );
    }

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Field - full width on mobile
          CustomSearchTextFormField(
            isRequiredLabel: false,
            controller: filterTextController,
            onChanged: (value) => _fetchBadStockList(
              filterText: value,
              from: selectedDateRange?.start ?? startDate,
              to: selectedDateRange?.end ?? endDate,
            ),
            onClear: () {
              filterTextController.clear();
              _fetchBadStockList(
                filterText: '',
                from: selectedDateRange?.start ?? startDate,
                to: selectedDateRange?.end ?? endDate,
              );
            },
            hintText: "by Product Name, Reason, or Reference",
          ),
          const SizedBox(height: 8),

          // Date range + refresh on same row
          Row(
            children: [
              Expanded(
                child: CustomDateRangeField(
                  isLabel: false,
                  selectedDateRange: selectedDateRange,
                  onDateRangeSelected: (value) {
                    setState(() => selectedDateRange = value);
                    if (value != null) {
                      _fetchBadStockList(
                        filterText: filterTextController.text,
                        from: value.start,
                        to: value.end,
                      );
                    } else {
                      _refreshWithCurrentFilters();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _refreshWithCurrentFilters,
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh",
              ),
            ],
          ),
        ],
      );
    }

    // Desktop / wide: original horizontal layout but preserving filters
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 350,
          child: CustomSearchTextFormField(
            isRequiredLabel: false,
            controller: filterTextController,
            onChanged: (value) => _fetchBadStockList(
              filterText: value,
              from: selectedDateRange?.start ?? startDate,
              to: selectedDateRange?.end ?? endDate,
            ),
            onClear: () {
              filterTextController.clear();
              _fetchBadStockList(
                filterText: '',
                from: selectedDateRange?.start ?? startDate,
                to: selectedDateRange?.end ?? endDate,
              );
            },
            hintText: "by Product Name, Reason, or Reference",
          ),
        ),
        const SizedBox(width: 12),

        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchBadStockList(
                  filterText: filterTextController.text,
                  from: value.start,
                  to: value.end,
                );
              } else {
                _refreshWithCurrentFilters();
              }
            },
          ),
        ),
        const SizedBox(width: 12),

        IconButton(
          onPressed: _refreshWithCurrentFilters,
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }
  Widget _buildDataTable() {
    return BlocBuilder<BadStockListBloc, BadStockListState>(
      buildWhen: (previous, current) {
        return current is BadStockListLoading ||
            current is BadStockListSuccess ||
            current is BadStockListFailed;
      },
      builder: (context, state) {
        if (state is BadStockListLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading bad stock records..."),
              ],
            ),
          );
        } else if (state is BadStockListSuccess) {
          if (state.list.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              SizedBox(
                child: BadStockTableCard(badStocks: state.list),
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
                  _fetchBadStockList(
                    pageNumber: page,
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                  );
                },
                onPageSizeChanged: (newSize) {
                  _fetchBadStockList(pageNumber: 0);
                },
              ),
            ],
          );
        } else if (state is BadStockListFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 16),
          Text(
            "No bad stock records found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bad stock records will appear here when created",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetchBadStockList(),
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error loading bad stock records",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetchBadStockList(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class BadStockTableCard extends StatelessWidget {
  final List<BadStockReturnModel> badStocks;
  final VoidCallback? onBadStockTap;

  const BadStockTableCard({
    super.key,
    required this.badStocks,
    this.onBadStockTap,
  });

  @override
  Widget build(BuildContext context) {
    if (badStocks.isEmpty) {
      return _buildEmptyState();
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600; // adjust breakpoint as needed

    if (isMobile) {
      return _buildMobileList(context);
    }

    // Desktop / Tablet: existing DataTable layout
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 6; // Product, Quantity, Reason, Date, Reference, Actions
        const minColumnWidth = 120.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

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
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: badStocks.asMap().entries.map((entry) {
                            final badStock = entry.value;
                            return DataRow(
                              onSelectChanged: onBadStockTap != null
                                  ? (_) => onBadStockTap!()
                                  : null,
                              cells: [
                                _buildDataCell(badStock.productName ?? 'Unknown', dynamicColumnWidth),
                                _buildDataCell(badStock.quantity.toString(), dynamicColumnWidth),
                                _buildReasonCell(badStock.reason, dynamicColumnWidth),
                                _buildDateCell(badStock.date, dynamicColumnWidth),
                                _buildReferenceCell(badStock, dynamicColumnWidth),
                                _buildActionCell(badStock, context, dynamicColumnWidth),
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

  // MOBILE LIST
  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badStocks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final badStock = badStocks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primaryColor,
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
                            badStock.productName ?? 'Unknown Product',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qty: ${badStock.quantity ?? 0}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(badStock.date),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          badStock.referenceType != null
                              ? '${badStock.referenceType} #${badStock.referenceId}'
                              : 'No Ref',
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
                if ((badStock.reason ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Reason:',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      badStock.reason ?? 'No reason provided',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _showViewDialog(context, badStock),
                      icon: Icon(HugeIcons.strokeRoundedView, color: Colors.green, size: 20),
                      tooltip: 'View bad stock details',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmDelete(context, badStock),
                      icon: Icon(HugeIcons.strokeRoundedDeleteThrow, color: Colors.red, size: 20),
                      tooltip: 'Delete bad stock',
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

  // ----- EXISTING TABLE HELPERS -----
  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Product', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Quantity', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Reason', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Date', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Reference', textAlign: TextAlign.center),
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

  DataCell _buildReasonCell(String? reason, double width) {
    return DataCell(
      Tooltip(
        message: reason ?? 'No reason provided',
        child: SizedBox(
          width: width,
          child: Text(
            reason ?? 'No reason',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  DataCell _buildDateCell(DateTime? date, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildReferenceCell(BadStockReturnModel badStock, double width) {
    final referenceText = '${badStock.referenceType} #${badStock.referenceId}';

    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          referenceText,
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

  DataCell _buildActionCell(BadStockReturnModel badStock, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // View Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedView,
              color: Colors.green,
              tooltip: 'View bad stock details',
              onPressed: () => _showViewDialog(context, badStock),
            ),

            // Delete Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedDeleteThrow,
              color: Colors.red,
              tooltip: 'Delete bad stock',
              onPressed: () => _confirmDelete(context, badStock),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context, BadStockReturnModel badStock) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      // Adjust based on your BLoC implementation
      // context.read<BadStockListBloc>().add(DeleteBadStock(id: badStock.id.toString()));
    }
  }

  void _showViewDialog(BuildContext context, BadStockReturnModel badStock) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: AppSizes.width(context) * 0.40,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bad Stock Details',
                    style: AppTextStyle.cardLevelHead(context),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Product:', badStock.productName ?? 'N/A'),
                  _buildDetailRow('Quantity:', badStock.quantity?.toString() ?? '0'),
                  _buildDetailRow('Reason:', badStock.reason ?? 'No reason provided'),
                  _buildDetailRow('Date:', _formatDate(badStock.date)),
                  _buildDetailRow('Reference Type:', badStock.referenceType ?? 'N/A'),
                  _buildDetailRow('Reference ID:', badStock.referenceId?.toString() ?? 'N/A'),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
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
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Bad Stock Records',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bad stock records will appear here when created',
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