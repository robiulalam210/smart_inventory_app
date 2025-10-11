import 'dart:async';

import '../../../../core/core.dart';
import '../../../feature.dart';


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
      child: SafeArea(
        child:_buildMainContent(),
      ),
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
              decoration:
              BoxDecoration(color: AppColors.whiteColor),
              child: isBigScreen
                  ? const Sidebar()
                  : const SizedBox.shrink(),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    physics:
                    const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PurchaseEntryForm(),

                      ],
                    ),
                  ),
                ),
                gapH20,
                FutureBuilder<Widget>(
                  future: buildActionButtons(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return snapshot.data!;
                    }
                  },
                )
                // buildActionButtons(),
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

            AppButton(
              name: 'Summery',
              onPressed: () {

              },
              color: Colors.grey,
            ),
            gapW4,
            AppButton(
              name: 'Finder',
              onPressed: () {

              },
              color: Color(0xffff6347),
            ),


            gapW4,
            AppButton(
              name: 'Due Collection',
              onPressed: () {

              },
              color: Colors.black,
            ),
          ],
        ),
        Row(
          children: [

            const SizedBox(width: 10),
            AppButton(
              name: 'Preview',
              onPressed: () async {

              },
              color: const Color(0xff800000),
            ),
            const SizedBox(width: 10),
            AppButton(
              name: 'Submit',
              onPressed: (){},
            ),
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
  final TextEditingController purchaseDateController = TextEditingController(text: "2025-10-11");
  final TextEditingController purchaseDocController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController priceController = TextEditingController(text: "0");
  final TextEditingController quantityController = TextEditingController(text: "0");
  String discountType = "Tk";
  final TextEditingController discountController = TextEditingController(text: "0");
  final TextEditingController ticketTotalController = TextEditingController(text: "0");
  final TextEditingController netTotalController = TextEditingController(text: "0");
  String overallDiscountType = "Tk";
  final TextEditingController overallDiscountController = TextEditingController(text: "0");
  String overallVatType = "Tk";
  final TextEditingController overallVatController = TextEditingController(text: "0");
  String serviceChargeType = "Tk";
  final TextEditingController serviceChargeController = TextEditingController(text: "0");
  String deliveryChargeType = "Tk";
  final TextEditingController deliveryChargeController = TextEditingController(text: "0");
  bool instantPay = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Create Purchase",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 18),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.zero,
              color: const Color(0xFFF6F6F6),
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
                            suffixIcon: const Icon(Icons.calendar_today, size: 16),
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
                                label: const Text("Click to Upload", style: TextStyle(fontSize: 13)),
                                onPressed: () {}, // implement upload logic
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                            onTypeChanged: (v) => setState(() => discountType = v),
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
                          child: _buildToggleInput(
                            type: overallDiscountType,
                            onTypeChanged: (v) => setState(() => overallDiscountType = v),
                            controller: overallDiscountController,
                            label: "OVERALL DISCOUNT",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleInput(
                            type: overallVatType,
                            onTypeChanged: (v) => setState(() => overallVatType = v),
                            controller: overallVatController,
                            label: "OVERALL VAT",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleInput(
                            type: serviceChargeType,
                            onTypeChanged: (v) => setState(() => serviceChargeType = v),
                            controller: serviceChargeController,
                            label: "SERVICE CHARGE",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleInput(
                            type: deliveryChargeType,
                            onTypeChanged: (v) => setState(() => deliveryChargeType = v),
                            controller: deliveryChargeController,
                            label: "DELIVERY CHARGE",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                },
                                children: const [
                                  TableRow(children: [
                                    Text("Ticket Total"),
                                    Align(alignment: Alignment.centerRight, child: Text("0")),
                                  ]),
                                  TableRow(children: [
                                    Text("Specific Discount (-)"),
                                    Align(alignment: Alignment.centerRight, child: Text("0")),
                                  ]),
                                  TableRow(children: [
                                    Text("Net Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Align(alignment: Alignment.centerRight, child: Text("0", style: TextStyle(fontWeight: FontWeight.bold))),
                                  ]),
                                  TableRow(children: [
                                    Text("Discount (-)"),
                                    Align(alignment: Alignment.centerRight, child: Text("0")),
                                  ]),
                                  TableRow(children: [
                                    Text("Vat (+)"),
                                    Align(alignment: Alignment.centerRight, child: Text("0")),
                                  ]),
                                  TableRow(children: [
                                    Text("Service Charge (+)"),
                                    Align(alignment: Alignment.centerRight, child: Text("0")),
                                  ]),
                                  TableRow(children: [
                                    Text("Gross Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Align(alignment: Alignment.centerRight, child: Text("0.00", style: TextStyle(fontWeight: FontWeight.bold))),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Checkbox(
                                value: instantPay,
                                onChanged: (v) => setState(() => instantPay = v!),
                              ),
                              const Text("Instant Pay"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              label: const Text("Create Purchase"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57A56),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildToggleInput({
    required String type,
    required ValueChanged<String> onTypeChanged,
    required TextEditingController controller,
    required String label,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                ToggleButtons(
                  isSelected: [type == "Tk", type == "%"],
                  borderRadius: BorderRadius.circular(4),
                  onPressed: (i) => onTypeChanged(i == 0 ? "Tk" : "%"),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Tk"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("%"),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}