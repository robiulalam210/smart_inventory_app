import 'package:smart_inventory/core/configs/configs.dart';

import '../../products/product/presentation/widget/pagination.dart';
import 'bad_stock_list/bad_stock_list_bloc.dart';
import 'data/model/bad_stock_return/bad_stock_return_model.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/date_range.dart';


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
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bg,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 🔍 Search Field
        Expanded(
          flex: 2,
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

        // 🏢 Location Dropdown (if you have locations)


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
            return _noDataWidget("No bad stock records found");
          }
          return Column(
            children: [
              SizedBox(
                child: BadStockDataTableWidget(badStocks: state.list),
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
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget _noDataWidget(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(AppImages.noData, width: 200, height: 200),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
            onPressed: () => _fetchBadStockList(),
            child: const Text("Refresh")
        ),
      ],
    ),
  );

  Widget _errorWidget(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          "Error: $error",
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
            onPressed: () => _fetchBadStockList(),
            child: const Text("Retry")
        ),
      ],
    ),
  );
}
class BadStockDataTableWidget extends StatelessWidget {
  final List<BadStockReturnModel> badStocks;

  const BadStockDataTableWidget({super.key, required this.badStocks});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.primaryColor.withOpacity(0.1)),
            columns: const [
              DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Reference', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: badStocks.map((badStock) {
              return DataRow(cells: [
                DataCell(Text(badStock.productName ?? 'Unknown')),
                DataCell(Text(badStock.quantity?.toString() ?? '0')),
                DataCell(
                  Tooltip(
                    message: badStock.reason ?? '',
                    child: Text(
                      badStock.reason ?? 'No reason',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(badStock.date.toString() ?? 'Unknown date')),
                DataCell(Text('${badStock.referenceType} #${badStock.referenceId}')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () {
                          // View details
                          _showBadStockDetails(context, badStock);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () {
                          // Delete bad stock
                          _deleteBadStock(context, badStock);
                        },
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showBadStockDetails(BuildContext context, BadStockReturnModel badStock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bad Stock Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Product:', badStock.productName),
              _buildDetailRow('Quantity:', badStock.quantity?.toString()),
              _buildDetailRow('Reason:', badStock.reason),
              _buildDetailRow('Date:', badStock.date.toString()),
              _buildDetailRow('Reference Type:', badStock.referenceType),
              _buildDetailRow('Reference ID:', badStock.referenceId?.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value ?? 'Not available'),
          ),
        ],
      ),
    );
  }

  void _deleteBadStock(BuildContext context, BadStockReturnModel badStock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bad Stock'),
        content: Text('Are you sure you want to delete bad stock record for ${badStock.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // context.read<BadStockListBloc>().add(DeleteBadStock(badStock.id!, context));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}