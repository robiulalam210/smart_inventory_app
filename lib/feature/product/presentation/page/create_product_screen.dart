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
    productNameController.dispose();
    purchasePriceController.dispose();
    sellingPriceController.dispose();
    openingStockController.dispose();
    barcodeController.dispose();
    alertQtyController.dispose();
    productDescriptionController.dispose();
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
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
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
                child:  SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: "* Category",
                                      value: productCategory,
                                      items: categories,
                                      hint: "Select Category",
                                      onChanged: (val) => setState(() => productCategory = val),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: "* Unit",
                                      value: productUnit,
                                      items: units,
                                      hint: "Select Unit",
                                      onChanged: (val) => setState(() => productUnit = val),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: "* Brand",
                                      value: productBrand,
                                      items: brands,
                                      hint: "Select Brand",
                                      onChanged: (val) => setState(() => productBrand = val),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      label: "* Product Name",
                                      hint: "Enter Product Name",
                                      controller: productNameController,
                                      isRequired: true, keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      label: "* Purchase Price",
                                      hint: "0",
                                      controller: purchasePriceController,
                                      keyboardType: TextInputType.number,
                                      isRequired: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      label: "* Selling Price",
                                      hint: "0",
                                      controller: sellingPriceController,
                                      keyboardType: TextInputType.number,
                                      isRequired: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      label: "* Opening Stock",
                                      hint: "0",
                                      controller: openingStockController,
                                      keyboardType: TextInputType.number,
                                      isRequired: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: "Barcode",
                                      hint: "Enter Barcode",
                                      controller: barcodeController,
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      label: "* Alert Qty",
                                      hint: "5",
                                      controller: alertQtyController,
                                      keyboardType: TextInputType.number,
                                      isRequired: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                label: "Description",
                                hint: "Product Description",
                                controller: productDescriptionController,
                                maxLines: 2,
                                keyboardType: TextInputType.multiline,
                              ),
                            ],
                          ),
                        ),
                      ),
                      gapH20,
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    required TextInputType keyboardType,
    int maxLines = 1,
  }) {
    return CustomInputField(
      controller: controller,
      readOnly: readOnly,
      // keyboardType: keyboardType,
      // decoration: InputDecoration(
      //   labelText: label,
      //   hintText: hint,
      //   border: const OutlineInputBorder(),
      //   isDense: true,
      //   contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      // ),
      validator: isRequired
          ? (v) {
        if (v == null || v.isEmpty) return "Required";
        return null;
      }
          : null, hintText: hint??"",labelText: label, keyboardType: keyboardType,
    );
  }
}