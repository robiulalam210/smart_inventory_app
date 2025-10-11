import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_inventory/core/core.dart';

// This class is unchanged.
class ProductRowData {
  final TextEditingController productController = TextEditingController();
  final TextEditingController priceController = TextEditingController(
    text: "0",
  );
  final TextEditingController quantityController = TextEditingController(
    text: "1",
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
}

class SalesEntrySection extends StatefulWidget {
  const SalesEntrySection({super.key});

  @override
  State<SalesEntrySection> createState() => _SalesEntrySectionState();
}

class _SalesEntrySectionState extends State<SalesEntrySection> {
  // Example controllers and lists
  final TextEditingController customerController = TextEditingController();
  final TextEditingController salesByController = TextEditingController(
    text: "MAHMUDUL HAQUE ARMAAN",
  );
  final TextEditingController dateController = TextEditingController(
    text: "11-10-2025",
  );
  final TextEditingController branchController = TextEditingController();
  final List<ProductRowData> products = [ProductRowData()];
  String vatType = "Tk";
  String discountType = "Tk";
  String serviceChargeType = "Tk";
  String deliveryChargeType = "Tk";
  final TextEditingController overallVatController = TextEditingController(
    text: "0",
  );
  final TextEditingController overallDiscountController = TextEditingController(
    text: "0",
  );
  final TextEditingController serviceChargeController = TextEditingController(
    text: "0",
  );
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

  void addProductRow() => setState(() => products.add(ProductRowData()));

  void removeProductRow(int index) => setState(() => products.removeAt(index));

  // For dropdown demo
  final List<String> paymentMethods = ["Cash", "Mobile banking"];
  final List<String> accounts = ["Hand Cash (16601.80)", "Bank A", "Bank B"];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  controller: customerController,
                  label: "Customer",
                  isRequired: true,
                  hint: "Select Customer",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: salesByController,
                  label: "Sales By",
                  isRequired: true,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: dateController,
                  label: "Date",
                  isRequired: true,
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_today, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items Information
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Items Information",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: List.generate(products.length, (index) {
              final row = products[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    // Product Dropdown
                    Expanded(
                      flex: 2,
                      child: _buildDropdownField(
                        controller: row.productController,
                        label: "Select Product",
                        isRequired: true,
                        hint: "Select Product",
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Price
                    Expanded(
                      child: _buildNumberField(
                        controller: row.priceController,
                        label: "Price",
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quantity
                    Expanded(
                      child: _buildNumberField(
                        controller: row.quantityController,
                        label: "Quantity",
                        isRequired: true,
                        initialValue: "1",
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Discount Type Toggle
                    Expanded(
                      child: _buildToggleInput(
                        type: row.discountType,
                        onTypeChanged: (v) =>
                            setState(() => row.discountType = v),
                        controller: row.discountController,
                        label: "Discount Type",
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ticket Total
                    Expanded(
                      child: _buildNumberField(
                        controller: row.ticketTotalController,
                        label: "Ticket Total",
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Net Total
                    Expanded(
                      child: _buildNumberField(
                        controller: row.netTotalController,
                        label: "Net Total",
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: index == products.length - 1
                          ? IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: addProductRow,
                            )
                          : IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => removeProductRow(index),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // VAT, Discount, Charges Row
          Row(
            children: [
              Expanded(
                child: _buildToggleInput(
                  type: vatType,
                  onTypeChanged: (v) => setState(() => vatType = v),
                  controller: overallVatController,
                  label: "OVERALL VAT",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildToggleInput(
                  type: discountType,
                  onTypeChanged: (v) => setState(() => discountType = v),
                  controller: overallDiscountController,
                  label: "OVERALL DISCOUNT",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildToggleInput(
                  type: serviceChargeType,
                  onTypeChanged: (v) => setState(() => serviceChargeType = v),
                  controller: serviceChargeController,
                  label: "SERVICE CHARGE",
                ),
              ),
              const SizedBox(width: 8),
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

          // Order Overview and With Money Receipt Section
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
                            value: withMoneyReceipt,
                            onChanged: (v) => setState(() => withMoneyReceipt = v!),
                          ),
                          const Text("With Money Receipt"),
                        ],
                      ),
// Only show payment fields if checked!
                      if (withMoneyReceipt) ...[
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
                      const SizedBox(height: 8),
                      CustomInputField(
                        controller: remarkController,
                        labelText: "Remark",
                        hintText: "Enter Remark",

                        isRequired: false,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    String? hint,
  }) {
    return CustomInputField(
      controller: controller,
      hintText: hint ?? "",
      labelText: label,
      suffixIcon: const Icon(Icons.arrow_drop_down),
      readOnly: true,
      onTap: () {},
      keyboardType: TextInputType.text,
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
}

// The order overview box remains unchanged
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
