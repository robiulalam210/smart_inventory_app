// NOTE: adjust imports paths to match your project structure
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '/core/core.dart';
import '/feature/products/product/data/model/product_stock_model.dart';
import '/feature/users_list/presentation/bloc/users/user_bloc.dart';

import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../../products/brand/presentation/bloc/brand/brand_bloc.dart';
import '../../../../products/categories/presentation/bloc/categories/categories_bloc.dart';
import '../../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';

class MobileSalesScreen extends StatefulWidget {
  const MobileSalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<MobileSalesScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late CategoriesBloc categoriesBloc;
  late BrandBloc brandBloc;

  TextEditingController changeAmountController = TextEditingController();
  TextEditingController productSearchController = TextEditingController();
  String selectedCategoryFilter = '';
  String selectedBrandFilter = '';
  bool _isChecked = false;

  // Charge/discount types (defaults)
  String selectedOverallVatType = 'fixed';
  String selectedOverallDiscountType = 'fixed';
  String selectedOverallServiceChargeType = 'fixed';
  String selectedOverallDeliveryType = 'fixed';

  // ---------------- Barcode scanner state ----------------
  final FocusNode _focusNode = FocusNode();
  String _barcodeBuffer = '';
  final List<Map<String, dynamic>> _scannedProducts = [];

  // Replace with your API base URL / token or load from secure storage
  final String apiBaseUrl = '${AppUrls.baseUrl}/products/barcode-search';
  final String jwtToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzYyNjg2MTI1LCJpYXQiOjE3NjI1OTk3MjUsImp0aSI6ImRiNjAzMmFjOWFkOTQ2NzRiNTE5Njk5OGI0ZWI0OTMzIiwidXNlcl9pZCI6IjIifQ.LJv3l53GjkdDWHKT-YPiCpuNQfBK8NorsWN56WirY8s";

  @override
  void initState() {
    super.initState();

    // Fetch initial lists
    context.read<AccountBloc>().add(FetchAccountActiveList(context));
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    context.read<UserBloc>().add(FetchUserList(context));
    context.read<ProductsBloc>().add(FetchProductsStockList(context));
    categoriesBloc = context.read<CategoriesBloc>();
    brandBloc = context.read<BrandBloc>();

    // Initialize BLoC fields (dates etc)
    final bloc = context.read<CreatePosSaleBloc>();
    bloc.dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );
    bloc.withdrawDateController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );

    selectedOverallVatType = bloc.selectedOverallVatType.isNotEmpty
        ? bloc.selectedOverallVatType
        : selectedOverallVatType;
    selectedOverallDiscountType = bloc.selectedOverallDiscountType.isNotEmpty
        ? bloc.selectedOverallDiscountType
        : selectedOverallDiscountType;
    selectedOverallServiceChargeType =
    bloc.selectedOverallServiceChargeType.isNotEmpty
        ? bloc.selectedOverallServiceChargeType
        : selectedOverallServiceChargeType;
    selectedOverallDeliveryType = bloc.selectedOverallDeliveryType.isNotEmpty
        ? bloc.selectedOverallDeliveryType
        : selectedOverallDeliveryType;
    _isChecked = bloc.isChecked;

    // Ensure there's at least one product row (empty) so UI has an 'add' row
    if (bloc.products.isEmpty) {
      bloc.addProduct();
    }

    // Defer setDefaultSalesUser and focus to after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setDefaultSalesUser();
      categoriesBloc.add(FetchCategoriesList(context));
      brandBloc.add(FetchBrandList(context));
      _ensureControllersForExistingProducts();

      // Request keyboard focus so RawKeyboardListener receives scanner input
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Future<void> setDefaultSalesUser() async {
    final token = await LocalDB.getLoginInfo();
    final loginUserId = token?['userId'];
    final bloc = context.read<CreatePosSaleBloc>();
    bloc.selectClintModel = CustomerActiveModel(
      name: 'Walk-in-customer',
      id: -1,
    );

    final userList = context.read<UserBloc>().list;
    if (userList.isEmpty) return;

    final matchedUser = userList.firstWhere(
          (user) => user.id == loginUserId,
      orElse: () => userList.first,
    );

    bloc.selectSalesModel = matchedUser;
    if (mounted) setState(() {});
  }

  void _ensureControllersForExistingProducts() {
    // Ensure controllers exist for products already present in bloc when screen opens.
    final bloc = context.read<CreatePosSaleBloc>();
    for (int i = 0; i < bloc.products.length; i++) {
      controllers.putIfAbsent(
        i,
            () => {
          "price": TextEditingController(
            text: _toDouble(bloc.products[i]["price"]).toStringAsFixed(2),
          ),
          "discount": TextEditingController(
            text: _toDouble(bloc.products[i]["discount"]).toString(),
          ),
          "quantity": TextEditingController(
            text: (bloc.products[i]["quantity"]?.toString() ?? "1"),
          ),
          "ticket_total": TextEditingController(
            text: _toDouble(
              bloc.products[i]["ticket_total"],
            ).toStringAsFixed(2),
          ),
          "total": TextEditingController(
            text: _toDouble(bloc.products[i]["total"]).toStringAsFixed(2),
          ),
        },
      );
    }

    // If there are controllers but some ticket_total/total are empty, compute them
    for (int i = 0; i < bloc.products.length; i++) {
      updateTotal(i);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    changeAmountController.dispose();
    productSearchController.dispose();
    _focusNode.dispose();
    // controllers are owned by CreatePosSaleBloc; dispose there if needed
    super.dispose();
  }

  void _updateChangeAmount() {
    final bloc = context.read<CreatePosSaleBloc>();
    final payableAmount = double.tryParse(bloc.payableAmount.text) ?? 0.0;
    final changeAmount = calculateAllFinalTotal() - payableAmount;

    setState(() {
      changeAmountController.text = changeAmount.toStringAsFixed(2);
    });
  }

  // Helper to compute grand/net total same as in summary widget
  double calculateAllFinalTotal() {
    final bloc = context.read<CreatePosSaleBloc>();
    final productList = products;
    double specificDiscount = productList.fold(0.0, (p, e) {
      final disc = _toDouble(e["discount"]);
      final ticket = _toDouble(e["ticket_total"]);
      return p + ((e["discount_type"] == 'percent') ? (ticket * (disc / 100.0)) : disc);
    });
    double subTotal = productList.fold(0.0, (p, e) => p + _toDouble(e["total"]));
    double overallDiscount =
        double.tryParse(bloc.discountOverAllController.text) ?? 0.0;
    if (selectedOverallDiscountType == 'percent') {
      overallDiscount = subTotal * (overallDiscount / 100.0);
    }
    double vat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;
    if (selectedOverallVatType == 'percent') vat = subTotal * (vat / 100.0);
    double serviceCharge =
        double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;
    if (selectedOverallServiceChargeType == 'percent') {
      serviceCharge = subTotal * (serviceCharge / 100.0);
    }
    double deliveryCharge =
        double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;
    if (selectedOverallDeliveryType == 'percent') {
      deliveryCharge = subTotal * (deliveryCharge / 100.0);
    }
    double netTotal = (subTotal - overallDiscount) + vat + serviceCharge + deliveryCharge;
    return netTotal;
  }

  // Helpers for parsing values safely
  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // Expose the products & controllers from the BLoC
  List<Map<String, dynamic>> get products =>
      context.read<CreatePosSaleBloc>().products;

  Map<int, Map<String, TextEditingController>> get controllers =>
      context.read<CreatePosSaleBloc>().controllers;

  // ---------------- Raw keyboard handling for barcode scanner ----------------
  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final keyLabel = event.character ?? '';

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_barcodeBuffer.isNotEmpty) {
          final code = _barcodeBuffer;
          _barcodeBuffer = '';
          _fetchProduct(code);
        }
      } else if (keyLabel.isNotEmpty && keyLabel != '\n' && keyLabel != '\r') {
        _barcodeBuffer += keyLabel;
      }
    }
  }

  Future<void> _fetchProduct(String sku) async {
    setState(() {});

    final url = Uri.parse('$apiBaseUrl/?sku=$sku');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final product = jsonResponse['data'];

          // Update local scanned list (optional)
          final index = _scannedProducts.indexWhere((p) => p['sku'] == product['sku']);
          if (index >= 0) {
            setState(() {
              _scannedProducts[index]['quantity'] += 1;
            });
          } else {
            setState(() {
              _scannedProducts.add({
                'sku': product['sku'],
                'id': product['id'],
                'name': product['name'],
                'selling_price': product['selling_price'],
                'stock_qty': product['stock_qty'],
                'category_info': product['category_info'],
                'brand_info': product['brand_info'],
                'image': product['image'],
                'stock_status_display': product['stock_status_display'],
                'quantity': 1,
              });
            });
          }

          setState(() {});

          // Normalize product map for internal use then add to sale list
          final productMap = {
            'id': product['id'],
            'sku': product['sku'] ?? product['id']?.toString(),
            'name': product['name'],
            'selling_price': product['selling_price'],
            'price': product['selling_price'],
            'stock_qty': product['stock_qty'],
            'category_info': product['category_info'],
            'brand_info': product['brand_info'],
            'image': product['image'],
            'stock_status_display': product['stock_status_display'],
            'discount': product['discount'] ?? 0,
            'discount_type': product['discount_type'] ?? 'fixed',
            'discount_applied': product['discount_applied'] ?? false,
          };

          _addScannedProductToSale(productMap);
        } else {
          setState(() {});
        }
      } else if (response.statusCode == 404) {
        setState(() {});
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        log('Fetch product error: $e');
      });
    }
  }

  // Add scanned product into the current sale products list
  void _addScannedProductToSale(Map<String, dynamic> productJson) {
    final bloc = context.read<CreatePosSaleBloc>();

    // ensure at least one row
    if (bloc.products.isEmpty) bloc.addProduct();

    final emptyIndex = bloc.products.indexWhere((row) => row["product_id"] == null);
    final targetIndex = emptyIndex >= 0 ? emptyIndex : (bloc.products.length - 1);

    // If target already has a product, append new row
    final int useIndex;
    if (bloc.products[targetIndex]["product_id"] != null) {
      bloc.addProduct();
      useIndex = bloc.products.length - 1;
    } else {
      useIndex = targetIndex;
    }

    // Map fields (normalize)
    final pid = productJson['id'] ?? productJson['product_id'] ?? 0;
    final name = productJson['name'] ?? '';
    final sellingPrice = _toDouble(productJson['selling_price'] ?? productJson['price'] ?? productJson['sellingPrice'] ?? 0);
    final discountValue = _toDouble(productJson['discount'] ?? productJson['discount_value'] ?? 0);
    final discountType = (productJson['discount_type'] ?? productJson['discountType'] ?? 'fixed').toString();
    final discountApplied = (productJson['discount_applied'] ?? productJson['discountApplied'] ?? false) == true;
    final stockQty = _toInt(productJson['stock_qty'] ?? productJson['stockQty'] ?? 0);
    final image = productJson['image']?.toString();

    // Construct ProductModelStockModel (fields used in this screen)
    final model = ProductModelStockModel(
      id: _toInt(pid),
      name: name,
      stockQty: stockQty,
      sellingPrice: sellingPrice,
      discountValue: discountValue,
      discountType: discountType,
      discountApplied: discountApplied,
      image: image,
    );

    // Use existing logic to set product into row (validations handled there)
    onProductChanged(useIndex, model);

    // Ensure controllers exist and set values
    controllers.putIfAbsent(
      useIndex,
          () => {
        "price": TextEditingController(text: sellingPrice.toStringAsFixed(2)),
        "discount": TextEditingController(text: discountApplied ? discountValue.toString() : "0"),
        "quantity": TextEditingController(text: "1"),
        "ticket_total": TextEditingController(),
        "total": TextEditingController(),
      },
    );

    controllers[useIndex]!["quantity"]!.text = "1";
    controllers[useIndex]!["price"]!.text = sellingPrice.toStringAsFixed(2);
    controllers[useIndex]!["discount"]!.text = discountApplied ? discountValue.toString() : "0";

    updateTotal(useIndex);

    if (mounted) setState(() {});
  }

  // ---------------- UI builders ----------------

  Widget _buildTopFormSection(CreatePosSaleBloc bloc) {
    // compact single column arrangement for mobile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  return AppDropdown(
                    context: context,
                    label: "Customer",
                    hint: bloc.selectClintModel?.name ?? "Select Customer",
                    isSearch: true,
                    isNeedAll: false,
                    isRequired: true,
                    value: bloc.selectClintModel,
                    itemList:
                    [CustomerActiveModel(name: 'Walk-in-customer', id: -1)] +
                        context.read<CustomerBloc>().activeCustomer,
                    onChanged: (newVal) {
                      bloc.selectClintModel = newVal;
                      bloc.customType = (newVal?.id == -1)
                          ? "Walking Customer"
                          : "Saved Customer";
                      setState(() {});
                    },
                    validator: (value) =>
                    value == null ? 'Please select Customer' : null,
                    itemBuilder: (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item.toString(),
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return AppDropdown(
                    context: context,
                    label: "Sales By",
                    hint: bloc.selectSalesModel?.username ?? "Select Sales",
                    isSearch: true,
                    isNeedAll: false,
                    isRequired: true,
                    value: bloc.selectSalesModel,
                    itemList: context.read<UserBloc>().list,
                    onChanged: (newVal) {
                      bloc.selectSalesModel = newVal;
                      setState(() {});
                    },
                    validator: (value) =>
                    value == null ? 'Please select Sales' : null,
                    itemBuilder: (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item.toString(),
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
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
                radius: 10,
                isRequired: true,
                readOnly: true,
                controller: bloc.dateEditingController,
                hintText: 'Sale Date',
                keyboardType: TextInputType.datetime,
                autofillHints: AutofillHints.name,
                bottom: 15.0,
                fillColor: AppColors.whiteColor,
                validator: (value) => value!.isEmpty ? 'Please enter date' : null,
                onTap: _selectDate,
              ),
            ),
            const SizedBox(width: 8),
            // Quick button to open product browser
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _openProductBrowser,
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductListSection(CreatePosSaleBloc bloc) {
    return Column(
      children: [
        // Header row (mobile compact)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(flex: 4, child: Text('Product', style: AppTextStyle.cardLevelHead(context))),
              Expanded(flex: 2, child: Text('Qty', style: AppTextStyle.cardLevelHead(context), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Price', style: AppTextStyle.cardLevelHead(context), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Net', style: AppTextStyle.cardLevelHead(context), textAlign: TextAlign.center)),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Product rows
        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final discountApplied = product["discountApplied"] == true;
          final selectedItem = product["product"] as ProductModelStockModel?;
          final title = selectedItem?.name ?? product["product"]?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyle.cardLevelText(context), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Stock: ${product["stock_qty"] ?? selectedItem?.stockQty ?? 0}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            if (product["discount_type"] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product["discount_type"] == 'percent' ? '${product["discount"] ?? 0}% off' : 'Tk ${product["discount"] ?? 0}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 34,
                              width: 34,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                onPressed: () {
                                  int currentQuantity = int.tryParse(
                                    controllers[index]?["quantity"]?.text ?? "0",
                                  ) ??
                                      0;
                                  if (currentQuantity > 1) {
                                    controllers[index]!["quantity"]!.text = (currentQuantity - 1).toString();
                                    products[index]["quantity"] = _toInt(controllers[index]!["quantity"]!.text);
                                    updateTotal(index);
                                  }
                                },
                                child: const Icon(Icons.remove, size: 18),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 36,
                              child: TextFormField(
                                controller: controllers[index]?["quantity"],
                                style: AppTextStyle.cardLevelText(context),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                readOnly: discountApplied,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 6)),
                                onChanged: discountApplied ? null : (value) {
                                  final parsed = double.tryParse(value) ?? 0.0;
                                  products[index]["quantity"] = parsed.toInt();
                                  controllers[index]!["quantity"]!.text = parsed.toInt().toString();
                                  updateTotal(index);
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              height: 34,
                              width: 34,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: AppColors.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                onPressed: () {
                                  int currentQuantity = int.tryParse(
                                    controllers[index]?["quantity"]?.text ?? "0",
                                  ) ??
                                      0;
                                  controllers[index]!["quantity"]!.text = (currentQuantity + 1).toString();
                                  products[index]["quantity"] = _toInt(controllers[index]!["quantity"]!.text);
                                  updateTotal(index);
                                },
                                child: const Icon(Icons.add, size: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('৳ ${controllers[index]?["price"]?.text ?? '0'}', textAlign: TextAlign.center, style: AppTextStyle.cardLevelText(context)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('৳ ${controllers[index]?["total"]?.text ?? '0'}', textAlign: TextAlign.center, style: AppTextStyle.cardLevelText(context)),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (product == products.last) {
                            context.read<CreatePosSaleBloc>().addProduct();
                          } else {
                            context.read<CreatePosSaleBloc>().removeProduct(index);
                          }
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: product == products.last ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: product == products.last ? Colors.green : Colors.red),
                          ),
                          child: Icon(product == products.last ? Icons.add : Icons.delete, color: product == products.last ? Colors.green : Colors.red, size: 18),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (product["discount_type"] != null)
                        Text(product["discount_type"] == 'percent' ? '%' : 'Tk', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void updateTotal(int index) {
    if (controllers[index] == null) return;

    final priceText = controllers[index]?["price"]?.text ?? "0";
    final quantityText = controllers[index]?["quantity"]?.text ?? "0";
    final discountText = controllers[index]?["discount"]?.text ?? "0";
    final discountType = products[index]["discount_type"]?.toString() ?? "fixed";

    final price = double.tryParse(priceText) ?? 0.0;
    final quantity = int.tryParse(quantityText) ?? 0;
    double discountValue = double.tryParse(discountText) ?? 0.0;

    final double ticketTotal = price * quantity;
    controllers[index]!["ticket_total"]?.text = ticketTotal.toStringAsFixed(2);
    products[index]["ticket_total"] = ticketTotal;

    double discountAmount = discountType == 'percent'
        ? ticketTotal * (discountValue / 100.0)
        : discountValue;
    double finalTotal = (ticketTotal - discountAmount).clamp(
      0.0,
      double.infinity,
    );
    controllers[index]!["total"]?.text = finalTotal.toStringAsFixed(2);
    products[index]["total"] = finalTotal;

    products[index]["price"] = price;
    products[index]["quantity"] = quantity;

    if (mounted) setState(() {});
  }

  void onProductChanged(int index, ProductModelStockModel? newVal) {
    if (newVal == null) return;

    final alreadyAdded = products.asMap().entries.any(
          (entry) => entry.key != index && entry.value["product_id"] == newVal.id,
    );

    if (alreadyAdded) {
      showCustomToast(
        context: context,
        title: 'Alert!',
        description: "This product is already added",
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
      return;
    }

    if ((newVal.stockQty ?? 0) <= 0) {
      showCustomToast(
        context: context,
        title: 'Alert!',
        description: "Product stock not available",
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    products[index]["product"] = newVal;
    products[index]["product_id"] = newVal.id;
    products[index]["price"] = _toDouble(newVal.sellingPrice);
    products[index]["discount"] = _toDouble(newVal.discountValue);
    products[index]["discount_type"] = newVal.discountType ?? "fixed";
    products[index]["discountApplied"] = newVal.discountApplied ?? false;

    // ensure controllers exist
    controllers.putIfAbsent(
      index,
          () => {
        "price": TextEditingController(),
        "discount": TextEditingController(),
        "quantity": TextEditingController(text: "1"),
        "ticket_total": TextEditingController(),
        "total": TextEditingController(),
      },
    );

    controllers[index]!["price"]!.text = _toDouble(
      newVal.sellingPrice,
    ).toStringAsFixed(2);
    controllers[index]!["discount"]!.text = (newVal.discountApplied == true
        ? _toDouble(newVal.discountValue).toString()
        : "0");
    controllers[index]!["quantity"]!.text =
    controllers[index]!["quantity"]!.text.isEmpty
        ? "1"
        : controllers[index]!["quantity"]!.text;

    updateTotal(index);
  }

  // Charges section (kept, compact)
  Widget _buildChargesSection(CreatePosSaleBloc bloc) {
    Widget chargeField(
        String label,
        String selectedType,
        TextEditingController controller,
        Function(String) onTypeChanged,
        ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.cardLevelText(context)),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 40,
                child: CupertinoSegmentedControl<String>(
                  padding: EdgeInsets.zero,
                  children: {
                    'fixed': Center(
                      child: Text(
                        'TK',
                        style: TextStyle(
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          color: selectedType == 'fixed' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    'percent': Center(
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          color: selectedType == 'percent' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  },
                  groupValue: selectedType,
                  onValueChanged: onTypeChanged,
                  unselectedColor: Colors.grey[300],
                  selectedColor: AppColors.primaryColor,
                  borderColor: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: CustomInputFieldPayRoll(
                    isRequiredLevle: false,
                    controller: controller,
                    hintText: label,
                    fillColor: Colors.white,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    autofillHints: '',
                    levelText: '',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        chargeField(
          "Discount",
          selectedOverallDiscountType,
          context.read<CreatePosSaleBloc>().discountOverAllController,
              (value) {
            setState(() {
              selectedOverallDiscountType = value;
              context.read<CreatePosSaleBloc>().selectedOverallDiscountType = value;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: chargeField("Vat", selectedOverallVatType, context.read<CreatePosSaleBloc>().vatOverAllController, (value) {
                setState(() {
                  selectedOverallVatType = value;
                  context.read<CreatePosSaleBloc>().selectedOverallVatType = value;
                });
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: chargeField("Service", selectedOverallServiceChargeType, context.read<CreatePosSaleBloc>().serviceChargeOverAllController, (value) {
                setState(() {
                  selectedOverallServiceChargeType = value;
                  context.read<CreatePosSaleBloc>().selectedOverallServiceChargeType = value;
                });
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        chargeField("Delivery", selectedOverallDeliveryType, context.read<CreatePosSaleBloc>().deliveryChargeOverAllController, (value) {
          setState(() {
            selectedOverallDeliveryType = value;
            context.read<CreatePosSaleBloc>().selectedOverallDeliveryType = value;
          });
        }),
      ],
    );
  }

  Widget _buildSummaryAndPayment(CreatePosSaleBloc bloc) {
    double productTotal = products.fold(
      0.0,
          (p, e) => p + _toDouble(e["ticket_total"]),
    );
    double specificDiscount = products.fold(0.0, (p, e) {
      final disc = _toDouble(e["discount"]);
      final ticket = _toDouble(e["ticket_total"]);
      return p +
          ((e["discount_type"] == 'percent') ? (ticket * (disc / 100.0)) : disc);
    });
    double subTotal = products.fold(0.0, (p, e) => p + _toDouble(e["total"]));
    double overallDiscount =
        double.tryParse(bloc.discountOverAllController.text) ?? 0.0;
    if (selectedOverallDiscountType == 'percent') {
      overallDiscount = subTotal * (overallDiscount / 100.0);
    }
    double vat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;
    if (selectedOverallVatType == 'percent') vat = subTotal * (vat / 100.0);
    double serviceCharge =
        double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;
    if (selectedOverallServiceChargeType == 'percent') {
      serviceCharge = subTotal * (serviceCharge / 100.0);
    }
    double deliveryCharge =
        double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;
    if (selectedOverallDeliveryType == 'percent') {
      deliveryCharge = subTotal * (deliveryCharge / 100.0);
    }
    double netTotal = (subTotal - overallDiscount) + vat + serviceCharge + deliveryCharge;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              _buildSummaryRow("Product Total", productTotal),
              _buildSummaryRow("Specific Discount (-)", specificDiscount),
              _buildSummaryRow("Sub Total", subTotal),
              _buildSummaryRow("Discount (-)", overallDiscount),
              _buildSummaryRow("Vat (+)", vat),
              _buildSummaryRow("Service Charge (+)", serviceCharge),
              _buildSummaryRow("Delivery Charge (+)", deliveryCharge),
              const Divider(),
              _buildSummaryRow("Net Total", netTotal),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text("With Money Receipt", style: AppTextStyle.headerTitle(context)),
          value: _isChecked,
          onChanged: (bool? newValue) {
            setState(() {
              _isChecked = newValue ?? false;
              context.read<CreatePosSaleBloc>().isChecked = _isChecked;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (_isChecked) ...[
          AppDropdown(
            context: context,
            label: "Payment Method",
            hint: context.read<CreatePosSaleBloc>().selectedPaymentMethod.isEmpty
                ? "Select Payment Method"
                : context.read<CreatePosSaleBloc>().selectedPaymentMethod,
            isLabel: false,
            isRequired: true,
            isNeedAll: false,
            value: context.read<CreatePosSaleBloc>().selectedPaymentMethod.isEmpty ? null : context.read<CreatePosSaleBloc>().selectedPaymentMethod,
            itemList: [] + context.read<CreatePosSaleBloc>().paymentMethod,
            onChanged: (newVal) {
              context.read<CreatePosSaleBloc>().selectedPaymentMethod = newVal.toString();
              setState(() {});
            },
            validator: (value) => value == null ? 'Please select a payment method' : null,
            itemBuilder: (item) => DropdownMenuItem(value: item, child: Text(item.toString())),
          ),
          const SizedBox(height: 8),
          BlocBuilder<AccountBloc, AccountState>(
            builder: (context, state) {
              if (state is AccountActiveListLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AccountActiveListSuccess) {
                final bloc = context.read<CreatePosSaleBloc>();
                final filteredList = bloc.selectedPaymentMethod.isNotEmpty
                    ? state.list.where((item) => item.acType?.toLowerCase() == bloc.selectedPaymentMethod.toLowerCase()).toList()
                    : state.list;
                final selectedAccount = bloc.accountModel ?? (filteredList.isNotEmpty ? filteredList.first : null);
                bloc.accountModel = selectedAccount;
                return AppDropdown<AccountActiveModel>(
                  context: context,
                  label: "Account",
                  hint: bloc.accountModel == null ? "Select Account" : bloc.accountModel!.name.toString(),
                  isLabel: false,
                  isRequired: true,
                  isNeedAll: false,
                  value: selectedAccount,
                  itemList: filteredList,
                  onChanged: (newVal) {
                    bloc.accountModel = newVal;
                    setState(() {});
                  },
                  validator: (value) => value == null ? 'Please select an account' : null,
                  itemBuilder: (item) => DropdownMenuItem(value: item, child: Text(item.toString())),
                );
              } else {
                return Container();
              }
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: changeAmountController,
                  hintText: 'Change Amount',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: context.read<CreatePosSaleBloc>().payableAmount,
                  hintText: 'Payable Amount',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => setState(() {
                    _updateChangeAmount();
                  }),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        CustomInputField(
          isRequiredLable: true,
          controller: context.read<CreatePosSaleBloc>().remarkController,
          hintText: 'Remark',
          fillColor: Colors.white,
          validator: (value) => value!.isEmpty ? 'Please enter Remark' : null,
          onChanged: (value) => setState(() {}),
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(label, style: AppTextStyle.cardLevelHead(context))),
          Expanded(flex: 2, child: Text(value.toStringAsFixed(2), style: AppTextStyle.cardLevelText(context), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            name: 'Preview',
            onPressed: () {},
            color: const Color(0xff800000),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(name: 'Submit', onPressed: _submitForm),
        ),
      ],
    );
  }

  // Product browser shown as bottom sheet for mobile
  void _openProductBrowser() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: productSearchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search by name / SKU / barcode',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            productSearchController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: BlocBuilder<ProductsBloc, ProductsState>(
                      builder: (context, state) {
                        List<ProductModelStockModel> productList = [];
                        if (state is ProductsListStockSuccess) {
                          productList = state.list;
                        } else if (state is ProductsListLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ProductsListFailed) {
                          return Center(child: Text(state.content));
                        }

                        final query = productSearchController.text.trim().toLowerCase();
                        final filteredProducts = productList.where((p) {
                          final searchableText = [p.name, p.sku].whereType<String>().join(' ').toLowerCase();
                          final matchesSearch = query.isEmpty || searchableText.contains(query);
                          final matchesCategory = selectedCategoryFilter.isEmpty || p.categoryInfo?.name == selectedCategoryFilter;
                          final matchesBrand = selectedBrandFilter.isEmpty || p.brand == selectedBrandFilter;
                          return matchesSearch && matchesCategory && matchesBrand;
                        }).toList();

                        if (filteredProducts.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }

                        return GridView.builder(
                          controller: controller,
                          padding: EdgeInsets.zero,
                          itemCount: filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.78,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) => _buildProductCard(filteredProducts[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductModelStockModel p) {
    return InkWell(
      onTap: () {
        final bloc = context.read<CreatePosSaleBloc>();

        // If products list is empty for some reason, add an empty row first.
        if (bloc.products.isEmpty) {
          bloc.addProduct();
        }

        final emptyIndex = bloc.products.indexWhere((row) => row["product_id"] == null);

        final targetIndex = emptyIndex >= 0 ? emptyIndex : (bloc.products.length - 1);

        // If the target row already has a product, append a new row and use it
        if (bloc.products[targetIndex]["product_id"] != null) {
          bloc.addProduct();
          final newIndex = bloc.products.length - 1;
          onProductChanged(newIndex, p);
          controllers.putIfAbsent(
            newIndex,
                () => {
              "price": TextEditingController(),
              "discount": TextEditingController(),
              "quantity": TextEditingController(text: "1"),
              "ticket_total": TextEditingController(),
              "total": TextEditingController(),
            },
          );
          updateTotal(newIndex);
        } else {
          onProductChanged(targetIndex, p);
          controllers.putIfAbsent(
            targetIndex,
                () => {
              "price": TextEditingController(),
              "discount": TextEditingController(),
              "quantity": TextEditingController(text: "1"),
              "ticket_total": TextEditingController(),
              "total": TextEditingController(),
            },
          );
          updateTotal(targetIndex);
        }
        setState(() {});
        Navigator.pop(context); // close product browser after selection
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            AspectRatio(
              aspectRatio: 1,
              child: p.image != null
                  ? ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(p.image!, fit: BoxFit.cover, width: double.infinity),
              )
                  : Container(
                decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(10)), color: Color(0xfff5f5f5)),
                child: const Center(child: Icon(Icons.image_not_supported, size: 36, color: Colors.black26)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('৳ ${_toDouble(p.sellingPrice).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(p.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('${p.brandInfo?.name ?? ''} • ${p.categoryInfo?.name ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(color: p.stockQty == 0 ? Colors.grey : Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                        child: Text('Stock ${p.stockQty ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      Icon(Icons.add_circle_outline, color: AppColors.primaryColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Date selector
  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final bloc = context.read<CreatePosSaleBloc>();
      bloc.dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(pickedDate);
      setState(() {});
    }
  }

  // Submit form
  void _submitForm() {
    if (!formKey.currentState!.validate()) return;
    final bloc = context.read<CreatePosSaleBloc>();

    var transferProducts = products.map((product) {
      return {
        "product_id": _toInt(product["product_id"]),
        "quantity": _toInt(product["quantity"]),
        "unit_price": _toDouble(product["price"]),
        "discount": _toDouble(product["discount"]),
        "discount_type": product["discount_type"]?.toString() ?? 'fixed',
      };
    }).toList();

    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;

    Map<String, dynamic> body = {
      "type": "normal_sale",
      "sale_date": appWidgets.convertDateTime(
        DateFormat("dd-MM-yyyy").parse(bloc.dateEditingController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "sale_by": bloc.selectSalesModel?.id.toString() ?? '',
      "overall_vat_type": selectedOverallVatType.toLowerCase(),
      "vat": bloc.vatOverAllController.text.isEmpty ? 0 : double.tryParse(bloc.vatOverAllController.text),
      "overall_service_type": selectedOverallServiceChargeType.toLowerCase(),
      "service_charge": bloc.serviceChargeOverAllController.text.isEmpty ? 0 : double.tryParse(bloc.serviceChargeOverAllController.text),
      "overall_delivery_type": selectedOverallDeliveryType.toLowerCase(),
      "delivery_charge": bloc.deliveryChargeOverAllController.text.isEmpty ? 0 : double.tryParse(bloc.deliveryChargeOverAllController.text),
      "overall_discount_type": selectedOverallDiscountType.toLowerCase(),
      "overall_discount": bloc.discountOverAllController.text.isEmpty ? 0.0 : double.tryParse(bloc.discountOverAllController.text),
      "remark": bloc.remarkController.text,
      "items": transferProducts,
      "customer_type": isWalkInCustomer ? "walk_in" : "saved_customer",
      "with_money_receipt": _isChecked ? "Yes" : "No",
      "paid_amount": double.tryParse(bloc.payableAmount.text.trim()) ?? 0,
    };

    if (!isWalkInCustomer) body['customer_id'] = selectedCustomer?.id.toString() ?? '';

    if (isWalkInCustomer) {
      final subTotal = products.fold(0.0, (p, e) => p + _toDouble(e["total"]));
      double overallDiscount = double.tryParse(bloc.discountOverAllController.text) ?? 0.0;
      if (selectedOverallDiscountType == 'percent') overallDiscount = subTotal * (overallDiscount / 100.0);
      double vat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;
      if (selectedOverallVatType == 'percent') vat = subTotal * (vat / 100.0);
      double serviceVal = double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;
      if (selectedOverallServiceChargeType == 'percent') serviceVal = subTotal * (serviceVal / 100.0);
      double delivery = double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;
      if (selectedOverallDeliveryType == 'percent') delivery = subTotal * (delivery / 100.0);

      final netTotal = (subTotal - overallDiscount) + vat + serviceVal + delivery;
      final paidAmount = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;
      if (paidAmount < netTotal) {
        showCustomToast(
          context: context,
          title: 'Warning!',
          description: "Walk-in customer: Full payment required. No due allowed.",
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return;
      }
    }

    if (_isChecked) {
      body['payment_method'] = bloc.selectedPaymentMethod;
      body['account_id'] = bloc.accountModel?.id.toString() ?? '';
    }

    bloc.add(AddPosSale(body: body));
    log(body.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Use mobile-first layout inside Scaffold
    final availableHeight = MediaQuery.of(context).size.height - kToolbarHeight - 24;

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKey,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('POS - Mobile'),
          actions: [
            IconButton(
              onPressed: _openProductBrowser,
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 6),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openProductBrowser,
          child: const Icon(Icons.add_shopping_cart),
        ),
        body: SafeArea(
          child: BlocConsumer<CreatePosSaleBloc, CreatePosSaleState>(
            listener: (context, state) {
              if (state is CreatePosSaleLoading) {
                appLoader(context, "Creating PosSale, please wait...");
              } else if (state is CreatePosSaleSuccess) {
                Navigator.pop(context);
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: "Sale created successfully!",
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );
                changeAmountController.clear();
                context.read<DashboardBloc>().add(
                  ChangeDashboardScreen(index: 2),
                );
                setState(() {});
              } else if (state is CreatePosSaleFailed) {
                Navigator.pop(context);
                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => AppRoutes.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }
            },
            builder: (context, state) {
              final bloc = context.read<CreatePosSaleBloc>();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopFormSection(bloc),
                        const SizedBox(height: 12),
                        _buildProductListSection(bloc),
                        const SizedBox(height: 12),
                        _buildChargesSection(bloc),
                        const SizedBox(height: 12),
                        _buildSummaryAndPayment(bloc),
                        const SizedBox(height: 12),
                        _buildActionButtons(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}