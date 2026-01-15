import 'package:intl/intl.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/supplier/supplier_list_bloc.dart';
import '../bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../bloc/supplier_payment/supplier_payment_bloc.dart';

class MobileSupplierPaymentCreate extends StatefulWidget {
  const MobileSupplierPaymentCreate({super.key});

  @override
  State<MobileSupplierPaymentCreate> createState() => _MobileSupplierPaymentCreateState();
}

class _MobileSupplierPaymentCreateState extends State<MobileSupplierPaymentCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Fetch necessary lists
    context.read<UserBloc>().add(FetchUserList(context, dropdownFilter: "?status=1"));
    context.read<SupplierListBloc>().add(FetchSupplierList(context));
    context.read<AccountBloc>().add(FetchAccountActiveList(context));

    // Set default date
    context.read<SupplierPaymentBloc>().dateController.text =
        appWidgets.convertDateTimeDDMMYYYY(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return BlocListener<SupplierPaymentBloc, SupplierPaymentState>(
      listener: (context, state) {
        if (state is SupplierPaymentAddLoading) {
          appLoader(context, "Payment, please wait...");
        } else if (state is SupplierPaymentAddSuccess) {
          Navigator.pop(context); // Close loader
          Navigator.pop(context); // Close form
        } else if (state is SupplierPaymentAddFailed) {
          Navigator.pop(context); // Close loader
          appAlertDialog(
            context,
            state.content,
            title: state.title,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Dismiss"),
              ),
            ],
          );
        }
      },
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 6),
              Column(
                children: [

                  _buildSupplierInfoSection(),
                  const SizedBox(height: 6),
                  _buildPaymentInfoSection(),
                  const SizedBox(height: 15),
                  _buildActionButtons(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Supplier Payment", style: AppTextStyle.headerTitle(context)),
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierInfoSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Supplier & Collected By
          _buildTwoColumnRow(
            firstChild: _buildSupplierDropdown(),
            secondChild: _buildCollectedByDropdown(),
          ),


          // Payment To & Conditional Invoice
          _buildTwoColumnRow(
            firstChild: _buildPaymentToDropdown(),
            secondChild: _buildInvoiceDropdownIfNeeded(),
          ),


          // Date field
          CustomInputField(
            isRequiredLable: true,
            isRequired: false,
            controller: context.read<SupplierPaymentBloc>().dateController,
            hintText: 'Date',
            fillColor: Colors.white,
            readOnly: true,
            onTap: _pickDate,
            validator: (value) => value!.isEmpty ? 'Please enter Date' : null, keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Information", style: AppTextStyle.headerTitle(context)),
          const SizedBox(height: 6),

          // Payment Method & Account
          _buildTwoColumnRow(
            firstChild: _buildPaymentMethodDropdown(),
            secondChild: _buildAccountDropdown(),
          ),


          // Amount & Remark
          _buildTwoColumnRow(
            firstChild: CustomInputField(
              isRequiredLable: true,
              isRequired: true,
              controller: context.read<SupplierPaymentBloc>().amountController,
              hintText: 'Amount',
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter amount' : null,
            ),
            secondChild: CustomInputField( keyboardType: TextInputType.text,
              isRequiredLable: true,
              isRequired: false,
              controller: context.read<SupplierPaymentBloc>().remarkController,
              hintText: 'Remark',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          size: 100,
          name: "Cancel",
          color: Colors.grey,
          onPressed: () => Navigator.of(context).pop(),
        ),
        gapW16,
        AppButton(
          size: 180,
          name: "Create Payment",
          onPressed: _submitPayment,
        ),
      ],
      
    );
  }

  Widget _buildTwoColumnRow({required Widget firstChild, required Widget secondChild}) {
    return LayoutBuilder(
      builder: (context, constraints) {

        return Column(
          children: [
            firstChild,
            secondChild,
          ],
        );
      },
    );
  }

  // ---------------- Dropdown builders ----------------

  Widget _buildSupplierDropdown() {
    return BlocBuilder<SupplierListBloc, SupplierListState>(
      builder: (context, state) {
        return AppDropdown(
          label: "Supplier",
          hint: context.read<SupplierPaymentBloc>().selectCustomerModel?.name ?? "Select Supplier",
          isRequired: true,
          value: context.read<SupplierPaymentBloc>().selectCustomerModel,
          itemList: context.read<SupplierListBloc>().supplierListModel,
          onChanged: (newVal) {
            context.read<SupplierPaymentBloc>().selectCustomerModel = newVal;
            context.read<SupplierInvoiceBloc>().supplierInvoiceListModel = "";
            context.read<SupplierInvoiceBloc>().add(FetchSupplierInvoiceList(
              context,
              dropdownFilter: "${newVal?.id}",
            ));
            // Set default amount if due > 0
            context.read<SupplierPaymentBloc>().amountController.text =
            double.tryParse(newVal?.totalDue.toString() ?? "0")! > 0
                ? newVal!.totalDue.toString()
                : "0";
            setState(() {});
          },
          validator: (value) => value == null ? 'Please select Supplier' : null,

        );
      },
    );
  }

  Widget _buildCollectedByDropdown() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return AppDropdown(
          label: "Collected By",
          isRequired: true,
          value: context.read<SupplierPaymentBloc>().selectUserModel,
          itemList: context.read<UserBloc>().list,
          hint: context.read<SupplierPaymentBloc>().selectUserModel?.username ?? "Select Collected By",
          onChanged: (newVal) {
            context.read<SupplierPaymentBloc>().selectUserModel = newVal;
            setState(() {});
          },
          validator: (value) => value == null ? 'Please select Collected By' : null,

        );
      },
    );
  }

  Widget _buildPaymentToDropdown() {
    return AppDropdown(
      label: "Payment To",
      isRequired: true,
      value: context.read<SupplierPaymentBloc>().selectedPaymentToState,
      itemList: context.read<SupplierPaymentBloc>().paymentTo,
      hint: context.read<SupplierPaymentBloc>().selectedPaymentToState.isNotEmpty
          ? context.read<SupplierPaymentBloc>().selectedPaymentToState
          : "Select Payment To",
      onChanged: (newVal) {
        context.read<SupplierPaymentBloc>().selectedPaymentToState = newVal;
        setState(() {});
      },
      validator: (value) => value == null ? 'Please select Payment To' : null,

    );
  }

  Widget _buildInvoiceDropdownIfNeeded() {
    if (context.read<SupplierPaymentBloc>().selectedPaymentToState != "Specific") {
      return const SizedBox();
    }

    return BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
      builder: (context, state) {
        return AppDropdown(
          label: "Invoice",
          isRequired: true,
          value: context.read<SupplierInvoiceBloc>().supplierInvoiceListModel,
          itemList: context.read<SupplierInvoiceBloc>().supplierListModel,
          hint: context.read<SupplierInvoiceBloc>().supplierInvoiceListModel.isEmpty
              ? "Select Invoice"
              : context.read<SupplierInvoiceBloc>().supplierInvoiceListModel,
          onChanged: (newVal) {
            context.read<SupplierInvoiceBloc>().supplierInvoiceListModel = newVal.toString();
            context.read<SupplierPaymentBloc>().amountController.text =
                newVal.toString().split("(").last.split(")").first;
            setState(() {});
          },
          validator: (value) => value == null ? 'Please select Invoice' : null,

        );
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return AppDropdown(
      label: "Payment Method",
      isRequired: true,
      value: context.read<SupplierPaymentBloc>().selectedPaymentMethod.isEmpty
          ? null
          : context.read<SupplierPaymentBloc>().selectedPaymentMethod,
      itemList: context.read<SupplierPaymentBloc>().paymentMethod,
      hint: context.read<SupplierPaymentBloc>().selectedPaymentMethod.isEmpty
          ? "Select Payment Method"
          : context.read<SupplierPaymentBloc>().selectedPaymentMethod,
      onChanged: (newVal) {
        context.read<SupplierPaymentBloc>().selectedPaymentMethod = newVal.toString();
        context.read<SupplierPaymentBloc>().selectedAccount = "";
        context.read<SupplierPaymentBloc>().selectedAccountId = "";
        setState(() {});
      },
      validator: (value) => value == null ? 'Please select a payment method' : null,

    );
  }

  Widget _buildAccountDropdown() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final filteredList = context.read<SupplierPaymentBloc>().selectedPaymentMethod.isNotEmpty
            ? context.read<AccountBloc>().activeAccount.where((item) {
          final itemAcType = item.acType?.toLowerCase() ?? '';
          final selectedMethod = context.read<SupplierPaymentBloc>().selectedPaymentMethod.toLowerCase();
          return itemAcType == selectedMethod;
        }).toList()
            : context.read<AccountBloc>().activeAccount;

        return AppDropdown(
          label: "Account",
          isRequired: true,
          value: context.read<SupplierPaymentBloc>().selectedAccount.isEmpty
              ? null
              : context.read<SupplierPaymentBloc>().selectedAccount,
          itemList: filteredList,
          hint: filteredList.isEmpty ? "No accounts available" : "Select Account",
          onChanged: (newVal) {
            if (newVal != null) {
              context.read<SupplierPaymentBloc>().selectedAccount = newVal.toString();
              try {
                var matchingAccount = filteredList.firstWhere((acc) => acc.toString() == newVal.toString());
                context.read<SupplierPaymentBloc>().selectedAccountId = matchingAccount.id.toString();
              } catch (e) {
                context.read<SupplierPaymentBloc>().selectedAccountId = "";
              }
            }
          },
          validator: (value) => value == null ? 'Please select an account' : null,

        );
      },
    );
  }

  void _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      context.read<SupplierPaymentBloc>().dateController.text =
          appWidgets.convertDateTimeDDMMYYYY(pickedDate);
      setState(() {});
    }
  }

  void _submitPayment() {
    if (!formKey.currentState!.validate()) return;

    final supplierBloc = context.read<SupplierPaymentBloc>();
    final invoiceBloc = context.read<SupplierInvoiceBloc>();

    Map<String, dynamic> body = {
      "account_id": supplierBloc.selectedAccountId,
      "amount": double.tryParse(supplierBloc.amountController.text.trim()),
      "supplier_id": supplierBloc.selectCustomerModel?.id.toString(),
      "payment_date": appWidgets.convertDateTime(
        DateFormat("dd-MM-yyyy").parse(supplierBloc.dateController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "payment_method": supplierBloc.selectedPaymentMethod.toString().toLowerCase(),
      "seller_id": supplierBloc.selectUserModel?.id.toString(),
      "specific_invoice": supplierBloc.selectedPaymentToState == "Over All" ? false : true,
    };

    if (supplierBloc.selectedPaymentToState == "Specific") {
      body["invoice_no"] = invoiceBloc.supplierInvoiceListModel.toString().split("(").first;
    }
    if (supplierBloc.remarkController.text.isNotEmpty) {
      body["description"] = supplierBloc.remarkController.text;
    }

    supplierBloc.add(AddSupplierPayment(body: body));
  }
}
