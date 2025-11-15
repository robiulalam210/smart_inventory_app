import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_text.dart';
import '../../../../core/configs/configs.dart';
import 'top_selling.dart';
import 'package:flutter/material.dart';

Widget lowStock(BuildContext context, List<Product>? lowStockProducts) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: lowStockProducts?.isNotEmpty ?? false
        ? ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
        child: DataTable(
          columnSpacing: 5,
          dividerThickness: 0.5,
          headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.orangeAccent.shade200),
          headingTextStyle: AppTextStyle.cardTitle(context)
              .copyWith(color: AppColors.whiteColor),
          columns: const <DataColumn>[
            DataColumn(label: Text('Product Name')),
            DataColumn(label: Text('Quantity')),
          ],
          rows: List<DataRow>.generate(
            lowStockProducts?.length ?? 0,
                (index) {
              final lowStockProduct = lowStockProducts?[index];
              return DataRow(
                cells: [
                  DataCell(Text(
                      lowStockProduct?.name ?? 'N/A',
                      style: AppTextStyle.cardLevelText(context))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        lowStockProduct?.totalSold.toString() ?? '0',
                        style: AppTextStyle.cardTitle(context),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    )
        : Lottie.asset(AppImages.noData),
  );
}

class CustomerDue {
  final String? name;
  final String? due;

  CustomerDue({this.name, this.due});
}

// itemList is your list of CustomerDue, can be for customers or suppliers
Widget customer(
    BuildContext context, {
      required List<CustomerDue> lowStockProducts,
      String itemName = '',
      Widget? statistics, // Optional stats widget
    }) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: lowStockProducts.isNotEmpty
        ?ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
        child:  DataTable(
      columnSpacing: 5,
      dividerThickness: 0.5,
      headingRowColor: WidgetStateProperty.resolveWith(
              (states) => Colors.orangeAccent.shade200),
      headingTextStyle: AppTextStyle.cardTitle(context)
          .copyWith(color: AppColors.whiteColor),
      columns: <DataColumn>[
        DataColumn(label: Text('$itemName Name', )),
        const DataColumn(
          label: Text('Due',),
        ),
      ],
      rows: List<DataRow>.generate(
        lowStockProducts.length,
            (index) {
          final lowStockProduct = lowStockProducts[index];
          return DataRow(
            cells: [
              DataCell(Text(
                lowStockProduct.name ?? 'N/A',
                style: AppTextStyle.cardLevelHead(context),
              )),
              DataCell(
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    lowStockProduct.due ?? '0',
                    style: AppTextStyle.cardTitle(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    )))
        : Lottie.asset(AppImages.noData),
  );
}
