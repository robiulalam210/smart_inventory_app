import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/configs/configs.dart';
import '../../../accounts/data/model/account_model.dart';

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
    if (accounts.isEmpty) {
      return _buildEmptyState();
    }

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
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Accounts Summary',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  'Total: ${accounts.length} accounts',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 55,
                dataRowMaxHeight: 60,
                columnSpacing: 16,
                horizontalMargin: 16,
                dividerThickness: 0.5,
                headingRowHeight: 50,
                headingTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                headingRowColor: MaterialStateProperty.all(
                  AppColors.primaryColor,
                ),
                dataTextStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
                columns: const [
                  DataColumn(label: Text('No.', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Account Name', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Account Type', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Account Number', textAlign: TextAlign.center)),
                  DataColumn(label: Text('Balance', textAlign: TextAlign.center)),
                ],
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
                      DataCell(Center(child: Text('${entry.key + 1}'))),
                      DataCell(Center(child: Text(account.acName ?? "N/A"))),
                      DataCell(Center(child: Text(account.acType ?? "N/A"))),
                      DataCell(Center(child: Text(account.acNumber ?? "N/A"))),
                      _buildBalanceCellSimple(balanceValue),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildBalanceCellSimple(double? balanceValue) {
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
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: getAmountColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${getAmountPrefix()}\$${getAmountText()}',
            style: GoogleFonts.inter(
              color: getAmountColor(),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
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
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Accounts Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}