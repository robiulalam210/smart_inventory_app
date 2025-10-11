//
// import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart';
//
// import '../../../../../core/configs/configs.dart';
// import '../../../../../core/widgets/show_custom_toast.dart';
// import '../../bloc/lab_billing/lab_billing_bloc.dart';
//
//
// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({super.key});
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   late LabBillingBloc bloc;
//
//   @override
//   void initState() {
//     super.initState();
//     bloc = context.read<LabBillingBloc>();
//
//     // Initialize delivery date and time
//     bloc.dateDeliveryReport.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     bloc.timeDeliveryReport.text = "7:00 PM";
//
//     // Calculate initial discount and due amounts
//     calculateDiscountTotal();
//     calculateDueAmount();
//
//     // Add listeners to controllers to recalculate when text changes
//     bloc.discountController.addListener(() {
//       calculateDiscountTotal();
//       // setState(() {}); // Refresh UI on discount change
//     });
//     bloc.paidAmountController.addListener(() {
//       calculateDueAmount();
//       // setState(() {}); // Refresh UI on paid amount change
//     });
//   }
//
//   void calculateDiscountTotal() {
//     final discountValue = double.tryParse(bloc.discountController.text) ?? 0.0;
//
//     if (bloc.selectedOverallDiscountType == 'fixed') {
//       bloc.discountAmount = discountValue;
//       bloc.discountAmountPercentage = (bloc.discountAmount / bloc.testTotalDiscountApply) * 100;
//     } else if (bloc.selectedOverallDiscountType == 'percentage') {
//       bloc.discountAmount = (bloc.testTotalDiscountApply * discountValue) / 100;
//       bloc.discountAmountPercentage = discountValue;
//     }
//   }
//
//   void calculateDueAmount() {
//     bloc.paidAmount = double.tryParse(bloc.paidAmountController.text) ?? 0.0;
//     bloc.dueAmount = (bloc.totalAmount - bloc.discountAmount) - bloc.paidAmount;
//   }
//
//   void _selectPaymentMethod(String method) {
//     setState(() {
//       bloc.selectedPaymentMethod = method;
//     });
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         bloc.dateDeliveryReport.text = DateFormat('dd-MM-yyyy').format(picked);
//       });
//     }
//   }
//
//   Future<void> _selectTime(BuildContext context) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         bloc.timeDeliveryReport.text = picked.format(context);
//       });
//     }
//   }
//   final selectedType = bloc.selectedOverallDiscountType;
//   final validGroupValue = ['fixed', 'percentage'].contains(selectedType) ? selectedType : null;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LabBillingBloc, LabBillingState>(
//       builder: (context, state) {
//
//
//
//         return Container(
//           decoration: BoxDecoration(
//             color: AppColors.whiteColor,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Payment Methods Section
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey.shade400, width: 0.5),
//                     color: Colors.white,
//                   ),
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Payment", style: AppTextStyle.cardTitle(context)),
//                       PaymentMethod(
//                         image: "assets/images/cash.png",
//                         title: 'Cash',
//                         selectedPaymentMethod: bloc.selectedPaymentMethod,
//                         onSelected: () => _selectPaymentMethod('Cash'),
//                       ),
//                       PaymentMethod(
//                         image: "assets/images/card.png",
//                         title: 'Credit / Debit Card',
//                         selectedPaymentMethod: bloc.selectedPaymentMethod,
//                         onSelected: () => _selectPaymentMethod('Credit / Debit Card'),
//                       ),
//                       PaymentMethod(
//                         image: "assets/images/digital.png",
//                         title: 'Digital Payment',
//                         selectedPaymentMethod: bloc.selectedPaymentMethod,
//                         onSelected: () => _selectPaymentMethod('Digital Payment'),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 10),
//
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Left Payment Info Section
//                     Container(
//                       padding: EdgeInsets.all(10.0),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade400, width: 0.5),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       width: 450,
//                       child: Column(
//                         children: [
//                           // Sub Total
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Sub Total'),
//                               Text(bloc.totalAmount.toStringAsFixed(2)),
//                             ],
//                           ),
//                           SizedBox(height: 5),
//
//                           // Apply Discount Checkbox
//                           CheckboxListTile(
//                             activeColor: AppColors.primaryColor,
//                             contentPadding: EdgeInsets.zero,
//                             value: bloc.isDiscountApplied,
//                             onChanged: (value) {
//                               setState(() {
//                                 bloc.isDiscountApplied = value ?? false;
//                                 if (!bloc.isDiscountApplied) {
//                                   bloc.discountController.clear();
//                                   bloc.discountAmount = 0.0;
//                                 }
//                                 calculateDiscountTotal();
//                               });
//                             },
//                             title: Text("Apply Discount", style: AppTextStyle.cardTitle(context)),
//                           ),
//
//                           if (bloc.isDiscountApplied)
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 CupertinoSegmentedControl<String>(
//                                   padding: EdgeInsets.zero,
//                                   children: {
//                                     'fixed': Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
//                                       child: Text(
//                                         'Fixed',
//                                         style: TextStyle(
//                                           color: selectedType == 'fixed' ? Colors.white : Colors.black,
//                                         ),
//                                       ),
//                                     ),
//                                     'percentage': Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
//                                       child: Text(
//                                         'Percentage',
//                                         style: TextStyle(
//                                           color: selectedType == 'percentage' ? Colors.white : Colors.black,
//                                         ),
//                                       ),
//                                     ),
//                                   },
//                                   onValueChanged: (value) {
//                                     setState(() {
//                                       bloc.selectedOverallDiscountType = value;
//                                       bloc.discountController.clear();
//                                       calculateDiscountTotal();
//                                     });
//                                   },
//                                   groupValue: validGroupValue,
//                                   pressedColor: Colors.black45,
//                                   unselectedColor: AppColors.whiteColor,
//                                   selectedColor: AppColors.primaryColor,
//                                   borderColor: AppColors.primaryColor,
//                                 ),
//                                 SizedBox(
//                                   width: 100,
//                                   child: TextField(
//                                     controller: bloc.discountController,
//                                     decoration: InputDecoration(
//                                       fillColor: AppColors.whiteColor,
//                                       border: OutlineInputBorder(
//                                         borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
//                                       ),
//                                       filled: true,
//                                       hintStyle: AppTextStyle.cardLevelHead(context),
//                                       isCollapsed: true,
//                                       enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                         borderSide: BorderSide(color: AppColors.blackColor.withValues(alpha: 0.8), width: 0.5),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                         borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.8), width: 0.5),
//                                       ),
//                                       contentPadding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 12),
//                                       hintText: bloc.selectedOverallDiscountType == 'fixed' ? 'Discount' : '% (0-100)',
//                                     ),
//                                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
//                                       LengthLimitingTextInputFormatter(6),
//                                     ],
//                                       onChanged: (value) {
//
//                                         final amount = double.tryParse(value) ?? 0.0;
//
//                                       if (bloc.selectedOverallDiscountType == 'fixed') {
//                                         if (amount < 0) {
//                                           bloc.discountController.text = '0';
//                                         } else if (amount > bloc.testTotalDiscountApply) {
//                                           // Optional: allow user to type but show warning
//                                           showCustomToast(
//                                             context: context,
//                                             title: 'Warning!',
//                                             description: 'Discount exceeds total. Max applied.',
//                                             type: ToastificationType.warning,
//                                           );
//                                           bloc.discountController.text = bloc.testTotalDiscountApply.toStringAsFixed(2);
//                                         }
//                                         // else: valid input, no need to reset text
//                                       } else if (bloc.selectedOverallDiscountType == 'percentage') {
//                                           if (amount < 0) {
//                                             bloc.discountController.text = '0';
//                                           } else if (amount > 100) {
//                                             bloc.discountController.text = '100';
//                                           }
//
//
//                                         }
//
//                                         calculateDiscountTotal();
//                                         calculateDueAmount();
//                                         setState(() {});
//                                       }
//
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                           SizedBox(height: 10),
//
//                           // Discount Display
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Discount ${bloc.selectedOverallDiscountType != 'percentage' ? "(${bloc.discountAmountPercentage.toStringAsFixed(2)}%)" : ""}'),
//                               Text(bloc.discountAmount.toStringAsFixed(2)),
//                             ],
//                           ),
//
//                           SizedBox(height: 10),
//
//                           // Total after discount
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Total'),
//                               Text((bloc.totalAmount - bloc.discountAmount).toStringAsFixed(2)),
//                             ],
//                           ),
//
//                           SizedBox(height: 10),
//
//                           // Paid Amount Input
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Paid Amount'),
//                               SizedBox(
//                                 width: 100,
//                                 child: TextField(
//                                   controller: bloc.paidAmountController,
//                                   decoration: InputDecoration(
//                                     fillColor: AppColors.whiteColor,
//                                     border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5)),
//                                     filled: true,
//                                     hintStyle: AppTextStyle.cardLevelHead(context),
//                                     isCollapsed: true,
//                                     enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide(color: AppColors.blackColor.withValues(alpha: 0.5), width: 0.5),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5), width: 0.5),
//                                     ),
//                                     contentPadding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 12),
//                                     hintText: 'Paid Amount',
//                                   ),
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
//                                   ],
//                                   keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                   onChanged: (value) {
//                                     final enteredAmount = double.tryParse(value) ?? 0;
//                                     final totalPayable = bloc.totalAmount - bloc.discountAmount;
//
//                                     if (enteredAmount > totalPayable) {
//
//                                       showCustomToast(
//                                         context: context,
//                                         title: 'Failed!',
//                                         description:'Paid amount cannot exceed total payable amount (${totalPayable.toStringAsFixed(2)}).',
//                                         type: ToastificationType.error,
//                                         icon: Icons.error,
//                                         primaryColor: Colors.red,
//                                       );
//
//                                       bloc.paidAmountController.text = totalPayable.toStringAsFixed(2);
//                                       bloc.paidAmountController.selection = TextSelection.fromPosition(
//                                         TextPosition(offset: bloc.paidAmountController.text.length),
//                                       );
//                                     }
//                                     calculateDueAmount();
//                                     setState(() {});
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           Divider(height: 10),
//
//                           // Due Amount Display
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Due'),
//                               Text(bloc.dueAmount.toStringAsFixed(2)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     SizedBox(width: 20),
//
//                     // Right Delivery Date & Time Section
//                     Container(
//                       padding: EdgeInsets.all(8.0),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade400, width: 0.8),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       width: 250,
//                       child: Column(
//                         children: [
//                           TextField(
//                             controller: bloc.dateDeliveryReport,
//                             decoration: InputDecoration(
//                               fillColor: AppColors.whiteColor,
//                               border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5)),
//                               filled: true,
//                               hintStyle: AppTextStyle.cardLevelHead(context),
//                               isCollapsed: true,
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(color: AppColors.blackColor.withValues(alpha: 0.8), width: 0.5),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.8), width: 0.5),
//                               ),
//                               contentPadding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 12),
//                               hintText: "Delivery Report Date",
//                               labelText: "Delivery Report Date",
//                             ),
//                             keyboardType: TextInputType.datetime,
//                             readOnly: true,
//                             onTap: () => _selectDate(context),
//                           ),
//                           SizedBox(height: 20),
//                           TextField(
//                             controller: bloc.timeDeliveryReport,
//                             decoration: InputDecoration(
//                               fillColor: AppColors.whiteColor,
//                               border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5)),
//                               filled: true,
//                               hintStyle: AppTextStyle.cardLevelHead(context),
//                               isCollapsed: true,
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(color: AppColors.blackColor.withValues(alpha: 0.8), width: 0.5),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.8), width: 0.5),
//                               ),
//                               contentPadding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 12),
//                               hintText: "Delivery Report Time",
//                               labelText: "Delivery Report Time",
//                             ),
//                             keyboardType: TextInputType.datetime,
//                             readOnly: true,
//                             onTap: () => _selectTime(context),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class PaymentMethod extends StatelessWidget {
//   final String image;
//   final String title;
//   final String selectedPaymentMethod;
//   final VoidCallback onSelected;
//
//   const PaymentMethod({
//     super.key,
//     required this.image,
//     required this.title,
//     required this.selectedPaymentMethod,
//     required this.onSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isSelected = selectedPaymentMethod == title;
//
//     return GestureDetector(
//       onTap: onSelected,
//       child: Container(
//         margin: const EdgeInsets.all(5),
//         padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(
//             color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
//             width: isSelected ? 1.5 : 0.5,
//           ),
//           color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.white,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Radio<String>(
//                   activeColor: AppColors.primaryColor,
//                   value: title,
//                   groupValue: selectedPaymentMethod,
//                   onChanged: (value) {
//                     onSelected();
//                   },
//                 ),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//             Image.asset(image, height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }
