import '../../../../../../core/configs/configs.dart';
import '../../../data/model/sales_return_model.dart';
import '../../sales_return_bloc/sales_return_bloc.dart';

class SalesReturnDataTableWidget extends StatelessWidget {
  final List<SalesReturnModel> salesReturns;

  const SalesReturnDataTableWidget({super.key, required this.salesReturns});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) => AppColors.primaryColor.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Receipt No', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Return Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Return Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Items', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: salesReturns.asMap().entries.map((entry) {
            final index = entry.key;
            final salesReturn = entry.value;

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return index % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent;
                },
              ),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  Text(
                    salesReturn .receiptNo?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(salesReturn.customerName ?? 'N/A')),
                DataCell(Text(_formatDate(salesReturn.returnDate??DateTime.now()))),
                DataCell(
                  Text(
                    '\$${salesReturn.returnAmount.toString()}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(salesReturn.status.toString()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      salesReturn.status.toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(salesReturn.paymentMethod ?? 'N/A')),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      salesReturn.reason ?? 'No reason provided',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${salesReturn.items?.length}',
                    textAlign: TextAlign.center,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 18),
                        onPressed: () {
                          // View details action
                          _viewSalesReturnDetails(context, salesReturn);
                        },
                        tooltip: "View Details",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () {
                          // Delete action
                          _deleteSalesReturn(context, salesReturn);
                        },
                        tooltip: "Delete",
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

  void _viewSalesReturnDetails(BuildContext context, SalesReturnModel salesReturn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sales Return - ${salesReturn.receiptNo}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer:', salesReturn.customerName ?? 'N/A'),
              _buildDetailRow('Return Date:', _formatDate(salesReturn.returnDate??DateTime.now())),
              _buildDetailRow('Return Amount:', '\$${salesReturn.returnAmount.toString()}'),
              _buildDetailRow('Status:', salesReturn.status.toString().toUpperCase()),
              _buildDetailRow('Payment Method:', salesReturn.paymentMethod ?? 'N/A'),
              _buildDetailRow('Reason:', salesReturn.reason ?? 'No reason provided'),

              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...?salesReturn.items?.map((item) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• ${item.productName} (Qty: ${item.quantity}) - \$${item.total.toString()}'),
                  )
              ).toList(),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _deleteSalesReturn(BuildContext context, SalesReturnModel salesReturn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sales Return'),
        content: Text('Are you sure you want to delete sales return ${salesReturn.receiptNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SalesReturnBloc>().add(
                  DeleteSalesReturn(context, salesReturn.id.toString())
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}