import 'package:flutter/material.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../responsive.dart';

class MoneyReceiptForm extends StatefulWidget {
  const MoneyReceiptForm({super.key});

  @override
  State<MoneyReceiptForm> createState() => _MoneyReceiptListScreenState();
}

class _MoneyReceiptListScreenState extends State<MoneyReceiptForm> {
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController amountController = TextEditingController(text: "0");
  final TextEditingController dateController = TextEditingController(text: "11-10-2025");

  String customer = "Select Customer";
  String collectedBy = "MAHMUDUL HAQUE ARMAAN";
  String paymentTo = "Over All";
  String paymentMethod = "Cash";
  String paymentAccount = "Hand Cash (16601.80)";

  List<String> customers = ["Select Customer"];
  List<String> collectors = ["MAHMUDUL HAQUE ARMAAN"];
  List<String> paymentTos = ["Over All"];
  List<String> paymentMethods = ["Cash"];
  List<String> accounts = ["Hand Cash (16601.80)"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Create Money Receipt",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Top Row
                      Row(
                        children: [
                          // Customer Dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: "* Customer",
                              value: customer,
                              items: customers,
                              onChanged: (val) =>
                                  setState(() => customer = val ?? customer),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Collected By Dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: "* Collected By",
                              value: collectedBy,
                              items: collectors,
                              onChanged: (val) =>
                                  setState(() => collectedBy = val ?? collectedBy),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Payment To Dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: "* Payment To",
                              value: paymentTo,
                              items: paymentTos,
                              onChanged: (val) =>
                                  setState(() => paymentTo = val ?? paymentTo),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: "* Date",
                              controller: dateController,
                            ),
                          ),
                          const Spacer(flex: 4),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            "Payment Information",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.credit_card, size: 17, color: Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Payment Method Dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: "* Payment Method",
                              value: paymentMethod,
                              items: paymentMethods,
                              onChanged: (val) =>
                                  setState(() => paymentMethod = val ?? paymentMethod),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Account Dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: "* Account",
                              value: paymentAccount,
                              items: accounts,
                              onChanged: (val) =>
                                  setState(() => paymentAccount = val ?? paymentAccount),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Amount Input
                          Expanded(
                            child: _buildTextField(
                              label: "* Amount",
                              controller: amountController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _buildTextField(
                        label: "Remark",
                        controller: remarkController,
                        hintText: "Seller Remark",
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    label: const Text("Create"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57A56),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    String? label,
    String? value,
    List<String>? items,
    void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: items != null
          ? items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList()
          : [],
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    String? label,
    String? hintText,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildDateField({
    String? label,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () {
        // TODO: Implement date picker if desired
      },
    );
  }
}