import 'package:meherinMart/desktop/widgets/sidebar.dart';
// NOTE: adjust imports paths to match your project structure
import '../../shared/create_pos_sale/sale_payment_rules.dart';
import 'dart:developer';
import 'dart:ui' show FontFeature;

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
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
   final jwtToken =  LocalDB.getLoginInfo();

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
    final changeAmount = SalePaymentRules.change(payableAmount, calculateAllFinalTotal()); // FIX: আগে উল্টো (ঋণাত্মক) দেখাত

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
  //
  // Layout নীতি (desktop):
  //   • প্রতিটা অংশ (Customer, Items, Adjustments, Summary) আলাদা card এ —
  //     চোখ বুঝতে পারে কোথায় কী
  //   • Items টেবিলের header আর row একই column মাপ ব্যবহার করে
  //     (_lineRow), তাই "Quantity" লেখা ঠিক quantity box এর উপরে থাকে
  //   • সংখ্যা সবসময় ডানে align — দশমিক এক লাইনে মেলে
  //   • ভুল মান (stock এর বেশি qty, 100% এর বেশি discount) সাথে সাথে লাল
  //     border + নিচে কারণ লেখা — Submit চাপার আগেই user জানে

  static const double _wIdx = 28;
  static const double _wQty = 128;
  static const double _wDisc = 150;
  static const double _wAct = 40;
  static const double _fieldH = 34;

  Color get _borderColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.10)
      : AppColors.borderLight;

  /// সব অংশের জন্য একই card
  Widget _section({String? title, Widget? trailing, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(text, style: AppTextStyle.labelDropdownTextStyle(context)),
          if (required)
            const Text(' *', style: TextStyle(color: AppColors.danger)),
        ],
      ),
    );
  }

  InputDecoration _boxDecoration({String? hint, bool error = false}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 13, color: AppColors.text(context).withValues(alpha: 0.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      filled: true,
      fillColor: AppColors.bottomNavBg(context),
      enabledBorder: b(error ? AppColors.danger : AppColors.border),
      focusedBorder:
          b(error ? AppColors.danger : AppColors.primaryColor(context), 1.4),
      errorBorder: b(AppColors.danger),
      focusedErrorBorder: b(AppColors.danger, 1.4),
      border: b(AppColors.border),
      errorStyle: const TextStyle(fontSize: 11, height: 1.1),
    );
  }

  /// শুধু দেখানোর জন্য (read-only) মান — ডানে align
  Widget _valueBox(String text, {bool strong = false}) {
    return Container(
      height: _fieldH,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.text(context),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  /// TK / % ছোট toggle — Cupertino segmented control এর বদলে, যেটা
  /// desktop এ বড় আর অন্য field এর সাথে উচ্চতা মিলত না
  Widget _typeToggle(String value, ValueChanged<String>? onChanged) {
    Widget seg(String key, String label) {
      final bool selected = value == key;
      final Color primary = AppColors.primaryColor(context);
      return Expanded(
        child: InkWell(
          onTap: onChanged == null ? null : () => onChanged(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            alignment: Alignment.center,
            color: selected ? primary : Colors.transparent,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.onColor(primary)
                    : AppColors.text(context).withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: _fieldH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Row(children: [seg('fixed', 'TK'), seg('percent', '%')]),
      ),
    );
  }

  // ---------------- Customer / Seller / Date ----------------

  Widget _buildTopFormSection(CreatePosSaleBloc bloc) {
    final user = context.read<ProfileBloc>().permissionModel?.data?.user;
    final isAdmin = user?.role == "SUPER_ADMIN" || user?.role == "ADMIN";

    return _section(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                return AppDropdown(
                  label: "Customer",
                  hint: bloc.selectClintModel?.name ?? "Select Customer",
                  isSearch: true,
                  isLabel: true,
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
                    // Walk-in customer এর বাকি রাখা যায় না — তাই টাকা
                    // গ্রহণ (money receipt) স্বয়ংক্রিয়ভাবে চালু
                    if (newVal?.id == -1) {
                      _isChecked = true;
                      bloc.isChecked = true;
                    }
                    setState(() {});
                  },
                  validator: (value) =>
                      value == null ? 'Please select a customer' : null,
                );
              },
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return AppDropdown(
                    label: "Sales By",
                    hint: bloc.selectSalesModel?.username ?? "Select Seller",
                    isSearch: true,
                    isLabel: true,
                    isNeedAll: false,
                    isRequired: true,
                    value: bloc.selectSalesModel,
                    itemList: context.read<UserBloc>().list,
                    onChanged: (newVal) {
                      bloc.selectSalesModel = newVal;
                      setState(() {});
                    },
                    validator: (value) =>
                        value == null ? 'Please select a seller' : null,
                  );
                },
              ),
            ),
          ],
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Sale Date', required: true),
                TextFormField(
                  controller: bloc.dateEditingController,
                  readOnly: true,
                  onTap: _selectDate,
                  style: TextStyle(fontSize: 14, color: AppColors.text(context)),
                  decoration: _boxDecoration(hint: 'dd-mm-yyyy').copyWith(
                    suffixIcon: const Icon(Icons.calendar_today_outlined,
                        size: 16),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 34, minHeight: 20),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please select a date'
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Line items ----------------

  /// header আর প্রতিটা row এই একই column মাপে বসে
  Widget _lineRow(List<Widget> c, {CrossAxisAlignment cross = CrossAxisAlignment.center}) {
    const gap = SizedBox(width: 8);
    return Row(
      crossAxisAlignment: cross,
      children: [
        SizedBox(width: _wIdx, child: c[0]),
        gap,
        Expanded(flex: 4, child: c[1]),
        gap,
        SizedBox(width: _wQty, child: c[2]),
        gap,
        Expanded(flex: 2, child: c[3]),
        gap,
        SizedBox(width: _wDisc, child: c[4]),
        gap,
        Expanded(flex: 2, child: c[5]),
        gap,
        Expanded(flex: 2, child: c[6]),
        gap,
        SizedBox(width: _wAct, child: c[7]),
      ],
    );
  }

  Widget _headCell(String text, {TextAlign align = TextAlign.left}) => Text(
        text,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AppColors.text(context).withValues(alpha: 0.6),
        ),
      );

  /// row এর product এর stock (না জানা থাকলে অসীম — তখন সীমা নেই)
  double _stockOf(int index) {
    final p = products[index]["product"];
    if (p is ProductModelStockModel && p.stockQty != null) {
      return p.stockQty!.toDouble();
    }
    return double.infinity;
  }

  /// row এর সমস্যা — null মানে ঠিক আছে
  String? _rowIssue(int index) {
    final row = products[index];
    if (row["product_id"] == null) return null;

    final qty = _toDouble(row["quantity"]);
    final stock = _stockOf(index);
    if (qty <= 0) return 'Quantity must be at least 1';
    if (qty > stock) return 'Only ${stock.toStringAsFixed(0)} in stock';

    final ticket = _toDouble(row["ticket_total"]);
    final disc = double.tryParse(controllers[index]?["discount"]?.text ?? '') ?? 0;
    if (disc < 0) return 'Discount cannot be negative';
    if (row["discount_type"] == 'percent' && disc > 100) {
      return 'Discount cannot exceed 100%';
    }
    if (row["discount_type"] != 'percent' && disc > ticket && ticket > 0) {
      return 'Discount is more than the item total';
    }
    if (_toDouble(row["price"]) <= 0) return 'Price is zero for this product';
    return null;
  }

  void _setQuantity(int index, int qty) {
    final stock = _stockOf(index);
    if (qty > stock) {
      showCustomToast(
        context: context,
        title: 'Stock limit',
        description: 'Only ${stock.toStringAsFixed(0)} available in stock',
        icon: Icons.inventory_2_outlined,
        primaryColor: AppColors.warning,
      );
      qty = stock.toInt();
    }
    if (qty < 1) qty = 1;
    controllers[index]!["quantity"]!.text = qty.toString();
    products[index]["quantity"] = qty;
    updateTotal(index);
  }

  Widget _buildProductListSection(CreatePosSaleBloc bloc) {
    final filled = <int>[
      for (int i = 0; i < products.length; i++)
        if (products[i]["product_id"] != null) i,
    ];

    return _section(
      title: 'Items',
      trailing: filled.isEmpty
          ? null
          : Text(
              '${filled.length} item${filled.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.text(context).withValues(alpha: 0.6),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _lineRow([
              _headCell('#'),
              _headCell('Product'),
              _headCell('Quantity', align: TextAlign.center),
              _headCell('Unit Price', align: TextAlign.right),
              _headCell('Discount', align: TextAlign.center),
              _headCell('Sub Total', align: TextAlign.right),
              _headCell('Net Price', align: TextAlign.right),
              const SizedBox.shrink(),
            ]),
          ),
          if (filled.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      size: 32, color: AppColors.greyColor(context)),
                  const SizedBox(height: 8),
                  Text(
                    'No items yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click a product on the right, or scan a barcode',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text(context).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            for (int n = 0; n < filled.length; n++)
              _buildLineItem(filled[n], n + 1),
        ],
      ),
    );
  }

  Widget _buildLineItem(int index, int serial) {
    final product = products[index];
    final bool locked = product["discountApplied"] == true;
    final String? issue = _rowIssue(index);
    final double stock = _stockOf(index);
    final double qty = _toDouble(product["quantity"]);
    final bool qtyError = qty <= 0 || qty > stock;
    final double ticket = _toDouble(product["ticket_total"]);
    final double discVal =
        double.tryParse(controllers[index]?["discount"]?.text ?? '') ?? 0;
    final bool discError = discVal < 0 ||
        (product["discount_type"] == 'percent'
            ? discVal > 100
            : (ticket > 0 && discVal > ticket));

    final p = product["product"];
    final String name = (p is ProductModelStockModel ? p.name : null) ??
        product["product"]?.toString() ??
        '';
    final String? sku = p is ProductModelStockModel ? p.sku : null;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: issue != null
              ? AppColors.danger.withValues(alpha: 0.5)
              : _borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lineRow([
            // #
            Text(
              '$serial',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.text(context).withValues(alpha: 0.5),
              ),
            ),

            // Product
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (stock.isFinite) 'Stock: ${stock.toStringAsFixed(0)}',
                    if (sku != null && sku.isNotEmpty) sku,
                    if (locked) 'Fixed discount',
                  ].join('  ·  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.text(context).withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),

            // Quantity  [-] [ 1 ] [+]
            Row(
              children: [
                _qtyButton(
                  Icons.remove_rounded,
                  enabled: !locked && qty > 1,
                  onTap: () => _setQuantity(index, qty.toInt() - 1),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: _fieldH,
                    child: TextFormField(
                      controller: controllers[index]?["quantity"],
                      readOnly: locked,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                          fontSize: 13, color: AppColors.text(context)),
                      decoration:
                          _boxDecoration(hint: '0', error: qtyError).copyWith(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 9),
                      ),
                      // আগে প্রতি keystroke এ text আবার লিখে দেওয়া হতো —
                      // cursor শেষে লাফাত আর field খালি করা যেত না
                      onChanged: locked
                          ? null
                          : (value) {
                              products[index]["quantity"] =
                                  int.tryParse(value) ?? 0;
                              updateTotal(index);
                            },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _qtyButton(
                  Icons.add_rounded,
                  primary: true,
                  enabled: !locked && qty < stock,
                  onTap: () => _setQuantity(index, qty.toInt() + 1),
                ),
              ],
            ),

            // Unit price
            _valueBox(_toDouble(product["price"]).toStringAsFixed(2)),

            // Discount  [TK|%] [ 0 ]
            Row(
              children: [
                _typeToggle(
                  product["discount_type"]?.toString() ?? 'fixed',
                  locked
                      ? null
                      : (value) {
                          setState(() {
                            product["discount_type"] = value;
                            updateTotal(index);
                          });
                        },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: _fieldH,
                    child: TextFormField(
                      controller: controllers[index]?["discount"],
                      readOnly: locked,
                      textAlign: TextAlign.right,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: TextStyle(
                          fontSize: 13, color: AppColors.text(context)),
                      decoration: _boxDecoration(hint: '0', error: discError)
                          .copyWith(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 9),
                      ),
                      onChanged: locked
                          ? null
                          : (value) {
                              product["discount"] = double.tryParse(value) ?? 0.0;
                              updateTotal(index);
                            },
                    ),
                  ),
                ),
              ],
            ),

            // Sub total / Net
            _valueBox(controllers[index]?["ticket_total"]?.text ?? '0.00'),
            _valueBox(controllers[index]?["total"]?.text ?? '0.00',
                strong: true),

            // Remove
            Center(
              child: Tooltip(
                message: 'Remove item',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  hoverColor: AppColors.danger.withValues(alpha: 0.08),
                  onTap: () {
                    final b = context.read<CreatePosSaleBloc>();
                    b.removeProduct(index);
                    // সবসময় অন্তত একটা খালি row থাকে — product card
                    // ক্লিক করলে সেটাতেই product বসে
                    if (b.products.isEmpty) b.addProduct();
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.delete_outline_rounded,
                        size: 19, color: AppColors.danger),
                  ),
                ),
              ),
            ),
          ]),
          if (issue != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: _wIdx + 8),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 14, color: AppColors.danger),
                  const SizedBox(width: 4),
                  Text(
                    issue,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.danger),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _qtyButton(
    IconData icon, {
    required VoidCallback onTap,
    bool primary = false,
    bool enabled = true,
  }) {
    final Color c = AppColors.primaryColor(context);
    return SizedBox(
      width: 28,
      height: _fieldH,
      child: Material(
        color: primary
            ? (enabled ? c : c.withValues(alpha: 0.35))
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: primary ? BorderSide.none : BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Icon(
            icon,
            size: 16,
            color: primary
                ? AppColors.onColor(c)
                : AppColors.text(context)
                    .withValues(alpha: enabled ? 0.8 : 0.3),
          ),
        ),
      ),
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
        primaryColor: AppColors.warning,
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

  // ---------------- Totals (এক জায়গায় হিসাব) ----------------
  // আগে summary, submit আর walk-in check — তিন জায়গায় আলাদা করে একই
  // হিসাব লেখা ছিল। এখন একটাই function, তাই কোথাও গরমিল হবে না।

  ({
    double productTotal,
    double specificDiscount,
    double subTotal,
    double overallDiscount,
    double vat,
    double service,
    double delivery,
    double net,
  }) _computeTotals() {
    final bloc = context.read<CreatePosSaleBloc>();
    final rows = products.where((e) => e["product_id"] != null);

    final double productTotal =
        rows.fold(0.0, (p, e) => p + _toDouble(e["ticket_total"]));
    final double specificDiscount = rows.fold(0.0, (p, e) {
      final disc = _toDouble(e["discount"]);
      final ticket = _toDouble(e["ticket_total"]);
      final amount =
          (e["discount_type"] == 'percent') ? ticket * (disc / 100.0) : disc;
      return p + amount.clamp(0.0, ticket);
    });
    final double subTotal = rows.fold(0.0, (p, e) => p + _toDouble(e["total"]));

    double pick(TextEditingController c, String type) {
      final v = double.tryParse(c.text) ?? 0.0;
      return type == 'percent' ? subTotal * (v / 100.0) : v;
    }

    final double overallDiscount =
        pick(bloc.discountOverAllController, selectedOverallDiscountType);
    final double vat = pick(bloc.vatOverAllController, selectedOverallVatType);
    final double service = pick(
        bloc.serviceChargeOverAllController, selectedOverallServiceChargeType);
    final double delivery =
        pick(bloc.deliveryChargeOverAllController, selectedOverallDeliveryType);

    return (
      productTotal: productTotal,
      specificDiscount: specificDiscount,
      subTotal: subTotal,
      overallDiscount: overallDiscount,
      vat: vat,
      service: service,
      delivery: delivery,
      net: (subTotal - overallDiscount) + vat + service + delivery,
    );
  }

  // ---------------- Adjustments (Discount / Vat / Service / Delivery) ----------------

  String? _adjustmentValidator(String? v, String type, {bool isDiscount = false}) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null) return 'Enter a valid number';
    if (value < 0) return 'Cannot be negative';
    if (type == 'percent' && value > 100) return 'Max 100%';
    if (isDiscount && type != 'percent') {
      final sub = _computeTotals().subTotal;
      if (value > sub) return 'More than sub total';
    }
    return null;
  }

  Widget _adjustmentField(
    String label,
    String selectedType,
    TextEditingController controller,
    ValueChanged<String> onTypeChanged, {
    bool isDiscount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(label),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _typeToggle(selectedType, (v) {
              onTypeChanged(v);
              // type বদলালে validation আবার চালানো — 50 TK ঠিক, কিন্তু 150% নয়
              formKey.currentState?.validate();
            }),
            const SizedBox(width: 6),
            Expanded(
              child: TextFormField(
                controller: controller,
                textAlign: TextAlign.right,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: TextStyle(fontSize: 13, color: AppColors.text(context)),
                decoration: _boxDecoration(hint: '0.00'),
                validator: (v) =>
                    _adjustmentValidator(v, selectedType, isDiscount: isDiscount),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChargesSection(CreatePosSaleBloc bloc) {
    final items = <Widget>[
      _adjustmentField(
        'Discount',
        selectedOverallDiscountType,
        bloc.discountOverAllController,
        (value) => setState(() {
          selectedOverallDiscountType = value;
          bloc.selectedOverallDiscountType = value;
        }),
        isDiscount: true,
      ),
      _adjustmentField(
        'VAT',
        selectedOverallVatType,
        bloc.vatOverAllController,
        (value) => setState(() {
          selectedOverallVatType = value;
          bloc.selectedOverallVatType = value;
        }),
      ),
      _adjustmentField(
        'Service Charge',
        selectedOverallServiceChargeType,
        bloc.serviceChargeOverAllController,
        (value) => setState(() {
          selectedOverallServiceChargeType = value;
          bloc.selectedOverallServiceChargeType = value;
        }),
      ),
      _adjustmentField(
        'Delivery Charge',
        selectedOverallDeliveryType,
        bloc.deliveryChargeOverAllController,
        (value) => setState(() {
          selectedOverallDeliveryType = value;
          bloc.selectedOverallDeliveryType = value;
        }),
      ),
    ];

    return _section(
      title: 'Adjustments',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: items[i]),
          ],
        ],
      ),
    );
  }

  // ---------------- Summary + Payment ----------------

  Widget _buildSummaryAndPayment(CreatePosSaleBloc bloc) {
    final t = _computeTotals();

    final summary = _section(
      title: 'Summary',
      child: Column(
        children: [
          _buildSummaryRow('Product Total', t.productTotal),
          _buildSummaryRow('Item Discount', -t.specificDiscount, muted: true),
          _buildSummaryRow('Sub Total', t.subTotal),
          _buildSummaryRow('Discount', -t.overallDiscount, muted: true),
          _buildSummaryRow('VAT', t.vat, muted: true),
          _buildSummaryRow('Service Charge', t.service, muted: true),
          _buildSummaryRow('Delivery Charge', t.delivery, muted: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: _borderColor),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Net Total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ),
              Text(
                '৳ ${t.net.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final payment = _section(
      title: 'Payment',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Receive payment now',
            style: TextStyle(fontSize: 13, color: AppColors.text(context)),
          ),
          const SizedBox(width: 6),
          Switch(
            value: _isChecked,
            onChanged: (bool v) {
              final isWalkIn = bloc.selectClintModel?.id == -1;
              if (!v && isWalkIn) {
                showCustomToast(
                  context: context,
                  title: 'Walk-in customer',
                  description: 'Full payment is required for walk-in customers.',
                  icon: Icons.info_outline,
                  primaryColor: AppColors.warning,
                );
                return;
              }
              setState(() {
                _isChecked = v;
                bloc.isChecked = v;
              });
            },
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isChecked) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDropdown(
                    label: "Payment Method",
                    hint: bloc.selectedPaymentMethod.isEmpty
                        ? "Select Payment Method"
                        : bloc.selectedPaymentMethod,
                    isLabel: true,
                    isRequired: true,
                    isNeedAll: false,
                    value: bloc.selectedPaymentMethod.isEmpty
                        ? null
                        : bloc.selectedPaymentMethod,
                    itemList: [] + bloc.paymentMethod,
                    onChanged: (newVal) {
                      bloc.selectedPaymentMethod = newVal?.toString() ?? '';
                      // method বদলালে আগের account আর মেলে না
                      bloc.accountModel = null;
                      setState(() {});
                    },
                    validator: (value) => (_isChecked && value == null)
                        ? 'Please select a payment method'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BlocBuilder<AccountBloc, AccountState>(
                    builder: (context, state) {
                      if (state is AccountActiveListLoading) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: LinearProgressIndicator(minHeight: 2),
                        );
                      } else if (state is AccountActiveListSuccess) {
                        final filteredList = bloc.selectedPaymentMethod.isNotEmpty
                            ? state.list
                                .where((item) =>
                                    item.acType?.toLowerCase() ==
                                    bloc.selectedPaymentMethod.toLowerCase())
                                .toList()
                            : state.list;
                        final selectedAccount = bloc.accountModel ??
                            (filteredList.isNotEmpty ? filteredList.first : null);
                        bloc.accountModel = selectedAccount;
                        return AppDropdown<AccountActiveModel>(
                          label: "Account",
                          hint: bloc.accountModel == null
                              ? "Select Account"
                              : bloc.accountModel!.name.toString(),
                          isLabel: true,
                          isRequired: true,
                          isNeedAll: false,
                          value: selectedAccount,
                          itemList: filteredList,
                          onChanged: (newVal) {
                            bloc.accountModel = newVal;
                            setState(() {});
                          },
                          validator: (value) => (_isChecked && value == null)
                              ? 'Please select an account'
                              : null,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Received Amount', required: true),
                      TextFormField(
                        controller: bloc.payableAmount,
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(
                            fontSize: 14, color: AppColors.text(context)),
                        decoration: _boxDecoration(hint: '0.00').copyWith(
                          suffixIcon: Tooltip(
                            message: 'Fill net total',
                            child: InkWell(
                              onTap: () {
                                bloc.payableAmount.text =
                                    t.net.toStringAsFixed(2);
                                _updateChangeAmount();
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.done_all_rounded, size: 16),
                              ),
                            ),
                          ),
                          suffixIconConstraints:
                              const BoxConstraints(minWidth: 32, minHeight: 20),
                        ),
                        validator: (v) {
                          if (!_isChecked) return null;
                          final value = double.tryParse((v ?? '').trim());
                          if (value == null || value <= 0) {
                            return 'Enter the amount received';
                          }
                          if (bloc.selectClintModel?.id == -1 &&
                              value + 0.001 < t.net) {
                            return 'Walk-in: full payment required';
                          }
                          return null;
                        },
                        onChanged: (_) => _updateChangeAmount(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(_receivedDelta(bloc, t.net) >= 0
                          ? 'Change to return'
                          : 'Due'),
                      _valueBox(
                        _receivedDelta(bloc, t.net).abs().toStringAsFixed(2),
                        strong: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'The full amount (৳ ${t.net.toStringAsFixed(2)}) will be recorded as due.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.text(context).withValues(alpha: 0.65),
                ),
              ),
            ),
          _fieldLabel('Remark', required: true),
          TextFormField(
            controller: bloc.remarkController,
            style: TextStyle(fontSize: 14, color: AppColors.text(context)),
            maxLines: 2,
            minLines: 1,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: _boxDecoration(hint: 'Note for this sale'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter a remark'
                : null,
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: payment),
        const SizedBox(width: 12),
        Expanded(flex: 4, child: summary),
      ],
    );
  }

  /// received − net : ধনাত্মক = ফেরত দিতে হবে, ঋণাত্মক = বাকি
  double _receivedDelta(CreatePosSaleBloc bloc, double net) {
    final received = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;
    return received - net;
  }

  Widget _buildSummaryRow(String label, double value, {bool muted = false}) {
    final Color c = AppColors.text(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: muted ? c.withValues(alpha: 0.65) : c,
                fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value < 0
                ? '− ${value.abs().toStringAsFixed(2)}'
                : value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 13,
              color: muted ? c.withValues(alpha: 0.75) : c,
              fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Builder(
            builder: (btnContext) => PopoverButton(
              label: 'Preview',
              onPressed: () => _showPreview(btnContext),
            ),
          ),
          const SizedBox(width: 10),
          PopoverButton(
            label: 'Submit Sale',
            primary: true,
            icon: Icons.check_rounded,
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }

  /// Submit এর আগে পুরো sale একবার দেখে নেওয়া — popover এ, তাই screen
  /// ছাড়তে হয় না। সমস্যা থাকলে এখানেই দেখা যায়।
  void _showPreview(BuildContext anchorContext) {
    final bloc = context.read<CreatePosSaleBloc>();
    final t = _computeTotals();
    final rows = [
      for (int i = 0; i < products.length; i++)
        if (products[i]["product_id"] != null) i,
    ];

    String nameOf(int i) {
      final p = products[i]["product"];
      return (p is ProductModelStockModel ? p.name : null) ?? '-';
    }

    showAppPopover<void>(
      context: anchorContext,
      mode: PopoverAnchorMode.aligned,
      builder: (ctx) => AppPopoverCard(
        width: 520,
        icon: const Icon(Icons.receipt_long_outlined),
        title: const Text('Sale Preview'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${bloc.selectClintModel?.name ?? 'No customer selected'}'
              '  ·  ${bloc.dateEditingController.text}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.text(context).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              const Text('No items added.')
            else
              for (final i in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nameOf(i),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          '${products[i]["quantity"]} × ${_toDouble(products[i]["price"]).toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          _toDouble(products[i]["total"]).toStringAsFixed(2),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
            const Divider(height: 20),
            _buildSummaryRow('Sub Total', t.subTotal),
            if (t.overallDiscount != 0)
              _buildSummaryRow('Discount', -t.overallDiscount, muted: true),
            if (t.vat != 0) _buildSummaryRow('VAT', t.vat, muted: true),
            if (t.service != 0)
              _buildSummaryRow('Service Charge', t.service, muted: true),
            if (t.delivery != 0)
              _buildSummaryRow('Delivery Charge', t.delivery, muted: true),
            const SizedBox(height: 6),
            Row(
              children: [
                const Expanded(
                  child: Text('Net Total',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text(
                  '৳ ${t.net.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopoverButton(
            label: 'Close',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          PopoverButton(
            label: 'Submit Sale',
            primary: true,
            icon: Icons.check_rounded,
            onPressed: rows.isEmpty
                ? null
                : () {
                    Navigator.of(ctx).pop();
                    _submitForm();
                  },
          ),
        ],
      ),
    );
  }

  /// Submit এর আগে item গুলো যাচাই — প্রথম সমস্যাটা জানিয়ে false ফেরত দেয়
  bool _validateItems() {
    final rows = [
      for (int i = 0; i < products.length; i++)
        if (products[i]["product_id"] != null) i,
    ];

    if (rows.isEmpty) {
      showCustomToast(
        context: context,
        title: 'No items',
        description: 'Add at least one product before submitting.',
        icon: Icons.shopping_cart_outlined,
        primaryColor: AppColors.warning,
      );
      return false;
    }

    for (int n = 0; n < rows.length; n++) {
      final issue = _rowIssue(rows[n]);
      if (issue != null) {
        showCustomToast(
          context: context,
          title: 'Item ${n + 1}',
          description: issue,
          icon: Icons.error_outline,
          primaryColor: AppColors.danger,
        );
        setState(() {}); // row এ লাল border দেখানো
        return false;
      }
    }

    if (_computeTotals().net < 0) {
      showCustomToast(
        context: context,
        title: 'Invalid total',
        description: 'Discount is larger than the sale amount.',
        icon: Icons.error_outline,
        primaryColor: AppColors.danger,
      );
      return false;
    }
    return true;
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

        // একই product আবার ক্লিক করলে নতুন row নয় — quantity +1
        // (আগে "already added" warning দিত, cashier কে হাতে qty বাড়াতে হতো)
        final existing =
            bloc.products.indexWhere((row) => row["product_id"] == p.id);
        if (existing >= 0) {
          _setQuantity(existing, _toDouble(bloc.products[existing]["quantity"]).toInt() + 1);
          setState(() {});
          return;
        }

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
    final formOk = formKey.currentState!.validate();
    if (!formOk) {
      showCustomToast(
        context: context,
        title: 'Check the form',
        description: 'Some required fields are missing or invalid.',
        icon: Icons.error_outline,
        primaryColor: AppColors.danger,
      );
      return;
    }
    if (!_validateItems()) return;
    final bloc = context.read<CreatePosSaleBloc>();

    // খালি row (product বাছা হয়নি) server এ পাঠানো হয় না
    var transferProducts = products
        .where((product) => product["product_id"] != null)
        .map((product) {
      return {
        "product_id": _toInt(product["product_id"]),
        "quantity": _toDouble(product["quantity"]), // FIX: দশমিক পরিমাণ বাদ পড়ত
        "unit_price": _toDouble(product["price"]),
        "discount": _toDouble(product["discount"]),
        "discount_type": product["discount_type"]?.toString() ?? 'fixed',
      };
    }).toList();

    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;
    final user = context.read<ProfileBloc>().permissionModel?.data?.user;
    final isAdmin = user?.role == "SUPER_ADMIN" || user?.role == "ADMIN";
    Map<String, dynamic> body = {
      "type": "normal_sale",
      "sale_date": appWidgets.convertDateTime(
        DateFormat("dd-MM-yyyy").parse(bloc.dateEditingController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "sale_by": (isAdmin)
          ? bloc.selectSalesModel?.id?.toString() ?? ''
          : user?.id?.toString() ?? '',
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
      final netTotal = _computeTotals().net;
      final paidAmount = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;
      if (paidAmount + 0.001 < netTotal) {
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

    // FIX: টাকা গ্রহণের নিয়ম (সব screen এ এক) — দেখুন sale_payment_rules.dart
    final paymentError = SalePaymentRules.apply(
      body: body,
      receivePayment: _isChecked,
      receivedText: bloc.payableAmount.text,
      paymentMethod: bloc.selectedPaymentMethod,
      accountId: bloc.accountModel?.id,
      grandTotal: calculateAllFinalTotal(),
      isWalkIn: isWalkInCustomer,
    );
    if (paymentError != null) {
      showCustomToast(
        context: context,
        title: 'Payment',
        description: paymentError,
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
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
                          primaryColor: AppColors.success,
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
                                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildTopFormSection(bloc),
                                      _buildProductListSection(bloc),
                                      _buildChargesSection(bloc),
                                      _buildSummaryAndPayment(bloc),
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