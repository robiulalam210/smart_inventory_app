import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utilities/amount_counter.dart';
import '../../../../core/configs/configs.dart';
import '../../data/models/invoice_sync_response_model.dart';

class InvoiceSummaryBoxes extends StatelessWidget {
  final SummaryModel? summaryModel;

  const InvoiceSummaryBoxes({super.key, this.summaryModel});

  @override
  Widget build(BuildContext context) {
    if (summaryModel == null) {
      return const Center(
        child: Text(
          'No invoices found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '৳',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isWideScreen = screenWidth > 600;
          final boxWidth = isWideScreen ? screenWidth / 4 - 8 : screenWidth / 3 - 10;
          final boxWidth3item =  screenWidth / 3-10;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  _buildSummaryBox(
                    title: 'Total Amount :',
                    amount: summaryModel?.totalAmount ?? 0.0,
                    count: summaryModel?.invoiceCount,
                    borderColor: const Color(0xffecaa33),
                    rightBorderColor: const Color(0xffe8aba4),
                    bottomBorderColor: const Color(0xffe8aba4),
                    formatCurrency: formatCurrency,
                    width: boxWidth,
                  ),
                  _buildSummaryBox(
                    title: 'Discount :',
                    amount: summaryModel?.totalDiscount ?? 0.0,
                    count: summaryModel?.discountInvoiceCount,
                    borderColor: const Color(0xffecaa33),
                    rightBorderColor: const Color(0xffe8aba4),
                    bottomBorderColor: const Color(0xffe8aba4),
                    formatCurrency: formatCurrency,
                    width: boxWidth,
                  ),
                  _buildSummaryBox(
                    title: 'Net Amount :',
                    amount: summaryModel?.netAmount ?? 0.0,
                    count: summaryModel?.invoiceCount,
                    borderColor: const Color(0xffecaa33),
                    rightBorderColor: const Color(0xffe8aba4),
                    bottomBorderColor: const Color(0xffe8aba4),
                    formatCurrency: formatCurrency,
                    width: boxWidth,
                  ),
                  _buildSummaryBox(
                    title: 'Total Received :',
                    amount: summaryModel?.totalPaid ?? 0.0,
                    count: summaryModel?.receiptCount,
                    borderColor: const Color(0xffecaa33),
                    rightBorderColor: Colors.green,
                    bottomBorderColor: Colors.green,
                    formatCurrency: formatCurrency,
                    width: boxWidth,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.start,
                children: [
                  _buildSummaryBox(
                    title: 'Total Refund :',
                    amount: summaryModel != null
                        ? double.parse(summaryModel!.refundAmount.toStringAsFixed(0))
                        : 0.0,

                    count: summaryModel?.refundCount,
                    borderColor: const Color(0xffecaa33),
                    rightBorderColor: Colors.orange,
                    bottomBorderColor: Colors.orange,
                    formatCurrency: formatCurrency,
                    width: boxWidth3item,
                  ),
                  _buildSummaryBox(
                    title: 'Total Due :',
                    amount: summaryModel?.totalDue ?? 0.0,
                    count: summaryModel?.dueInvoiceCount,
                    borderColor: const Color(0xffecaa33),
                    rightBorderColor: Colors.orange,
                    bottomBorderColor: Colors.orange,
                    formatCurrency: formatCurrency,
                    width: boxWidth3item,
                  ),

                  _buildSummaryBox(
                    title: 'Due Collection :',
                    amount: summaryModel?.dueReceiptAmount ?? 0.0,
                    count: summaryModel?.dueReceiptCount,
                    borderColor: const Color(0xffecaa33),
                    rightBorderColor: Color(0xff006bff),
                    bottomBorderColor: Color(0xff006bff),
                    formatCurrency: formatCurrency,
                    width: boxWidth3item,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildSummaryBox({
    required String title,
    required double amount,
    required Color borderColor,
    required Color rightBorderColor,
    required Color bottomBorderColor, // <== NEW
    required NumberFormat formatCurrency,
    required double width,
    int? count,
  }) {
    return Container(
      width: width,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
          left: BorderSide(color: borderColor, width: 1),
          // ❌ Don't add bottom here if it's a different color
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and count
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (count != null)
                      Text(
                        count.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const Divider(height: 1, thickness: 2, color: Colors.grey),
                AnimatedAmountCounter(
                  amount: amount,
                  prefix: '৳ ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Right colored border
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 8,
            child: Container(
              decoration: BoxDecoration(
                color: rightBorderColor,
                border: Border.all(color: rightBorderColor, width: 0.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // ✅ Bottom colored border
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: bottomBorderColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

