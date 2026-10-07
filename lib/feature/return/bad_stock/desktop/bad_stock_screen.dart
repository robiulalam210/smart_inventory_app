import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/configs/configs.dart';
import '../../../../desktop/widgets/sidebar.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../bad_stock_list/bad_stock_list_bloc.dart';
import '../data/model/bad_stock_return/bad_stock_return_model.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class BadStockScreen extends StatefulWidget {
  const BadStockScreen({super.key});

  @override
  State<BadStockScreen> createState() => _BadStockScreenState();
}

class _BadStockScreenState extends State<BadStockScreen> {
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
  void dispose() {
    filterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() => ResponsiveCol(
    xs: 0,
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
    child: Container(color: Colors.white, child: const Sidebar()),
  );

  Widget _buildContentArea(bool isBigScreen) {
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🔍 Search Field
        SizedBox(
          width: 350,

          child: CustomSearchTextFormField(
            isRequiredLabel: false,
            controller: filterTextController,
            onChanged: (value) => _fetchBadStockList(filterText: value),
            onClear: () {
              filterTextController.clear();
              _fetchBadStockList();
            },
            hintText: "by Product Name, Reason, or Reference",
          ),
        ),
        const SizedBox(width: 12),

        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchBadStockList(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 12),

        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchBadStockList(),
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
          const Icon(Icons.error_outline, size: 60, color: AppColors.danger),
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
            style: const TextStyle(fontSize: 14, color: AppColors.danger),
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
  // Desktop টেবিল — AppDataTable
  Widget build(BuildContext context) {
    if (badStocks.isEmpty) {
      return _buildEmptyState();
    }

    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Product', flex: 4, minWidth: 180),
      AppTableColumn.numeric('Quantity', flex: 1, minWidth: 90),
      AppTableColumn('Reason', flex: 3, minWidth: 150),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Reference', flex: 2, minWidth: 130),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: badStocks.length,
      onRowTap: onBadStockTap == null ? null : (_) => onBadStockTap!(),
      cellBuilder: (context, row, col) {
        final b = badStocks[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(b.productName ?? 'Unknown', bold: true);
          case 2:
            return AppTableText('${b.quantity ?? 0}',
                align: AppCellAlign.end, bold: true, color: AppColors.danger);
          case 3:
            return AppTableText(b.reason ?? '-', muted: true);
          case 4:
            return AppTableText(_formatDate(b.date));
          case 5:
            return AppTableText('${b.referenceType ?? '-'} #${b.referenceId ?? ''}',
                muted: true);
          default:
            return AppTableEditDelete(
              onView: () => _showViewDialog(context, b),
              onDelete: () => _confirmDelete(context, b),
            );
        }
      },
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
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          child: Container(
            width: AppSizes.width(context) * 0.40,
            padding: const EdgeInsets.all(20),
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