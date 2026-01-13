// NOTE: adjust imports paths to match your project structure
import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../../data/models/pos_sale_model.dart';
import '../mobile_pos_sale_screen.dart';
import '/core/core.dart';
import '/feature/products/product/data/model/product_stock_model.dart';
import '/feature/users_list/presentation/bloc/users/user_bloc.dart';

import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
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
  late CreatePosSaleBloc createPosSaleBloc;

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
    createPosSaleBloc = context.read<CreatePosSaleBloc>();

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

    // For walk-in customer (default), set _isChecked to false
    bloc.selectClintModel = CustomerActiveModel(
      name: 'Walk-in-customer',
      id: -1,
    );
    _isChecked = false;
    bloc.isChecked = false;

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
    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;
    final payableAmount = double.tryParse(bloc.payableAmount.text) ?? 0.0;
    final netTotal = calculateAllFinalTotal();
    final changeAmount = payableAmount - netTotal;

    // For walk-in customers, change amount should be 0 (no advance)
    if (isWalkInCustomer) {
      // Walk-in customer: Must pay exact amount, no change
      if (payableAmount != netTotal) {
        showCustomToast(
          context: context,
          title: 'Warning!',
          description:
          "Walk-in customer must pay exact amount. No change allowed.",
          icon: Icons.warning,
          primaryColor: Colors.orange,
        );
        // Auto-correct to exact amount
        bloc.payableAmount.text = netTotal.toStringAsFixed(2);
        setState(() {
          changeAmountController.text = "0.00";
        });
        return;
      }
    }

    setState(() {
      changeAmountController.text = changeAmount.toStringAsFixed(2);
    });
  }

  // Helper to compute grand/net total same as in summary widget
  double calculateAllFinalTotal() {
    final bloc = context.read<CreatePosSaleBloc>();
    final productList = products;
    double subTotal = productList.fold(
      0.0,
          (p, e) => p + _toDouble(e["total"]),
    );
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
    double netTotal =
        (subTotal - overallDiscount) + vat + serviceCharge + deliveryCharge;
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
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final product = jsonResponse['data'];

          // Update local scanned list (optional)
          final index = _scannedProducts.indexWhere(
                (p) => p['sku'] == product['sku'],
          );
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

    final emptyIndex = bloc.products.indexWhere(
          (row) => row["product_id"] == null,
    );
    final targetIndex =
    emptyIndex >= 0 ? emptyIndex : (bloc.products.length - 1);

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
    final sellingPrice = _toDouble(
      productJson['selling_price'] ??
          productJson['price'] ??
          productJson['sellingPrice'] ??
          0,
    );
    final discountValue = _toDouble(
      productJson['discount'] ?? productJson['discount_value'] ?? 0,
    );
    final discountType =
    (productJson['discount_type'] ?? productJson['discountType'] ?? 'fixed')
        .toString();
    final discountApplied =
        (productJson['discount_applied'] ??
            productJson['discountApplied'] ??
            false) ==
            true;
    final stockQty = _toInt(
      productJson['stock_qty'] ?? productJson['stockQty'] ?? 0,
    );
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
        "discount": TextEditingController(
          text: discountApplied ? discountValue.toString() : "0",
        ),
        "quantity": TextEditingController(text: "1"),
        "ticket_total": TextEditingController(),
        "total": TextEditingController(),
      },
    );

    controllers[useIndex]!["quantity"]!.text = "1";
    controllers[useIndex]!["price"]!.text = sellingPrice.toStringAsFixed(2);
    controllers[useIndex]!["discount"]!.text =
    discountApplied ? discountValue.toString() : "0";

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
                    itemList: [
                      CustomerActiveModel(name: 'Walk-in-customer', id: -1),
                    ] +
                        context.read<CustomerBloc>().activeCustomer,
                    onChanged: (newVal) {
                      bloc.selectClintModel = newVal;
                      bloc.customType = (newVal?.id == -1)
                          ? "Walking Customer"
                          : "Saved Customer";

                      // Apply customer type rules
                      if (newVal?.id == -1) {
                        // Walk-in customer: set _isChecked to false
                        _isChecked = false;
                        bloc.isChecked = false;
                        // Auto-set payable amount to net total for walk-in customer
                        Future.delayed(const Duration(milliseconds: 100), () {
                          final netTotal = calculateAllFinalTotal();
                          bloc.payableAmount.text = netTotal.toStringAsFixed(2);
                          _updateChangeAmount();
                        });
                      } else {
                        // Saved customer: set _isChecked to true
                        _isChecked = true;
                        bloc.isChecked = true;
                      }
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
                validator: (value) =>
                value!.isEmpty ? 'Please enter date' : null,
                onTap: _selectDate,
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
        // Simple header (mobile)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.centerLeft,
          child: Text('Products', style: AppTextStyle.titleMedium(context)),
        ),

        const SizedBox(height: 6),

        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final discountApplied = product["discountApplied"] == true;
          final selectedItem = product["product"] as ProductModelStockModel?;
          final title = selectedItem?.name ?? 'Select Product';
          final productId = product["product_id"];
          final isProductSelected = productId != null;

          return Card(
            margin: const EdgeInsets.only(bottom: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Product name + add/delete
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: isProductSelected
                              ? AppTextStyle.titleSmall(context)
                              : AppTextStyle.titleSmall(context).copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (product == products.last) {
                            context.read<CreatePosSaleBloc>().addProduct();
                          } else {
                            context
                                .read<CreatePosSaleBloc>()
                                .removeProduct(index);
                          }
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: product == products.last
                                ? Colors.green.withOpacity(0.08)
                                : Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            product == products.last ? Icons.add : Icons.delete,
                            size: 18,
                            color: product == products.last
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (isProductSelected) ...[
                    /// 🔹 Stock + discount
                    Row(
                      children: [
                        Text(
                          'Stock: ${product["stock_qty"] ?? selectedItem?.stockQty ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product["discount_type"] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product["discount_type"] == 'percent'
                                  ? '${product["discount"] ?? 0}% off'
                                  : 'Tk ${product["discount"] ?? 0}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    /// 🔹 Qty + Price + Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Qty controller
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                int q = int.tryParse(
                                  controllers[index]?["quantity"]
                                      ?.text ??
                                      "0",
                                ) ??
                                    0;
                                if (q > 1) {
                                  controllers[index]!["quantity"]!.text =
                                  "${q - 1}";
                                  products[index]["quantity"] = q - 1;
                                  updateTotal(index);
                                }
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: TextFormField(
                                controller: controllers[index]?["quantity"],
                                readOnly: discountApplied,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 4,
                                  ),
                                ),
                                onChanged: discountApplied
                                    ? null
                                    : (v) {
                                  final q = int.tryParse(v) ?? 0;
                                  controllers[index]!["quantity"]!.text =
                                  "$q";
                                  products[index]["quantity"] = q;
                                  updateTotal(index);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                int q = int.tryParse(
                                  controllers[index]?["quantity"]
                                      ?.text ??
                                      "0",
                                ) ??
                                    0;
                                controllers[index]!["quantity"]!.text =
                                "${q + 1}";
                                products[index]["quantity"] = q + 1;
                                updateTotal(index);
                              },
                            ),
                          ],
                        ),

                        /// Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price',
                              style: AppTextStyle.cardLevelHead(context),
                            ),
                            Text(
                              '৳ ${controllers[index]?["price"]?.text ?? '0'}',
                              style: AppTextStyle.cardLevelText(context),
                            ),
                          ],
                        ),

                        /// Total
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total',
                              style: AppTextStyle.cardLevelHead(context),
                            ),
                            Text(
                              '৳ ${controllers[index]?["total"]?.text ?? '0'}',
                              style: AppTextStyle.cardLevelText(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    // Show message when no product selected
                    const SizedBox(height: 10),
                    Text(
                      'Tap the product browser button below to add products',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void updateTotal(int index) {
    if (controllers[index] == null) return;

    final priceText = controllers[index]?["price"]?.text ?? "0";
    final quantityText = controllers[index]?["quantity"]?.text ?? "0";
    final discountText = controllers[index]?["discount"]?.text ?? "0";
    final discountType =
        products[index]["discount_type"]?.toString() ?? "fixed";

    final price = double.tryParse(priceText) ?? 0.0;
    final quantity = int.tryParse(quantityText) ?? 0;
    double discountValue = double.tryParse(discountText) ?? 0.0;

    final double ticketTotal = price * quantity;
    controllers[index]!["ticket_total"]?.text = ticketTotal.toStringAsFixed(2);
    products[index]["ticket_total"] = ticketTotal;

    double discountAmount = discountType == 'percent'
        ? ticketTotal * (discountValue / 100.0)
        : discountValue;
    double finalTotal =
    (ticketTotal - discountAmount).clamp(0.0, double.infinity);
    controllers[index]!["total"]?.text = finalTotal.toStringAsFixed(2);
    products[index]["total"] = finalTotal;

    products[index]["price"] = price;
    products[index]["quantity"] = quantity;

    if (mounted) setState(() {});
  }

  void onProductChanged(int index, ProductModelStockModel? newVal) {
    if (newVal == null) return;

    final alreadyAdded = products.asMap().entries.any(
            (entry) => entry.key != index && entry.value["product_id"] == newVal.id);

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
    products[index]["stock_qty"] = newVal.stockQty;

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

    controllers[index]!["price"]!.text =
        _toDouble(newVal.sellingPrice).toStringAsFixed(2);
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
                          color: selectedType == 'fixed'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    'percent': Center(
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          color: selectedType == 'percent'
                              ? Colors.white
                              : Colors.black,
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
        Row(children: [
          Expanded(
            child: chargeField(
              "Discount",
              selectedOverallDiscountType,
              context.read<CreatePosSaleBloc>().discountOverAllController,
                  (value) {
                setState(() {
                  selectedOverallDiscountType = value;
                  context.read<CreatePosSaleBloc>().selectedOverallDiscountType =
                      value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: chargeField(
              "Delivery",
              selectedOverallDeliveryType,
              context.read<CreatePosSaleBloc>().deliveryChargeOverAllController,
                  (value) {
                setState(() {
                  selectedOverallDeliveryType = value;
                  context.read<CreatePosSaleBloc>().selectedOverallDeliveryType =
                      value;
                });
              },
            ),
          )
        ]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: chargeField(
                "Vat",
                selectedOverallVatType,
                context.read<CreatePosSaleBloc>().vatOverAllController,
                    (value) {
                  setState(() {
                    selectedOverallVatType = value;
                    context.read<CreatePosSaleBloc>().selectedOverallVatType =
                        value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: chargeField(
                "Service",
                selectedOverallServiceChargeType,
                context
                    .read<CreatePosSaleBloc>()
                    .serviceChargeOverAllController,
                    (value) {
                  setState(() {
                    selectedOverallServiceChargeType = value;
                    context
                        .read<CreatePosSaleBloc>()
                        .selectedOverallServiceChargeType = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryAndPayment(CreatePosSaleBloc bloc) {
    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;
    final netTotal = calculateAllFinalTotal();

    return Column(
      children: [
        // Show customer type info
        if (isWalkInCustomer)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Walk-in Customer: Must pay exact amount. No due or advance allowed.",
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Saved Customer: Due or advance payment allowed. Money receipt required.",
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                  "Product Total",
                  products.fold(
                    0.0,
                        (p, e) => p + _toDouble(e["ticket_total"]),
                  )),
              _buildSummaryRow("Specific Discount (-)", products.fold(0.0, (p, e) {
                final disc = _toDouble(e["discount"]);
                final ticket = _toDouble(e["ticket_total"]);
                return p +
                    ((e["discount_type"] == 'percent')
                        ? (ticket * (disc / 100.0))
                        : disc);
              })),
              _buildSummaryRow("Sub Total",
                  products.fold(0.0, (p, e) => p + _toDouble(e["total"]))),
              _buildSummaryRow("Discount (-)",
                  double.tryParse(bloc.discountOverAllController.text) ?? 0.0),
              _buildSummaryRow("Vat (+)",
                  double.tryParse(bloc.vatOverAllController.text) ?? 0.0),
              _buildSummaryRow("Service Charge (+)",
                  double.tryParse(bloc.serviceChargeOverAllController.text) ??
                      0.0),
              _buildSummaryRow("Delivery Charge (+)",
                  double.tryParse(bloc.deliveryChargeOverAllController.text) ??
                      0.0),
              const Divider(),
              _buildSummaryRow("Net Total", netTotal, isBold: true),
            ],
          ),
        ),

        // Checkbox should be visible for all customers but disabled for walk-in
        CheckboxListTile(
          title: Text(
            "With Money Receipt",
            style: AppTextStyle.headerTitle(context),
          ),
          value: _isChecked,
          onChanged: isWalkInCustomer
              ? null // Disabled for walk-in customers
              : (bool? newValue) {
            setState(() {
              _isChecked = newValue ?? false;
              context.read<CreatePosSaleBloc>().isChecked = _isChecked;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          secondary: isWalkInCustomer
              ? Icon(Icons.info, color: Colors.orange[700], size: 20)
              : null,
        ),

        // Show payment section only when _isChecked is true
        if (_isChecked) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: AppDropdown(
                  context: context,
                  label: "Payment Method",
                  hint: bloc.selectedPaymentMethod.isEmpty
                      ? "Select Payment Method"
                      : bloc.selectedPaymentMethod,
                  isLabel: false,
                  isRequired: true,
                  isNeedAll: false,
                  value: bloc.selectedPaymentMethod.isEmpty
                      ? null
                      : bloc.selectedPaymentMethod,
                  itemList: [] + bloc.paymentMethod,
                  onChanged: (newVal) {
                    bloc.selectedPaymentMethod = newVal.toString();
                    setState(() {});
                  },
                  validator: (value) =>
                  value == null ? 'Please select a payment method' : null,
                  itemBuilder: (item) =>
                      DropdownMenuItem(value: item, child: Text(item.toString())),
                )),
            const SizedBox(width: 6),
            Expanded(
                child: BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                    if (state is AccountActiveListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AccountActiveListSuccess) {
                      final filteredList = bloc.selectedPaymentMethod.isNotEmpty
                          ? state.list
                          .where(
                            (item) =>
                        item.acType?.toLowerCase() ==
                            bloc.selectedPaymentMethod.toLowerCase(),
                      )
                          .toList()
                          : state.list;
                      final selectedAccount = bloc.accountModel ??
                          (filteredList.isNotEmpty ? filteredList.first : null);
                      bloc.accountModel = selectedAccount;
                      return AppDropdown<AccountActiveModel>(
                        context: context,
                        label: "Account",
                        hint: bloc.accountModel == null
                            ? "Select Account"
                            : bloc.accountModel!.name.toString(),
                        isLabel: false,
                        isRequired: true,
                        isNeedAll: false,
                        value: selectedAccount,
                        itemList: filteredList,
                        onChanged: (newVal) {
                          bloc.accountModel = newVal;
                          setState(() {});
                        },
                        validator: (value) =>
                        value == null ? 'Please select an account' : null,
                        itemBuilder: (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.toString()),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ))
          ])
        ],

        // Payable amount section (common for both)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show change amount only when there's a payment (not for walk-in when not checked)
            if (_isChecked)
              Expanded(
                child: AppTextField(
                  controller: changeAmountController,
                  hintText: 'Change Amount',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  readOnly: true,
                ),
              ),
            if (_isChecked) const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: bloc.payableAmount,
                    hintText: isWalkInCustomer && !_isChecked
                        ? 'Payable Amount (Auto-set to net total)'
                        : 'Payable Amount',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter Payable Amount';
                      }
                      final numericValue = double.tryParse(value);
                      if (numericValue == null) {
                        return 'Enter valid number';
                      }
                      if (numericValue < 0) {
                        return 'Cannot be negative';
                      }

                      // Walk-in customer validation - must pay exact amount
                      if (isWalkInCustomer && numericValue != netTotal) {
                        return 'Must pay exact: ${netTotal.toStringAsFixed(2)}';
                      }

                      return null;
                    },
                    onChanged: (v) => setState(() {
                      _updateChangeAmount();
                    }),
                  ),
                  if (isWalkInCustomer)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "Walk-in: Must pay exact amount ${netTotal.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (!isWalkInCustomer)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "Due: ${(netTotal - (double.tryParse(bloc.payableAmount.text.trim()) ?? 0)).clamp(0, double.infinity).toStringAsFixed(2)}",
                        style: TextStyle(
                          color: (double.tryParse(
                              bloc.payableAmount.text.trim()) ??
                              0) >=
                              netTotal
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        CustomInputField(
          isRequiredLable: true,
          controller: bloc.remarkController,
          hintText: 'Remark',
          fillColor: Colors.white,
          validator: (value) => value!.isEmpty ? 'Please enter Remark' : null,
          onChanged: (value) => setState(() {}),
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: AppTextStyle.cardLevelHead(context)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value.toStringAsFixed(2),
              style: isBold
                  ? AppTextStyle.cardLevelText(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              )
                  : AppTextStyle.cardLevelText(context),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Fixed PDF Preview function
  void _generatePdf(BuildContext context) async {
    // Create a mock PosSaleModel for preview
    final bloc = context.read<CreatePosSaleBloc>();
    final netTotal = calculateAllFinalTotal();
    final subTotal = products.fold(
      0.0,
          (p, e) => p + _toDouble(e["total"]),
    );
    final overallDiscount =
        double.tryParse(bloc.discountOverAllController.text) ?? 0.0;
    final vat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;
    final serviceCharge =
        double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;
    final deliveryCharge =
        double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;

    // Create a preview sale model
    final previewSale = PosSaleModel(
      id: 0,
      invoiceNo: 'PREVIEW-${DateTime.now().millisecondsSinceEpoch}',
      saleDate: DateTime.now(),
      // formattedSaleDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
      // formattedTime: DateFormat('hh:mm a').format(DateTime.now()),
      netTotal: netTotal,
      grandTotal: netTotal,
      overallDiscount: overallDiscount,
      overallVatAmount: vat,
      // paymentStatus: 'pending',
      customerName: bloc.selectClintModel?.name ?? 'Walk-in Customer',
      saleByName: bloc.selectSalesModel?.username ?? 'Sales Person',
      remark: bloc.remarkController.text,
      paymentMethod: bloc.selectedPaymentMethod,
      accountName: bloc.accountModel?.name,
      items: products.where((p) => p["product_id"] != null).map((p) {
        final product = p["product"] as ProductModelStockModel?;
        return PosSaleItem(
          productName: product?.name ?? 'Product',
          quantity: _toInt(p["quantity"]),
          unitPrice: _toDouble(p["price"]),
          subtotal: _toDouble(p["total"]),
        );
      }).toList(),
    );

    try {
      final companyInfo = context
          .read<ProfileBloc>()
          .permissionModel
          ?.data
          ?.companyInfo;

      // Generate PDF bytes
      final pdfBytes = await generateSalesPreviewPdf(previewSale, companyInfo);

      // Show PDF preview
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
      );
    } catch (e) {
      showCustomToast(
        context: context,
        title: 'Error!',
        description: 'Failed to generate PDF: ${e.toString()}',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            name: 'Preview',
            onPressed: () => _generatePdf(context),
            color: const Color(0xff800000),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(name: 'Submit', onPressed: _validateAndSubmitForm),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Product List ",
                          style: AppTextStyle.titleMedium(context)),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: productSearchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search by name / SKU / barcode',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
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
                      ),
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is ProductsListFailed) {
                          return Center(child: Text(state.content));
                        }

                        final query =
                        productSearchController.text.trim().toLowerCase();
                        final filteredProducts = productList.where((p) {
                          final searchableText = [
                            p.name,
                            p.sku,
                          ].whereType<String>().join(' ').toLowerCase();
                          final matchesSearch =
                              query.isEmpty || searchableText.contains(query);
                          final matchesCategory = selectedCategoryFilter.isEmpty ||
                              p.categoryInfo?.name == selectedCategoryFilter;
                          final matchesBrand = selectedBrandFilter.isEmpty ||
                              p.brand == selectedBrandFilter;
                          return matchesSearch &&
                              matchesCategory &&
                              matchesBrand;
                        }).toList();

                        if (filteredProducts.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }

                        return GridView.builder(
                          controller: controller,
                          padding: EdgeInsets.zero,
                          itemCount: filteredProducts.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.90,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) =>
                              _buildProductCard(filteredProducts[index]),
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
    final bloc = context.read<CreatePosSaleBloc>();

    final existingIndex = bloc.products.indexWhere(
          (row) => row["product_id"] == p.id,
    );
    return InkWell(
      // ➕ ADD PRODUCT / INCREASE QTY
      onTap: () {
        if (existingIndex != -1) {
          final qtyController = controllers[existingIndex]?["quantity"];
          final currentQty = int.tryParse(qtyController?.text ?? "1") ?? 1;

          qtyController?.text = (currentQty + 1).toString();
          bloc.products[existingIndex]["quantity"] = currentQty + 1;
          updateTotal(existingIndex);

          Navigator.pop(context);
          setState(() {});
          return;
        }

        final emptyIndex = bloc.products.indexWhere(
              (row) => row["product_id"] == null,
        );

        final targetIndex =
        emptyIndex != -1 ? emptyIndex : bloc.products.length;

        if (emptyIndex == -1) {
          bloc.addProduct();
        }

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

        bloc.products[targetIndex]["quantity"] = 1;
        updateTotal(targetIndex);

        setState(() {});
      },

      // ➖ REMOVE / DECREASE QTY
      onLongPress: () {
        final bloc = context.read<CreatePosSaleBloc>();

        final existingIndex = bloc.products.indexWhere(
              (row) => row["product_id"] == p.id,
        );

        if (existingIndex == -1) return;

        final qtyController = controllers[existingIndex]?["quantity"];
        final currentQty = int.tryParse(qtyController?.text ?? "1") ?? 1;

        if (currentQty > 1) {
          // decrease qty
          qtyController?.text = (currentQty - 1).toString();
          bloc.products[existingIndex]["quantity"] = currentQty - 1;
          updateTotal(existingIndex);
        } else {
          // qty == 1 → remove row
          bloc.removeProduct(existingIndex);
          controllers.remove(existingIndex);
        }

        setState(() {});
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: existingIndex != -1 ? Colors.green : Colors.grey.shade200,
            width: existingIndex != -1 ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            AspectRatio(
              aspectRatio: 3,
              child: p.image != null
                  ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.network(
                  p.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  color: Color(0xfff5f5f5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 36,
                    color: Colors.black26,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '৳ ${_toDouble(p.sellingPrice).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${p.brandInfo?.name ?? ''} • ${p.categoryInfo?.name ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.stockQty == 0 ? Colors.grey : Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Stock ${p.stockQty ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primaryColor,
                      ),
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
      bloc.dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(
        pickedDate,
      );
      setState(() {});
    }
  }

  // Validate form before submission
  void _validateAndSubmitForm() {
    // First validate the form
    if (!formKey.currentState!.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please fix the errors in the form',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Validate business logic
    final bloc = context.read<CreatePosSaleBloc>();
    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;
    final netTotal = calculateAllFinalTotal();
    final paidAmount = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;

    // Validate at least one product is added
    bool hasProducts = false;
    for (var product in products) {
      if (product["product_id"] != null) {
        hasProducts = true;
        break;
      }
    }

    if (!hasProducts) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please add at least one product',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Validate walk-in customer rules
    if (isWalkInCustomer) {
      // Check 1: Must pay exact amount
      if (paidAmount != netTotal) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description:
          "Walk-in customer must pay EXACT amount: ${netTotal.toStringAsFixed(2)}",
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }

      // Check 2: _isChecked must be false for walk-in customer
      if (_isChecked) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: "Walk-in customer cannot have money receipt",
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }
    }
    // Validate saved customer rules
    else {
      // Check 1: _isChecked must be true for saved customer
      if (!_isChecked) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: 'Saved customer must have money receipt',
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }

      // Check 2: Validate money receipt section when checked
      if (_isChecked) {
        if (bloc.selectedPaymentMethod.isEmpty) {
          showCustomToast(
            context: context,
            title: 'Validation Error',
            description: 'Please select a payment method',
            icon: Icons.error,
            primaryColor: Colors.red,
          );
          return;
        }

        if (bloc.accountModel == null) {
          showCustomToast(
            context: context,
            title: 'Validation Error',
            description: 'Please select an account',
            icon: Icons.error,
            primaryColor: Colors.red,
          );
          return;
        }
      }
    }

    // Validate payable amount (common for both)
    if (bloc.payableAmount.text.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please enter payable amount',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Validate paid amount is not negative
    if (paidAmount < 0) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Paid amount cannot be negative',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    _submitForm();
  }

  // Submit form
  void _submitForm() {
    final bloc = context.read<CreatePosSaleBloc>();

    var transferProducts = products.map((product) {
      return {
        "product_id": _toInt(product["product_id"]),
        "quantity": _toInt(product["quantity"]),
        "unit_price": _toDouble(product["price"]),
        "discount": _toDouble(product["discount"]),
        "discount_type": product["discount_type"]?.toString() ?? 'fixed',
      };
    }).where((p) => p["product_id"] != 0).toList();

    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;
    final netTotal = calculateAllFinalTotal();
    final paidAmount = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;

    Map<String, dynamic> body = {
      "type": "normal_sale",
      "sale_date": appWidgets.convertDateTime(
        DateFormat("dd-MM-yyyy")
            .parse(bloc.dateEditingController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "sale_by": bloc.selectSalesModel?.id.toString() ?? '',
      "overall_vat_type": selectedOverallVatType.toLowerCase(),
      "vat": bloc.vatOverAllController.text.isEmpty
          ? 0
          : double.tryParse(bloc.vatOverAllController.text),
      "overall_service_type": selectedOverallServiceChargeType.toLowerCase(),
      "service_charge": bloc.serviceChargeOverAllController.text.isEmpty
          ? 0
          : double.tryParse(bloc.serviceChargeOverAllController.text),
      "overall_delivery_type": selectedOverallDeliveryType.toLowerCase(),
      "delivery_charge": bloc.deliveryChargeOverAllController.text.isEmpty
          ? 0
          : double.tryParse(bloc.deliveryChargeOverAllController.text),
      "overall_discount_type": selectedOverallDiscountType.toLowerCase(),
      "overall_discount": bloc.discountOverAllController.text.isEmpty
          ? 0.0
          : double.tryParse(bloc.discountOverAllController.text),
      "remark": bloc.remarkController.text,
      "items": transferProducts,
      "customer_type": isWalkInCustomer ? "walk_in" : "saved_customer",
      "with_money_receipt": _isChecked ? "Yes" : "No",
      "paid_amount": paidAmount,
      "due_amount": isWalkInCustomer
          ? 0.0
          : (netTotal - paidAmount).clamp(0, double.infinity),
    };

    if (isWalkInCustomer) {
      body.remove('customer_id');
      // For walk-in customers, force these values
      body['with_money_receipt'] = "No";
      body['due_amount'] = 0.0;
    } else {
      body['customer_id'] = selectedCustomer?.id.toString() ?? '';
      // For saved customers, ensure money receipt is included
      body['with_money_receipt'] = "Yes";
    }

    if (_isChecked && !isWalkInCustomer) {
      body['payment_method'] = bloc.selectedPaymentMethod;
      body['account_id'] = bloc.accountModel?.id.toString() ?? '';
    }

    bloc.add(AddPosSale(body: body));
    log(body.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Use mobile-first layout inside Scaffold
    final availableHeight =
        MediaQuery.of(context).size.height - kToolbarHeight - 24;

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKey,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          title: Text('Pos Sale', style: AppTextStyle.titleMedium(context)),
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
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: "Sale created successfully!",
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );
                changeAmountController.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MobilePosSaleScreen(),
                  ),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }
            },
            builder: (context, state) {
              final bloc = context.read<CreatePosSaleBloc>();

              return SingleChildScrollView(
                padding: AppTextStyle.getResponsivePaddingBody(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopFormSection(bloc),
                        _buildProductListSection(bloc),
                        _buildChargesSection(bloc),
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

// Helper functions for PDF generation
Future<Uint8List> generateSalesPreviewPdf(
    PosSaleModel sale,
    CompanyInfo? company,
    ) async {
  final pdf = pw.Document();

  // Helper function for safe double conversion
  double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  // Helper for summary rows
  pw.Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for info rows
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style:  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for status color
  PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PdfColors.green;
      case 'pending':
        return PdfColors.orange;
      case 'cancelled':
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
      ),
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Company Info
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    company?.name ?? "Company Name",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  if (company?.address != null)
                    pw.Text(
                      company?.address??"",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  if (company?.phone != null)
                    pw.Text(
                      company?.phone??"",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  if (company?.email != null)
                    pw.Text(
                      company?.email??"",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                ],
              ),
            ),
            // Logo placeholder
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  "LOGO",
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      build: (context) => [
        // Header Section
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue800, width: 2),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: const pw.EdgeInsets.all(8),
          margin: const pw.EdgeInsets.all(12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SALES INVOICE',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  _buildInfoRow('Invoice No:', sale.invoiceNo ?? 'N/A'),
                  _buildInfoRow('Date:', sale.formattedSaleDate),
                  _buildInfoRow('Time:', sale.formattedTime),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(sale.paymentStatus),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  sale.paymentStatus.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Customer Info Section
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 12),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CUSTOMER INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Customer:', sale.customerName ?? 'Walk-in Customer'),
                    _buildInfoRow('Sales Person:', sale.saleByName ?? 'N/A'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAYMENT INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Payment Method:', sale.paymentMethod ?? 'Cash'),
                    if (sale.accountName != null && sale.accountName!.isNotEmpty)
                      _buildInfoRow('Account:', sale.accountName!),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),

        // Items Table Section
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12),
          child: pw.Text(
            'ITEMS DETAILS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(4),
                    topRight: pw.Radius.circular(4),
                  ),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'PRODUCT',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'QTY',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'PRICE',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Data rows
              ...(sale.items ?? []).map((item) {
                final unitPrice = toDouble(item.unitPrice);
                final subtotal = toDouble(item.subtotal);

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300),
                    ),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        item.productName ?? 'Unknown Product',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        (item.quantity ?? 0).toString(),
                        style: const pw.TextStyle(fontSize: 11),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '৳${unitPrice.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 11),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '৳${subtotal.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 11),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        pw.SizedBox(height: 25),

        // Summary Section
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.green200),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Thank you for your business!',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800,
                              fontSize: 14,
                            ),
                          ),
                          if (sale.remark != null && sale.remark!.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Remarks: ${sale.remark}',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue200),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      _buildSummaryRow('Subtotal:', '৳${sale.netTotal?.toStringAsFixed(2) ?? "0.00"}'),
                      if (sale.overallDiscount != null && sale.overallDiscount! > 0)
                        _buildSummaryRow('Discount:', '-৳${sale.overallDiscount?.toStringAsFixed(2) ?? "0.00"}'),
                      if (sale.overallVatAmount != null && sale.overallVatAmount! > 0)
                        _buildSummaryRow('Vat:', '৳${sale.overallVatAmount?.toStringAsFixed(2) ?? "0.00"}'),
                      pw.SizedBox(height: 4),
                      pw.Divider(
                        color: PdfColors.blue400,
                        height: 1,
                        thickness: 1,
                      ),
                      pw.SizedBox(height: 4),
                      _buildSummaryRow('GRAND TOTAL:', '৳${sale.grandTotal?.toStringAsFixed(2) ?? "0.00"}', isTotal: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return pdf.save();
}