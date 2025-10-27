import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/configs/configs.dart';
import '../../data/model/account_model.dart';

class AccountCard extends StatelessWidget {
  final List<AccountModel> accounts;
  final VoidCallback? onAccountTap;

  const AccountCard({
    super.key,
    required this.accounts,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 5;
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

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
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 50,
                          dataRowMaxHeight: 60,
                          columnSpacing: 0,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 50,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: accounts.asMap().entries.map((entry) {
                            final account = entry.value;
                            final balanceValue = account.balance != null
                                ? double.tryParse(account.balance.toString())
                                : null;

                            return DataRow(
                              onSelectChanged: onAccountTap != null
                                  ? (_) => onAccountTap!()
                                  : null,
                              cells: [
                                _buildDataCell('${entry.key + 1}', dynamicColumnWidth),
                                _buildDataCell(account.acName ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(account.acType ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(account.acNumber ?? "N/A", dynamicColumnWidth),
                                _buildBalanceCell(balanceValue, dynamicColumnWidth),
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

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('No.', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Account Name', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Account Type', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Account Number', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Balance', textAlign: TextAlign.center),
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
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildBalanceCell(double? balanceValue, double width) {
    Color getAmountColor() {
      if (balanceValue == null) return Colors.grey;
      if (balanceValue < 0) return Colors.red;
      if (balanceValue > 0) return Colors.green;
      return Colors.grey;
    }

    String getAmountText() {
      if (balanceValue == null) return "N/A";
      return balanceValue.abs().toStringAsFixed(2);
    }

    String getAmountPrefix() {
      if (balanceValue == null) return "";
      if (balanceValue < 0) return "-";
      if (balanceValue > 0) return "+";
      return "";
    }

    return DataCell(
      SizedBox(
        width: width,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: getAmountColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${getAmountPrefix()}\$${getAmountText()}',
            style: TextStyle(
              color: getAmountColor(),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}