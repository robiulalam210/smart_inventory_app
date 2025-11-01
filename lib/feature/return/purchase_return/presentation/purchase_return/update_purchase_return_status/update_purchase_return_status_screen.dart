// import 'package:intl/intl.dart';
//
// import '../../../../../../core/configs/configs.dart';
// import '../../../../../../core/widgets/app_dropdown.dart';
// import '../../../../../accounts/presentation/bloc/account/account_bloc.dart';
// import '../../bloc/purchase_return/purchase_return_bloc.dart';
//
//
//
// class UpdatePurchaseReturnStatusScreen extends StatefulWidget {
//   const UpdatePurchaseReturnStatusScreen({
//     super.key,
//     this.id = "",
//   });
//
//   final String? id;
//
//
//   @override
//   State<UpdatePurchaseReturnStatusScreen> createState() =>
//       _UpdatePurchaseReturnStatusScreenState();
// }
//
// class _UpdatePurchaseReturnStatusScreenState
//     extends State<UpdatePurchaseReturnStatusScreen> {
//   @override
//   void initState() {
//     context.read<AccountBloc>().add(
//           FetchAccountActiveList(context,),
//         );
//
//     context.read<PurchaseReturnBloc>().returnDateTextController.text =
//         appWidgets.convertDateTimeDDMMYYYY(DateTime.now());
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       body: Container(
//         padding: AppTextStyle.getResponsivePaddingBody(context),
//         child: RefreshIndicator(
//           color: AppColors.primaryColor,
//           onRefresh: () async {
//             context.read<AccountBloc>().add(
//                   FetchAccountList(context,),
//                 );
//           },
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Form(
//               key: formKey,
//               child: Column(
//                 children: [
//
//                   Padding(
//                     padding: const EdgeInsets.all(0.0),
//                     child: AppDropdown(
//                       label: "Return Status",context: context,
//                       hint: context
//                               .read<PurchaseReturnBloc>()
//                               .selectedStatus
//                               .isEmpty
//                           ? "Select Return Status"
//                           : context.read<PurchaseReturnBloc>().selectedStatus,
//                       isNeedAll: false,
//                       value: context
//                               .read<PurchaseReturnBloc>()
//                               .selectedStatus
//                               .isEmpty
//                           ? null
//                           : context.read<PurchaseReturnBloc>().selectedStatus,
//                       itemList: context.read<PurchaseReturnBloc>().statusList,
//                       onChanged: (newVal) {
//                         // Update the selected warehouse in the bloc
//                         context.read<PurchaseReturnBloc>().selectedStatus =
//                             newVal.toString();
//                       },
//                       itemBuilder: (item) => DropdownMenuItem(
//                         value: item,
//                         child: Text(
//                           item.toString(),
//                           style: const TextStyle(
//                             color: AppColors.blackColor,
//                             fontFamily: 'Quicksand',
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   AppDropdown(
//                     label: "Account Type",context: context,
//                     hint: context
//                             .read<MoneyReceiptBloc>()
//                             .selectedPaymentMethod
//                             .isEmpty
//                         ? "Select Account Type"
//                         : context
//                             .read<MoneyReceiptBloc>()
//                             .selectedPaymentMethod,
//                     isLabel: false,
//                     isRequired: true,
//                     value: context
//                             .read<MoneyReceiptBloc>()
//                             .selectedPaymentMethod
//                             .isEmpty
//                         ? null
//                         : context
//                             .read<MoneyReceiptBloc>()
//                             .selectedPaymentMethod,
//                     itemList: context.read<ExpenseBloc>().paymentMethod,
//                     onChanged: (newVal) {
//                       context.read<MoneyReceiptBloc>().selectedPaymentMethod =
//                           newVal.toString();
//                       setState(() {});
//                     },
//                     validator: (value) {
//                       return value == null
//                           ? 'Please select a payment method'
//                           : null;
//                     },
//                     itemBuilder: (item) => DropdownMenuItem(
//                       value: item,
//                       child: Text(
//                         item.toString(),
//                         style: const TextStyle(
//                           color: AppColors.blackColor,
//                           fontFamily: 'Quicksand',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   BlocBuilder<AccountBloc, AccountState>(
//                     builder: (context, state) {
//                       final filteredList = context
//                               .read<MoneyReceiptBloc>()
//                               .selectedPaymentMethod
//                               .isNotEmpty
//                           ? context.read<AccountBloc>().list.where((item) {
//                               return item.acType?.toLowerCase() ==
//                                   context
//                                       .read<MoneyReceiptBloc>()
//                                       .selectedPaymentMethod
//                                       .toLowerCase();
//                             }).toList()
//                           : context.read<AccountBloc>().list;
//
//                       // Debug: Check the size of the filtered list
//
//                       return AppDropdown(
//                         label: "Account",
//                         hint: "Select Account",context: context,
//                         isLabel: false,
//                         isRequired: true,
//                         isNeedAll: false,
//                         value: context
//                                 .read<MoneyReceiptBloc>()
//                                 .selectedAccount
//                                 .isEmpty
//                             ? null
//                             : context.read<MoneyReceiptBloc>().selectedAccount,
//                         itemList: filteredList,
//                         onChanged: (newVal) {
//                           // Update the selected account in the bloc
//                           context.read<MoneyReceiptBloc>().selectedAccount =
//                               newVal.toString();
//
//                           var matchingAccount = filteredList.firstWhere(
//                             (acc) =>
//                                 acc.acName.toString() ==
//                                 newVal.toString().split("(").first,
//                           );
//
//                           context.read<MoneyReceiptBloc>().selectedAccountId =
//                               matchingAccount.acId.toString();
//                         },
//                         validator: (value) {
//                           return value == null
//                               ? 'Please select an account'
//                               : null;
//                         },
//                         itemBuilder: (item) => DropdownMenuItem(
//                           value: item.toString(),
//                           child: Text(
//                             item.toString(),
//                             style: const TextStyle(
//                               color: AppColors.blackColor,
//                               fontFamily: 'Quicksand',
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   CustomInputField(
//                     isRequiredLable: true,
//                     isRequired: false,
//                     controller: context
//                         .read<PurchaseReturnBloc>()
//                         .returnDateTextController,
//                     hintText: 'Date',
//                     fillColor: const Color.fromARGB(255, 255, 255, 255),
//                     readOnly: true,
//                     keyboardType: TextInputType.text,
//                     autofillHints: AutofillHints.telephoneNumber,
//                     validator: (value) {
//                       return value!.isEmpty ? 'Please enter date ' : null;
//                     },
//                     onTap: () async {
//                       FocusScope.of(context)
//                           .requestFocus(FocusNode()); // Close the keyboard
//                       DateTime? pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(1900),
//                         lastDate: DateTime.now(),
//                       );
//                       if (pickedDate != null) {
//                         context.read<ChequeBloc>().dateController.text =
//                         pickedDate
//                             .toLocal()
//                             .toString()
//                             .split(' ')[0]; // Format the date
//                       }
//                     },
//                     onChanged: (value) {
//                       return null;
//                     },
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   AppButton(
//                     name: "Submit",
//                     onPressed: () {
//                       if (formKey.currentState!.validate()) {
//                         // Collecting the form data
//                         Map<String, dynamic> body = {
//                           "account_id":  context.read<MoneyReceiptBloc>().selectedAccountId ,
//                           "payment_method":context
//                               .read<MoneyReceiptBloc>()
//                               .selectedPaymentMethod,
//                           "return_status": context.read<PurchaseReturnBloc>().selectedStatus.toLowerCase(),
//                           "update_date": appWidgets.convertDateTime(
//                               DateFormat("dd-MM-yyyy").parse(
//                                   context
//                                       .read<PurchaseReturnBloc>()
//                                       .returnDateTextController
//                                       .text
//                                       .trim(),
//                                   true),
//                               "yyyy-MM-dd"),
//                         };
//
//
//                         context
//                             .read<PurchaseReturnBloc>()
//                             .add(PurchaseReturnStatusUpdate(body: body,id: widget.id.toString()));
//                       }
//                     },
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
