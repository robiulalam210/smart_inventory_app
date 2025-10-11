import 'package:flutter/material.dart';
import 'package:smart_inventory/core/core.dart';

class SalesEntrySection extends StatefulWidget {
  const SalesEntrySection({super.key});

  @override
  State<SalesEntrySection> createState() => _SalesEntrySectionState();
}

class _SalesEntrySectionState extends State<SalesEntrySection> {
  // Example controllers and lists
  final TextEditingController customerController = TextEditingController();
  final TextEditingController salesByController = TextEditingController(text: "MAHMUDUL HAQUE ARMAAN");
  final TextEditingController dateController = TextEditingController(text: "11-10-2025");
  final TextEditingController branchController = TextEditingController();
  final List<ProductRowData> products = [ProductRowData()];
  String vatType = "Tk";
  String discountType = "Tk";
  String serviceChargeType = "Tk";
  String deliveryChargeType = "Tk";
  final TextEditingController overallVatController = TextEditingController(text: "0");
  final TextEditingController overallDiscountController = TextEditingController(text: "0");
  final TextEditingController serviceChargeController = TextEditingController(text: "0");
  final TextEditingController deliveryChargeController = TextEditingController(text: "0");
  bool withMoneyReceipt = false;
  final TextEditingController remarkController = TextEditingController();

  void addProductRow() => setState(() => products.add(ProductRowData()));
  void removeProductRow(int index) => setState(() => products.removeAt(index));

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
          const SizedBox(height: 16),

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
                        onTypeChanged: (v) => setState(() => row.discountType = v),
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

          // Order Overview and Remarks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _OrderOverviewBox(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
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
                    const SizedBox(height: 8),
                    TextField(
                      controller: remarkController,
                      decoration: const InputDecoration(
                        labelText: "Remark",
                        hintText: "Enter Remark",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
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
      hintText: hint??"",
      labelText: label,
      suffixIcon: const Icon(Icons.arrow_drop_down),

      readOnly: true,
      onTap: () {}, keyboardType: TextInputType.text,
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
      readOnly: readOnly, textInputAction: TextInputAction.next, hintText: label, keyboardType: TextInputType.text,

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
      keyboardType: TextInputType.number, hintText: label,
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            ToggleButtons(
              isSelected: [type == "Tk", type == "%"],
              onPressed: (i) => onTypeChanged(i == 0 ? "Tk" : "%"),
              children: const [Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Tk"),
              ), Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("%"),
              )],
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
    );
  }
}

class ProductRowData {
  final TextEditingController productController = TextEditingController();
  final TextEditingController priceController = TextEditingController(text: "0");
  final TextEditingController quantityController = TextEditingController(text: "1");
  String discountType = "Tk";
  final TextEditingController discountController = TextEditingController(text: "0");
  final TextEditingController ticketTotalController = TextEditingController(text: "0");
  final TextEditingController netTotalController = TextEditingController(text: "0");
}

class _OrderOverviewBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with your logic and controllers
    return Card(
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
    );
  }
}