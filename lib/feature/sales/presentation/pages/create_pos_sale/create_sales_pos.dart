// NOTE: adjust imports paths to match your project structure
import 'dart:developer';

import 'package:flutter/cupertino.dart';
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

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
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
    double _ = productList.fold(0.0, (p, e) => p + _toDouble(e["ticket_total"]));
    double _ = productList.fold(0.0, (p, e) {
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
    return ResponsiveRow(
      spacing: 2,
      runSpacing: 2,
      children: [
        ResponsiveCol(
          xs: 12,
          sm: 3,
          md: 3,
          lg: 3,
          xl: 3,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown(
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
                  if(  newVal?.id == -1){
                    _isChecked=true;
                  }
                  setState(() {});
                },
                validator: (value) =>
                value == null ? 'Please select Customer' : null,

              );
            },
          ),
        ),
        ResponsiveCol(
          xs: 12,
          sm: 3,
          md: 3,
          lg: 3,
          xl: 3,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return AppDropdown(
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

              );
            },
          ),
        ),
        ResponsiveCol(
          xs: 12,
          sm: 2,
          md: 2,
          lg: 2,
          xl: 2,
          child: CustomInputField(
            isRequired: true,
            readOnly: true,
            controller: bloc.dateEditingController,
            hintText: 'Sale Date',
            keyboardType: TextInputType.datetime,
            autofillHints: AutofillHints.name,
            fillColor: AppColors.whiteColor(context),
            validator: (value) => value!.isEmpty ? 'Please enter date' : null,
            onTap: _selectDate,
          ),
        ),
        ResponsiveCol(
          xs: 12,
          sm: 3,
          md: 3,
          lg: 3,
          xl: 3,
          child: const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildProductListSection(CreatePosSaleBloc bloc) {
    return Column(
      children: [
        // Header row
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: ResponsiveRow(
            spacing: 6,
            runSpacing: 6,
            children: [
              ResponsiveCol(
                xs: 12,
                sm: 2,
                md: 2,
                lg: 3,
                xl: 3,
                child: Text(
                  'Product Name',
                  style: AppTextStyle.cardLevelHead(context),
                ),
              ),
              ResponsiveCol(
                xs: 12,
                sm: 2.3,
                md: 2.3,
                lg: 2.3,
                xl: 2.3,
                child: Text(
                  'Quantity',
                  style: AppTextStyle.cardLevelHead(context),
                ),
              ),
              ResponsiveCol(
                xs: 12,
                sm: 1.3,
                md: 1.3,
                lg: 1.5,
                xl: 1.5,
                child: Text(
                  'Price',
                  style: AppTextStyle.cardLevelHead(context),
                ),
              ),
              ResponsiveCol(
                xs: 12,
                sm: 2,
                md: 2,
                lg: 1.5,
                xl: 1.5,
                child: Text(
                  'Discount',
                  style: AppTextStyle.cardLevelHead(context),
                ),
              ),
              ResponsiveCol(
                xs: 12,
                sm: 1.5,
                md: 1.5,
                lg: 1.5,
                xl: 1.5,
                child: Text(
                  'Sub Total',
                  style: AppTextStyle.cardLevelHead(context),
                ),
              ),
              ResponsiveCol(
                xs: 12,
                sm: 1.5,
                md: 1.5,
                lg: 1.5,
                xl: 1.5,
                child: Text(
                  'Net Price',
                  style: AppTextStyle.cardLevelHead(context),
                ),
              ),
              ResponsiveCol(
                xs: 12,
                sm: 0.6,
                md: 0.6,
                lg: 0.8,
                xl: 0.8,
                child: Text(
                  'Delete',
                  style: AppTextStyle.cardLevelHead(context),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Product rows
        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final discountApplied = product["discountApplied"] == true;

          return Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ResponsiveRow(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Product Name
                ResponsiveCol(
                  xs: 12,
                  sm: 2,
                  md: 2,
                  lg: 3,
                  xl: 3,
                  child: BlocBuilder<ProductsBloc, ProductsState>(
                    builder: (context, state) {
                      final allProducts = context.read<ProductsBloc>().productList;

                      ProductModelStockModel? selectedItem;
                      if (product["product_id"] != null) {
                        selectedItem = allProducts.firstWhere(
                              (p) => p.id == _toInt(product["product_id"]),
                          orElse: () {
                            return allProducts.isNotEmpty
                                ? allProducts.first
                                : ProductModelStockModel(
                              id: 0,
                              name: 'Unknown',
                              stockQty: 0,
                            );
                          },
                        );
                      }

                      final title =
                          selectedItem?.name ?? product["product"]?.toString() ?? '';
                      return Text(
                        title,
                        style: AppTextStyle.cardLevelText(context),
                      );
                    },
                  ),
                ),

                // Quantity
                ResponsiveCol(
                  xs: 12,
                  sm: 2.3,
                  md: 2.3,
                  lg: 2.3,
                  xl: 2.3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 32,
                        width: 30,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: AppColors.text(context)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            int currentQuantity = int.tryParse(
                              controllers[index]?["quantity"]?.text ?? "0",
                            ) ??
                                0;
                            if (currentQuantity > 1) {
                              controllers[index]!["quantity"]!.text =
                                  (currentQuantity - 1).toString();
                              products[index]["quantity"] = _toInt(
                                controllers[index]!["quantity"]!.text,
                              );
                              updateTotal(index);
                            }
                          },
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 32,
                        width: 55,
                        child: TextFormField(
                          controller: controllers[index]?["quantity"],
                          style: AppTextStyle.cardLevelText(context),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          readOnly: discountApplied,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            hintText: "0",
                          ),
                          onChanged: discountApplied
                              ? null
                              : (value) {
                            // allow decimal input but convert to int for storage
                            final parsed = double.tryParse(value) ?? 0.0;
                            products[index]["quantity"] = parsed.toInt();
                            controllers[index]!["quantity"]!.text = parsed.toInt().toString();
                            updateTotal(index);
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 32,
                        width: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primaryColor(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            int currentQuantity = int.tryParse(
                              controllers[index]?["quantity"]?.text ?? "0",
                            ) ??
                                0;
                            controllers[index]!["quantity"]!.text =
                                (currentQuantity + 1).toString();
                            products[index]["quantity"] = _toInt(
                              controllers[index]!["quantity"]!.text,
                            );
                            updateTotal(index);
                          },
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                ResponsiveCol(
                  xs: 12,
                  sm: 1.3,
                  md: 1.3,
                  lg: 1.5,
                  xl: 1.5,
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.text(context)),
                    ),
                    child: Text(
                      controllers[index]?["price"]?.text ?? '0',
                      style: AppTextStyle.cardLevelText(context),
                    ),
                  ),
                ),

                // Discount + Segment control
                ResponsiveCol(
                  xs: 12,
                  sm: 2,
                  md: 2,
                  lg: 1.5,
                  xl: 1.5,
                  child: Row(
                    children: [
                      Flexible(
                        child: CupertinoSegmentedControl<String>(
                          padding: EdgeInsets.zero,
                          children: {
                            'fixed': Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 2,
                              ),
                              child: Text(
                                'Tk',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product["discount_type"] == 'fixed'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            'percent': Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 2,
                              ),
                              child: Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product["discount_type"] == 'percent'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          },
                          onValueChanged: discountApplied
                              ? (_) {}
                              : (value) {
                            setState(() {
                              product["discount_type"] = value;
                              updateTotal(index);
                            });
                          },
                          groupValue: product["discount_type"],
                          unselectedColor: Colors.grey[200],
                          selectedColor: AppColors.primaryColor(context),
                          borderColor: AppColors.primaryColor(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 32,
                        width: 50,
                        child: TextFormField(
                          controller: controllers[index]?["discount"],
                          style: AppTextStyle.cardLevelText(context),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          readOnly: discountApplied,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            hintText: "0",
                          ),
                          onChanged: discountApplied
                              ? null
                              : (value) {
                            product["discount"] = double.tryParse(value) ?? 0.0;
                            updateTotal(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtotal
                ResponsiveCol(
                  xs: 12,
                  sm: 1.5,
                  md: 1.5,
                  lg: 1.5,
                  xl: 1.5,
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.text(context)),
                    ),
                    child: Text(
                      controllers[index]?["ticket_total"]?.text ?? '0',
                      style: AppTextStyle.cardLevelText(context),
                    ),
                  ),
                ),

                // Net Price
                ResponsiveCol(
                  xs: 12,
                  sm: 1.5,
                  md: 1.5,
                  lg: 1.5,
                  xl: 1.5,
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.text(context)),
                    ),
                    child: Text(
                      controllers[index]?["total"]?.text ?? '0',
                      style: AppTextStyle.cardLevelText(context),
                    ),
                  ),
                ),

                // Delete button
                ResponsiveCol(
                  xs: 12,
                  sm: 0.6,
                  md: 0.6,
                  lg: 0.8,
                  xl: 0.8,
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        if (product == products.last) {
                          context.read<CreatePosSaleBloc>().addProduct();
                        } else {
                          context.read<CreatePosSaleBloc>().removeProduct(
                            index,
                          );
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: product == products.last
                              ? Colors.green.withValues(alpha: 0.08)
                              : Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: product == products.last
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Icon(
                          product == products.last ? Icons.add : Icons.delete,
                          color: product == products.last
                              ? Colors.green
                              : Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

  // Charges section (kept)
  Widget _buildChargesSection(CreatePosSaleBloc bloc) {
    Widget chargeField(
        String label,
        String selectedType,
        TextEditingController controller,
        Function(String) onTypeChanged,
        ) {
      return ResponsiveCol(
        xs: 12,
        sm: 2.5,
        md: 2.5,
        lg: 1.5,
        xl: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyle.cardLevelText(context)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Segmented control (fixed width)
                SizedBox(
                  width: 50,
                  height: 38,
                  child: CupertinoSegmentedControl<String>(
                    padding: EdgeInsets.zero,
                    children: {
                      'fixed': Center(
                        child: Text(
                          'TK',
                          style: TextStyle(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            color:
                            selectedType == 'fixed' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      'percent': Center(
                        child: Text(
                          '%',
                          style: TextStyle(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            color:
                            selectedType == 'percent' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    },
                    groupValue: selectedType,
                    onValueChanged: onTypeChanged,
                    unselectedColor: Colors.grey[300],
                    selectedColor: AppColors.primaryColor(context),
                    borderColor: AppColors.primaryColor(context),
                  ),
                ),

                const SizedBox(width: 6),

                // ✅ FIX: Expanded gives bounded width
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: CustomInputFieldPayRoll(
                      isRequiredLevle: false,
                      controller: controller,
                      hintText: label,
                      fillColor: Colors.white,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      autofillHints: '',
                      levelText: '',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ResponsiveRow(
      spacing: 6,
      runSpacing: 6,
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
        chargeField("Vat", selectedOverallVatType, context.read<CreatePosSaleBloc>().vatOverAllController, (
            value,
            ) {
          setState(() {
            selectedOverallVatType = value;
            context.read<CreatePosSaleBloc>().selectedOverallVatType = value;
          });
        }),
        chargeField(
          "Service Charge",
          selectedOverallServiceChargeType,
          context.read<CreatePosSaleBloc>().serviceChargeOverAllController,
              (value) {
            setState(() {
              selectedOverallServiceChargeType = value;
              context.read<CreatePosSaleBloc>().selectedOverallServiceChargeType = value;
            });
          },
        ),
        chargeField(
          "Delivery Charge",
          selectedOverallDeliveryType,
          context.read<CreatePosSaleBloc>().deliveryChargeOverAllController,
              (value) {
            setState(() {
              selectedOverallDeliveryType = value;
              context.read<CreatePosSaleBloc>().selectedOverallDeliveryType = value;
            });
          },
        ),
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

    return ResponsiveRow(
      spacing: 6,
      runSpacing: 6,
      children: [
        ResponsiveCol(
          xs: 12,
          sm: 5,
          md: 5,
          lg: 5,
          xl: 5,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: [
                _buildSummaryRow("Product Total", productTotal),
                _buildSummaryRow("Specific Discount (-)", specificDiscount),
                _buildSummaryRow("Sub Total", subTotal),
                _buildSummaryRow("Discount (-)", overallDiscount),
                _buildSummaryRow("Vat (+)", vat),
                _buildSummaryRow("Service Charge (+)", serviceCharge),
                _buildSummaryRow("Delivery Charge (+)", deliveryCharge),
                _buildSummaryRow("Net Total", netTotal),
              ],
            ),
          ),
        ),
        ResponsiveCol(
          xs: 12,
          sm: 5,
          md: 5,
          lg: 5,
          xl: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: Text(
                  "With Money Receipt",
                  style: AppTextStyle.headerTitle(context),
                ),
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
                const SizedBox(height: 0),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown(
                        label: "Payment Method",
                        hint: context.read<CreatePosSaleBloc>().selectedPaymentMethod.isEmpty
                            ? "Select Payment Method"
                            : context.read<CreatePosSaleBloc>().selectedPaymentMethod,
                        isLabel: false,
                        isRequired: true,
                        isNeedAll: false,
                        value: context.read<CreatePosSaleBloc>().selectedPaymentMethod.isEmpty
                            ? null
                            : context.read<CreatePosSaleBloc>().selectedPaymentMethod,
                        itemList: [] + context.read<CreatePosSaleBloc>().paymentMethod,
                        onChanged: (newVal) {
                          context.read<CreatePosSaleBloc>().selectedPaymentMethod = newVal.toString();
                          setState(() {});
                        },
                        validator: (value) => value == null ? 'Please select a payment method' : null,

                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: BlocBuilder<AccountBloc, AccountState>(
                        builder: (context, state) {
                          if (state is AccountActiveListLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is AccountActiveListSuccess) {
                            final bloc = context.read<CreatePosSaleBloc>();
                            final filteredList = bloc.selectedPaymentMethod.isNotEmpty
                                ? state.list
                                .where((item) => item.acType?.toLowerCase() == bloc.selectedPaymentMethod.toLowerCase())
                                .toList()
                                : state.list;
                            final selectedAccount = bloc.accountModel ?? (filteredList.isNotEmpty ? filteredList.first : null);
                            bloc.accountModel = selectedAccount;
                            return AppDropdown<AccountActiveModel>(
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
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0),
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
                    const SizedBox(width: 5),
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
              const SizedBox(height: 0),
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
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(label, style: AppTextStyle.cardLevelHead(context))),
          Expanded(flex: 2, child: Text(value.toStringAsFixed(2), style: AppTextStyle.cardLevelText(context))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        const SizedBox(width: 10),
        AppButton(
          name: 'Preview',
          onPressed: () {},
          color: const Color(0xff800000),
        ),
        const SizedBox(width: 10),
        AppButton(name: 'Submit', onPressed: _submitForm),
        const SizedBox(width: 5),
      ],
    );
  }

  // Product browser -------------------------------------------------------
  Widget _buildProductBrowser() {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        List<ProductModelStockModel> productList = [];

        // 🔹 Use the correct product list based on state
        if (state is ProductsListStockSuccess) {
          productList = state.list;
        } else if (state is ProductsListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductsListFailed) {
          return Center(child: Text(state.content));
        }

        // 🔹 Get search query
        final query = productSearchController.text.trim().toLowerCase();

        // 🔹 Filter logic
        final filteredProducts = productList.where((p) {
          final searchableText = [p.name, p.sku].whereType<String>().join(' ').toLowerCase();
          final matchesSearch = query.isEmpty || searchableText.contains(query);
          final matchesCategory = selectedCategoryFilter.isEmpty || p.categoryInfo?.name == selectedCategoryFilter;
          final matchesBrand = selectedBrandFilter.isEmpty || p.brand == selectedBrandFilter;
          return matchesSearch && matchesCategory && matchesBrand;
        }).toList();

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              // ---------------- Filters ----------------
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<CategoriesBloc, CategoriesState>(
                      builder: (context, state) {
                        final categoryList = categoriesBloc.list;
                        return AppDropdown(
                          label: "Category",
                          hint: "Select Category",
                          isLabel: false,
                          isNeedAll: true,
                          isSearch: true,
                          value: selectedCategoryFilter.isEmpty ? null : selectedCategoryFilter,
                          itemList: categoryList.map((e) => e.name ?? '').toList(),
                          onChanged: (v) => setState(() {
                            selectedCategoryFilter = v?.toString() ?? '';
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: BlocBuilder<BrandBloc, BrandState>(
                      builder: (context, state) {
                        final brandList = brandBloc.brandModel;
                        return AppDropdown(
                          label: "Brand",
                          hint: "Select Brand",
                          isLabel: false,
                          isNeedAll: true,
                          isSearch: true,
                          value: selectedBrandFilter.isEmpty ? null : selectedBrandFilter,
                          itemList: brandList.map((e) => e.name ?? '').toList(),
                          onChanged: (v) => setState(() {
                            selectedBrandFilter = v?.toString() ?? '';
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ---------------- Search + small status ----------------
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
                ],
              ),

              const SizedBox(height: 12),

              // ---------------- Grid ----------------
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.5,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) => _buildProductCard(filteredProducts[index]),
                ),
              ),
            ],
          ),
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
      },
      child:Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: p.image != null
                        ? Image.network(
                      p.image!,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 30,
                        color: Colors.black26,
                      ),
                    ),
                  ),

                  /// STOCK
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.stockQty == 0
                            ? Colors.grey
                            : Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Stock ${p.stockQty ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// DETAILS
              Padding(
                padding: const EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PRICE (FOCUS)
                    Text(
                      '৳ ${_toDouble(p.sellingPrice).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// NAME
                    Text(
                      p.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 2),

                    /// BRAND / CATEGORY
                    Text(
                      '${p.brandInfo?.name ?? ''} • ${p.categoryInfo?.name ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )


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
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    // Constrain the main content height so internal Expanded widgets can layout properly.
    final availableHeight = MediaQuery.of(context).size.height - kToolbarHeight - 24;

    // Wrap the whole content in a RawKeyboardListener so barcode scanners (keyboard emulators) can send input.
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKey,
      child: Container(
        color: AppColors.bottomNavBg(context),
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
                    decoration: const BoxDecoration(color: Colors.white),
                    child: const Sidebar(),
                  ),
                ),
              ResponsiveCol(
                xs: 12,
                sm: 12,
                md: 12,
                lg: 10,
                xl: 10,
                child: SizedBox(
                  height: availableHeight,
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

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT: Sales form (~65%)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildTopFormSection(bloc),
                                      _buildProductListSection(bloc),
                                      _buildChargesSection(bloc),
                                      const SizedBox(height: 4),
                                      _buildSummaryAndPayment(bloc),
                                      gapH8,
                                      _buildActionButtons(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 280, child: _buildProductBrowser()),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}