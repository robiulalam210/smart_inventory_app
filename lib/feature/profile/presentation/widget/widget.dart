// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../../core/configs/configs.dart';
// import '../../../accounts/data/model/account_model.dart';
//
// class AccountCard extends StatelessWidget {
//   final List<AccountModel> accounts;
//   final VoidCallback? onAccountTap;
//   final Function(AccountModel)? onEdit;
//   final Function(AccountModel)? onDelete;
//
//   const AccountCard({
//     super.key,
//     required this.accounts,
//     this.onAccountTap,
//     this.onEdit,
//     this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (accounts.isEmpty) {
//       return _buildEmptyState();
//     }
//
//     final verticalScrollController = ScrollController();
//     final horizontalScrollController = ScrollController();
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Calculate total width needed for all columns
//         const numColumns = 7; // Added one column for actions
//         const columnSpacing = 10.0;
//         const horizontalMargin = 12.0;
//         const minColumnWidth = 120.0;
//
//         // Calculate total table width
//         final totalTableWidth = (constraints.maxWidth-75) +
//             (columnSpacing * (numColumns - 1)) +
//             (horizontalMargin * 2);
//
//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withValues(alpha: 0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Scrollbar(
//             controller: verticalScrollController,
//             thumbVisibility: true,
//             child: SingleChildScrollView(
//               controller: verticalScrollController,
//               scrollDirection: Axis.vertical,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Scrollbar(
//                   controller: horizontalScrollController,
//                   thumbVisibility: true,
//                   child: SingleChildScrollView(
//                     controller: horizontalScrollController,
//                     scrollDirection: Axis.horizontal,
//                     child: Container(
//                       constraints: BoxConstraints(
//                         minWidth: totalTableWidth,
//                         minHeight: 200,
//                       ),
//                       child: DataTable(
//                         dataRowMinHeight: 50,
//                         dataRowMaxHeight: 60,
//                         columnSpacing: columnSpacing,
//                         horizontalMargin: horizontalMargin,
//                         dividerThickness: 0.5,
//                         headingRowHeight: 50,
//                         headingTextStyle: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: GoogleFonts.inter().fontFamily,
//                         ),
//                         headingRowColor: WidgetStateProperty.all(
//                           AppColors.primaryColor,
//                         ),
//                         dataTextStyle: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500,
//                           fontFamily: GoogleFonts.inter().fontFamily,
//                         ),
//                         columns: _buildColumns(minColumnWidth),
//                         rows: accounts.asMap().entries.map((entry) {
//                           final account = entry.value;
//                           return DataRow(
//                             color: WidgetStateProperty.resolveWith<Color?>(
//                                   (Set<WidgetState> states) {
//                                 if (entry.key.isEven) {
//                                   return Colors.grey.withValues(alpha: 0.03);
//                                 }
//                                 return null;
//                               },
//                             ),
//                             onSelectChanged: onAccountTap != null
//                                 ? (_) => onAccountTap!()
//                                 : null,
//                             cells: [
//                               _buildDataCell(account.acNo ?? "N/A", minColumnWidth * 1.2),
//                               _buildDataCell(account.acName ?? "N/A", minColumnWidth * 1.2),
//                               _buildDataCell(account.acType ?? "N/A", minColumnWidth),
//                               _buildDataCell(account.acNumber ?? "-", minColumnWidth),
//                               _buildBankCell(account.bankName, account.branch, minColumnWidth * 1.3),
//                               _buildBalanceCell(account.balance, minColumnWidth),
//                               _buildActionsCell(context,account, minColumnWidth * 0.8),
//                             ],
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   List<DataColumn> _buildColumns(double columnWidth) {
//     return [
//       DataColumn(
//         label: SizedBox(
//           width: columnWidth * 0.6,
//           child: const Text(
//             'No.',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//       DataColumn(
//         label: SizedBox(
//           width: columnWidth * 1.2,
//           child: const Text(
//             'Account Name',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//       DataColumn(
//         label: SizedBox(
//           width: columnWidth,
//           child: const Text(
//             'Type',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//       DataColumn(
//         label: SizedBox(
//           width: columnWidth,
//           child: const Text(
//             'Account No.',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//       DataColumn(
//         label: SizedBox(
//           width: columnWidth * 1.3,
//           child: const Text(
//             'Bank/Branch',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//       DataColumn(
//         label: SizedBox(
//           width: columnWidth,
//           child: const Text(
//             'Balance',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//       DataColumn(
//         label: SizedBox(
//           width: columnWidth * 0.8,
//           child: const Text(
//             'Actions',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     ];
//   }
//
//   DataCell _buildDataCell(String text, double width) {
//     return DataCell(
//       Container(
//         width: width,
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//           textAlign: TextAlign.center,
//           overflow: TextOverflow.ellipsis,
//           maxLines: 2,
//         ),
//       ),
//     );
//   }
//
//   DataCell _buildBankCell(String? bankName, String? branch, double width) {
//     final hasBankInfo = bankName != null && bankName.isNotEmpty && bankName != "-";
//     final hasBranch = branch != null && branch.isNotEmpty && branch != "-";
//
//     String displayText;
//     if (hasBankInfo && hasBranch) {
//       displayText = '$bankName\n$branch';
//     } else if (hasBankInfo) {
//       displayText = bankName;
//     } else {
//       displayText = '-';
//     }
//
//     return DataCell(
//       Container(
//         width: width,
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         child: Text(
//           displayText,
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: hasBankInfo ? Colors.black87 : Colors.grey,
//           ),
//           textAlign: TextAlign.center,
//           overflow: TextOverflow.ellipsis,
//           maxLines: 2,
//         ),
//       ),
//     );
//   }
//
//   DataCell _buildBalanceCell(double? balanceValue, double width) {
//     Color getAmountColor() {
//       if (balanceValue == null) return Colors.grey;
//       if (balanceValue < 0) return Colors.red;
//       if (balanceValue > 0) return Colors.green;
//       return Colors.grey;
//     }
//
//     String getAmountText() {
//       if (balanceValue == null) return "N/A";
//       return balanceValue.abs().toStringAsFixed(2);
//     }
//
//     String getAmountPrefix() {
//       if (balanceValue == null) return "";
//       if (balanceValue < 0) return "-";
//       if (balanceValue > 0) return "+";
//       return "";
//     }
//
//     final color = getAmountColor();
//
//     return DataCell(
//       Container(
//         width: width,
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(
//                 color: color.withValues(alpha: 0.3),
//                 width: 1,
//               ),
//             ),
//             constraints: const BoxConstraints(
//               minWidth: 80,
//             ),
//             child: Text(
//               '${getAmountPrefix()}${getAmountText()}',
//               style: GoogleFonts.inter(
//                 color: color,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 11,
//               ),
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   DataCell _buildActionsCell(BuildContext context,AccountModel account, double width) {
//     return DataCell(
//       Container(
//         width: width,
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Edit Button
//             IconButton(
//               icon: Icon(
//                 Iconsax.edit,
//                 size: 18,
//                 color: Colors.blue,
//               ),
//               onPressed: () => onEdit?.call(account),
//               padding: const EdgeInsets.all(4),
//               constraints: const BoxConstraints(),
//               tooltip: 'Edit Account',
//             ),
//
//             // Delete Button
//             IconButton(
//               icon: Icon(
//                 HugeIcons.strokeRoundedDeleteThrow,
//                 size: 18,
//                 color: Colors.red.shade600,
//               ),
//               onPressed: () => _showDeleteConfirmation(context, account),
//               padding: const EdgeInsets.all(4),
//               constraints: const BoxConstraints(),
//               tooltip: 'Delete Account',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteConfirmation(BuildContext context, AccountModel account) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Icon(
//                 Icons.warning_amber_rounded,
//                 color: Colors.orange.shade600,
//                 size: 24,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Delete Account',
//                 style: GoogleFonts.inter(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Are you sure you want to delete this account?',
//                 style: GoogleFonts.inter(
//                   fontSize: 14,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       account.acName ?? 'Unnamed Account',
//                       style: GoogleFonts.inter(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     if (account.acNumber != null && account.acNumber!.isNotEmpty)
//                       Text(
//                         'Account: ${account.acNumber}',
//                         style: GoogleFonts.inter(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     if (account.acType != null && account.acType!.isNotEmpty)
//                       Text(
//                         'Type: ${account.acType}',
//                         style: GoogleFonts.inter(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'This action cannot be undone.',
//                 style: GoogleFonts.inter(
//                   fontSize: 12,
//                   color: Colors.red.shade600,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.inter(
//                   color: Colors.grey.shade600,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onDelete?.call(account);
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.red.shade50,
//               ),
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.inter(
//                   color: Colors.red.shade700,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(alpha: 0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.account_balance_wallet_outlined,
//             size: 48,
//             color: Colors.grey.withValues(alpha: 0.5),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Accounts Found',
//             style: GoogleFonts.inter(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create your first account to get started',
//             style: GoogleFonts.inter(
//               fontSize: 12,
//               fontWeight: FontWeight.w400,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }