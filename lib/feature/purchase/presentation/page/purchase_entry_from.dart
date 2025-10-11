import 'dart:async';

import '../../../../core/core.dart';
import '../../../feature.dart';
import 'package:flutter/cupertino.dart';

class PurchaseCreateScreen extends StatefulWidget {
  const PurchaseCreateScreen({super.key});

  @override
  State<PurchaseCreateScreen> createState() => _PurchaseCreateScreenState();
}

class _PurchaseCreateScreenState extends State<PurchaseCreateScreen> {
  @override
  void initState() {
    super.initState();
    checkTokenAndLogoutIfExpired();
  }

  @override
  void dispose() {
    typeInventoryController.dispose();
    focusCategoryNode.dispose();
    focusInventoryNode.dispose();
    focusTestNode.dispose();
    super.dispose();
  }

  Future<void> checkTokenAndLogoutIfExpired() async {
    bool valid = await LocalDB.isTokenValid();
    if (!valid) {
      // Clear login info
      await LocalDB.delLoginInfo();
      if (mounted) {
        AppRoutes.pushReplacement(context, SplashScreen());
      }
    }
  }

  final TextEditingController typeInventoryController = TextEditingController();

  final FocusNode focusTestNode = FocusNode();
  final FocusNode focusCategoryNode = FocusNode();
  final FocusNode focusInventoryNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: SafeArea(child: _buildMainContent()),
    );
  }

  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen)
          ResponsiveCol(
            xs: 0,
            sm: 1,
            md: 1,
            lg: 2,
            xl: 2,
            child: Container(
              decoration: BoxDecoration(color: AppColors.whiteColor),
              child: isBigScreen ? const Sidebar() : const SizedBox.shrink(),
            ),
          ),
        ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: Container(
            color: AppColors.bg,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PurchaseEntryForm(),
                gapH20,
                FutureBuilder<Widget>(
                  future: buildActionButtons(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return snapshot.data!;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> buildActionButtons() async {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            AppButton(name: 'Summery', onPressed: () {}, color: Colors.grey),
            gapW4,
            AppButton(
              name: 'Finder',
              onPressed: () {},
              color: const Color(0xffff6347),
            ),
            gapW4,
            AppButton(
              name: 'Due Collection',
              onPressed: () {},
              color: Colors.black,
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            AppButton(
              name: 'Preview',
              onPressed: () async {},
              color: const Color(0xff800000),
            ),
            const SizedBox(width: 10),
            AppButton(name: 'Submit', onPressed: () {}),
            const SizedBox(width: 5),
          ],
        ),
      ],
    );
  }
}

class PurchaseEntryForm extends StatefulWidget {
  const PurchaseEntryForm({super.key});

  @override
  State<PurchaseEntryForm> createState() => _PurchaseEntryFormState();
}

class _PurchaseEntryFormState extends State<PurchaseEntryForm> {
  // Example controllers
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController warehouseController = TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController(
    text: "2025-10-11",
  );
  final TextEditingController purchaseDocController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController priceController = TextEditingController(
    text: "0",
  );
  final TextEditingController quantityController = TextEditingController(
    text: "0",
  );
  String discountType = "Tk";
  final TextEditingController discountController = TextEditingController(
    text: "0",
  );
  final TextEditingController ticketTotalController = TextEditingController(
    text: "0",
  );
  final TextEditingController netTotalController = TextEditingController(
    text: "0",
  );
  String overallDiscountType = "Tk";
  final TextEditingController overallDiscountController = TextEditingController(
    text: "0",
  );
  String overallVatType = "Tk";
  final TextEditingController overallVatController = TextEditingController(
    text: "0",
  );
  String serviceChargeType = "Tk";
  final TextEditingController serviceChargeController = TextEditingController(
    text: "0",
  );
  String deliveryChargeType = "Tk";
  final TextEditingController deliveryChargeController = TextEditingController(
    text: "0",
  );

  // Money receipt/payment section
  bool withMoneyReceipt = false;
  final TextEditingController paymentMethodController = TextEditingController(
    text: "Cash",
  );
  final TextEditingController accountController = TextEditingController(
    text: "Hand Cash (16601.80)",
  );
  final TextEditingController payableAmountController = TextEditingController();
  final TextEditingController returnAmountController = TextEditingController(
    text: "0",
  );
  final TextEditingController remarkController = TextEditingController();

  final List<String> paymentMethods = ["Cash", "Mobile banking"];
  final List<String> accounts = ["Hand Cash (16601.80)", "Bank A", "Bank B"];
  bool instantPay = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Purchase",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.white50Color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radius)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Supplier Info Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: "* Supplier",
                            controller: supplierController,
                            hint: "Select Supplier",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: "* Purchase Date",
                            controller: purchaseDateController,
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: "Purchase Document",
                                  controller: purchaseDocController,
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 4),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.upload_file, size: 16),
                                label: const Text(
                                  "Click to Upload",
                                  style: TextStyle(fontSize: 13),
                                ),
                                onPressed: () {}, // implement upload logic
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(),
                    // New Product Info Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: "* Product",
                            controller: productController,
                            hint: "Select Product",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberField(
                            label: "* Purchase Price",
                            controller: priceController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberField(
                            label: "* Quantity",
                            controller: quantityController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleInput(
                            type: discountType,
                            onTypeChanged: (v) =>
                                setState(() => discountType = v),
                            controller: discountController,
                            label: "Discount Type",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberField(
                            label: "Discount",
                            controller: discountController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberField(
                            label: "Ticket Total",
                            controller: ticketTotalController,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberField(
                            label: "Net Total",
                            controller: netTotalController,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 36,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {}, // implement add logic
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(),
                    // Service Charge, Delivery Charge and Discount Info
                    Row(
                      children: [
                        Expanded(
                          child: _buildToggleInputDiscount(
                            type: overallDiscountType,
                            onTypeChanged: (v) =>
                                setState(() => overallDiscountType = v),
                            controller: overallDiscountController,
                            label: "OVERALL DISCOUNT",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleInputDiscount(
                            type: overallVatType,
                            onTypeChanged: (v) =>
                                setState(() => overallVatType = v),
                            controller: overallVatController,
                            label: "OVERALL VAT",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleInputDiscount(
                            type: serviceChargeType,
                            onTypeChanged: (v) =>
                                setState(() => serviceChargeType = v),
                            controller: serviceChargeController,
                            label: "SERVICE CHARGE",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleInputDiscount(
                            type: deliveryChargeType,
                            onTypeChanged: (v) =>
                                setState(() => deliveryChargeType = v),
                            controller: deliveryChargeController,
                            label: "DELIVERY CHARGE",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Overview
                        Expanded(flex: 2, child: _OrderOverviewBox()),
                        const SizedBox(width: 16),
                        // Payment/Money Receipt Section
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: const Color(0xFFF6F6F6),
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: instantPay,
                                      onChanged: (v) => setState(() => instantPay = v!),
                                    ),
                                    const Text("Instant Pay"),
                                  ],
                                ),
                                // Only show payment fields if checked!
                                if (instantPay) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // Payment Method
                                      Expanded(
                                        child: _buildDropdownButton(
                                          label: "* Payment Method",
                                          value: paymentMethodController.text,
                                          items: paymentMethods,
                                          onChanged: (val) {
                                            setState(
                                                  () => paymentMethodController.text =
                                                  val ?? paymentMethodController.text,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Account
                                      Expanded(
                                        child: _buildDropdownButton(
                                          label: "* Account",
                                          value: accountController.text,
                                          items: accounts,
                                          onChanged: (val) {
                                            setState(
                                                  () => accountController.text =
                                                  val ?? accountController.text,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomInputField(
                                          controller: payableAmountController,
                                          labelText: "* Payable Amount",
                                          hintText: "Enter Client Payable Amount",
                                          keyboardType: TextInputType.number,
                                          isRequired: true,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: CustomInputField(
                                          controller: returnAmountController,
                                          labelText: "Return Amount",
                                          hintText: "0",
                                          keyboardType: TextInputType.number,
                                          isRequired: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.labelDropdownTextStyle(context)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return CustomInputField(
      controller: controller,
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      hintText: label,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool readOnly = false,
    String? initialValue,
  }) {
    return CustomInputField(
      controller: controller,
      readOnly: readOnly,
      isRequired: isRequired,
      keyboardType: TextInputType.number,
      hintText: label,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      onTap: () {},
    );
  }

  Widget _buildToggleInput({
    required String type,
    required ValueChanged<String> onTypeChanged,
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.labelDropdownTextStyle(context)),
        const SizedBox(height: 4),
        Row(
          children: [
            CupertinoSegmentedControl<String>(
              groupValue: type,
              children: const {
                "Tk": Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text("Tk"),
                ),
                "%": Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text("%"),
                ),
              },
              onValueChanged: onTypeChanged,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              selectedColor: Colors.deepOrangeAccent,
              unselectedColor: Colors.white,
              borderColor: Colors.deepOrangeAccent,
              pressedColor: Colors.deepOrangeAccent,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              child: CustomInputField(
                controller: controller,
                isRequiredLable: false,
                keyboardType: TextInputType.number,
                hintText: '',
              ),
            ),
          ],
        ),
      ],
    );
  }

 Widget _buildToggleInputDiscount({
    required String type,
    required ValueChanged<String> onTypeChanged,
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.labelDropdownTextStyle(context)),
        const SizedBox(height: 4),
        Row(
          children: [
            CupertinoSegmentedControl<String>(
              groupValue: type,
              children: const {
                "Tk": Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Text("Tk"),
                ),
                "%": Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text("%"),
                ),
              },
              onValueChanged: onTypeChanged,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              selectedColor: Colors.deepOrangeAccent,
              unselectedColor: Colors.white,
              borderColor: Colors.deepOrangeAccent,
              pressedColor: Colors.deepOrangeAccent,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: CustomInputField(
                controller: controller,
                isRequiredLable: false,
                keyboardType: TextInputType.number,
                hintText: '',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderOverviewBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Overview", style: AppTextStyle.cardTitle(context)),
            Divider(),
            gapH8,
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: const [
                TableRow(
                  children: [
                    Text("Ticket Total"),
                    Align(alignment: Alignment.centerRight, child: Text("0")),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Specific Discount (-)"),
                    Align(alignment: Alignment.centerRight, child: Text("0")),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      "Net Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "0",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Discount (-)"),
                    Align(alignment: Alignment.centerRight, child: Text("0")),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Vat (+)"),
                    Align(alignment: Alignment.centerRight, child: Text("0")),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Service Charge (+)"),
                    Align(alignment: Alignment.centerRight, child: Text("0")),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      "Gross Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "0.00",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}