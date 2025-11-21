import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meherin_mart/core/configs/app_images.dart';

// Dummy Product class definition for illustration (replace with your own)
class Product {
  final String? name;
  final num? totalSold;
  final num? totalPrice;

  Product({this.name, this.totalSold, this.totalPrice});
}

Widget topSelling(BuildContext context, List<Product> topProduct, {Widget? statistics}) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: topProduct.isNotEmpty
        ? ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (statistics != null) statistics, // Place stats above table if provided
            DataTable(
              columnSpacing: 5,
              dividerThickness: 0.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.orangeAccent.shade200),
              headingTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              columns: const [
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Total Sold')),
                DataColumn(label: Text('Total Amount')),
              ],
              rows: topProduct.map((product) {
                return DataRow(
                  cells: [
                    DataCell(Text(product.name ?? 'N/A')),
                    DataCell(Center(
                        child: Text(
                          product.totalSold?.toString() ?? 'N/A',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ))),
                    DataCell(Text(
                      product.totalPrice?.toString() ?? 'N/A',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    )
        : Center(
      child: Lottie.asset(
       AppImages.noData, // Use your Lottie file path
        width: 150,
        repeat: false,
      ),
    ),
  );
}