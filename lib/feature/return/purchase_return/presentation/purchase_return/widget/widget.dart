import 'package:flutter/material.dart';
import 'package:smart_inventory/core/configs/configs.dart';
import 'package:smart_inventory/feature/return/purchase_return/data/model/purchase_return_model.dart';

import '../../bloc/purchase_return/purchase_return_bloc.dart';

class PurchaseReturnDataTableWidget extends StatelessWidget {
  final List<PurchaseReturnModel> purchaseReturns;

  const PurchaseReturnDataTableWidget({super.key, required this.purchaseReturns});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.primaryColor.withOpacity(0.1)),
        columns: const [
          DataColumn(label: Text('Return No')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Total Amount')),
          DataColumn(label: Text('Reason')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: purchaseReturns.map((returnItem) {
          return DataRow(cells: [
            DataCell(Text(returnItem.invoiceNo ?? 'N/A')),
            DataCell(Text(returnItem.supplier ?? 'N/A')),
            DataCell(Text(returnItem.returnDate.toString())),
            DataCell(Text('\$${returnItem.returnAmount ?? '0.00'}')),
            DataCell(Text(returnItem.reason ?? 'N/A')),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(returnItem.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  returnItem.status ?? 'Pending',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    onPressed: () {
                      // View details action
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      // Edit action
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () {
                      // Delete action
                      context.read<PurchaseReturnBloc>().add(
                        DeletePurchaseReturn(context, id: returnItem.id.toString() ?? ''),
                      );
                    },
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
}