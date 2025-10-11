import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../feature.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  @override
  void initState() {
    super.initState();
    checkTokenAndLogoutIfExpired();
  }

  @override
  void dispose() {
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

  final _formKey = GlobalKey<FormState>();
  String? productCategory;
  String? productUnit;
  String? productBrand;
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController(text: "0");
  final TextEditingController sellingPriceController = TextEditingController(text: "0");
  final TextEditingController openingStockController = TextEditingController(text: "0");
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController alertQtyController = TextEditingController(text: "5");
  final TextEditingController productDescriptionController = TextEditingController();
  String? productPicture;

  final List<String> categories = ["Electronics", "Clothing", "Grocery"];
  final List<String> units = ["Piece", "Kg", "Litre"];
  final List<String> brands = ["Brand A", "Brand B", "Brand C"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 860),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 14.0),
                        child: Text(
                          "Create Product",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    label: "* Product Category",
                                    value: productCategory,
                                    items: categories,
                                    hint: "Select Product Category",
                                    onChanged: (val) => setState(() => productCategory = val),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    label: "* Product Unit",
                                    value: productUnit,
                                    items: units,
                                    hint: "Select Product Unit",
                                    onChanged: (val) => setState(() => productUnit = val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    label: "Select Brand",
                                    value: productBrand,
                                    items: brands,
                                    hint: "Select Product Brand",
                                    onChanged: (val) => setState(() => productBrand = val),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: "* Product Name",
                                    hint: "Enter Product Name",
                                    controller: productNameController,
                                    isRequired: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "Purchase Price",
                                    controller: purchasePriceController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: "Selling Price",
                                    controller: sellingPriceController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "Product Opening Stock",
                                    controller: openingStockController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    label: "Product Barcode",
                                    hint: "Enter Product Barcode",
                                    controller: barcodeController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "Alert Quantity",
                                    controller: alertQtyController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          label: "Product Picture",
                                          controller: TextEditingController(text: productPicture ?? ""),
                                          readOnly: true,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.upload_file, size: 16),
                                        label: const Text("Click to Upload", style: TextStyle(fontSize: 13)),
                                        onPressed: () {
                                          // TODO: Implement file picker
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: "Product Description",
                              hint: "Write Product Description",
                              controller: productDescriptionController,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          label: const Text("Create"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF57A56),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Implement create product logic
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    String? value,
    required List<String> items,
    String? hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      items: items
          .map((val) => DropdownMenuItem(
        value: val,
        child: Text(val),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (val) {
        if (label.startsWith('*') && (val == null || val.isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    required TextEditingController controller,
    bool readOnly = false,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      validator: isRequired
          ? (v) {
        if (v == null || v.isEmpty) return "Required";
        return null;
      }
          : null,
    );
  }
}