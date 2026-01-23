import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../products/sale_mode/data/product_sale_mode_model.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../mobile_pos_sale_screen.dart';
import '/core/core.dart';
import '/feature/products/product/data/model/product_stock_model.dart';
import '/feature/users_list/presentation/bloc/users/user_bloc.dart';

import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../products/categories/data/model/categories_model.dart';
import '../../../../products/categories/presentation/bloc/categories/categories_bloc.dart';
import '../../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../../../../products/sale_mode/presentation/bloc/product_sale_mode/product_sale_mode_bloc.dart';
import '../../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';

class MobileShortCreatePosSale extends StatefulWidget {
  const MobileShortCreatePosSale({super.key});

  @override
  _CreatePosSalePageState createState() => _CreatePosSalePageState();
}

class _CreatePosSalePageState extends State<MobileShortCreatePosSale> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController changeAmountController = TextEditingController();
  late CategoriesBloc categoriesBloc;

  // Charge type variables
  String selectedOverallVatType = 'fixed';
  String selectedOverallDiscountType = 'fixed';
  String selectedOverallServiceChargeType = 'fixed';
  String selectedOverallDeliveryType = 'fixed';
  bool _isChecked = false;

  // Sale Mode related
  Map<int, ProductSaleModeModel?> _selectedSaleModes = {};
  Map<int, List<ProductSaleModeModel>> _availableSaleModes = {};
  Map<int, bool> _isLoadingSaleModes = {};

  // Scroll controller for better UX
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize blocs
    context.read<AccountBloc>().add(FetchAccountActiveList(context));
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    context.read<UserBloc>().add(FetchUserList(context));
    context.read<ProductsBloc>().add(FetchProductsStockList(context));

    categoriesBloc = context.read<CategoriesBloc>();
    categoriesBloc.add(FetchCategoriesList(context));

    final bloc = context.read<CreatePosSaleBloc>();
    bloc.dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );
    bloc.withdrawDateController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );

    selectedOverallVatType = bloc.selectedOverallVatType;
    selectedOverallDiscountType = bloc.selectedOverallDiscountType;
    selectedOverallServiceChargeType = bloc.selectedOverallServiceChargeType;
    selectedOverallDeliveryType = bloc.selectedOverallDeliveryType;
    _isChecked = bloc.isChecked;

    Future.microtask(() => setDefaultSalesUser());
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
    setState(() {});
  }

  @override
  void dispose() {
    changeAmountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Get products and controllers
  List<Map<String, dynamic>> get products =>
      context.read<CreatePosSaleBloc>().products;

  Map<int, Map<String, TextEditingController>> get controllers =>
      context.read<CreatePosSaleBloc>().controllers;

  void addProduct() {
    context.read<CreatePosSaleBloc>().addProduct();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    setState(() {});
  }

  void removeProduct(int index) {
    context.read<CreatePosSaleBloc>().removeProduct(index);
    _selectedSaleModes.remove(index);
    _availableSaleModes.remove(index);
    _isLoadingSaleModes.remove(index);
    setState(() {});
  }

  // ==================== SALE MODE FUNCTIONS ====================

  Future<void> _loadSaleModesForProduct(int index, int productId) async {
    // Don't reload if already loading or loaded
    if (_isLoadingSaleModes[index] == true ||
        _availableSaleModes[index] != null) {
      return;
    }

    log('🔄 Loading sale modes for product ID: $productId at index: $index');
    setState(() => _isLoadingSaleModes[index] = true);

    try {
      final productSaleModeBloc = context.read<ProductSaleModeBloc>();

      // Clear any existing data first
      productSaleModeBloc.productSaleModeModel.clear();

      // Fetch product-specific sale mode configurations
      productSaleModeBloc.add(
        FetchProductSaleModeList(
          context,
          productId: productId.toString(),
          pageNumber: 1,
          filterText: '',
        ),
      );

      // Wait a bit for the state to update
      await Future.delayed(Duration(milliseconds: 800));

      // Get only ACTIVE configurations from the current state
      final activeConfigs = productSaleModeBloc.productSaleModeModel
          .where((config) => config.isActive == true)
          .toList();

      log(
        '✅ Product $productId: Found ${activeConfigs.length} active sale mode configs',
      );
      log('✅ Configs: ${activeConfigs.map((c) => c.saleModeName).toList()}');

      setState(() {
        _availableSaleModes[index] = activeConfigs;
        _isLoadingSaleModes[index] = false;

        // If there's only one sale mode, auto-select it
        if (activeConfigs.length == 1) {
          _selectedSaleModes[index] = activeConfigs.first;
          _calculatePriceWithSaleMode(index);
        }
      });
    } catch (e) {
      log('❌ Error loading sale modes for product $productId: $e');
      setState(() {
        _availableSaleModes[index] = [];
        _isLoadingSaleModes[index] = false;
      });
    }
  }

  void _onSaleModeChanged(int index, ProductSaleModeModel? saleMode) {
    if (saleMode == null) {
      // If sale mode is cleared, reset to regular pricing
      setState(() => _selectedSaleModes.remove(index));

      // Get the current product
      final product = products[index]["product"] as ProductModelStockModel?;
      if (product != null) {
        // Reset to regular selling price
        final sellingPrice = product.sellingPrice ?? 0.0;
        controllers[index]?["price"]?.text = sellingPrice.toStringAsFixed(2);
        updateTotal(index);
      }
      return;
    }

    setState(() => _selectedSaleModes[index] = saleMode);
    _calculatePriceWithSaleMode(index);

    showCustomToast(
      context: context,
      title: 'Sale Mode Selected!',
      description: "${saleMode.saleModeName}",
      icon: Icons.check_circle,
      primaryColor: Colors.green,
    );
  }

  void _calculatePriceWithSaleMode(int index) {
    final saleMode = _selectedSaleModes[index];
    if (saleMode == null) {
      updateTotal(index);
      return;
    }

    final quantityText = controllers[index]?["quantity"]?.text ?? "0";
    final quantity = double.tryParse(quantityText) ?? 0;

    double finalPrice = 0;
    double discountAmount = 0;

    // Calculate based on price type
    switch (saleMode.priceType?.toLowerCase()) {
      case 'unit':
        if (saleMode.unitPrice != null) {
          finalPrice = quantity * saleMode.unitPrice!;
        }
        break;
      case 'flat':
        if (saleMode.flatPrice != null) {
          finalPrice = quantity * saleMode.flatPrice!;
        }
        break;
      case 'tier':
        finalPrice = _calculateTierPrice(quantity, saleMode);
        break;
      default:
        finalPrice = quantity * (saleMode.unitPrice ?? 0);
    }

    // Apply discount
    if (saleMode.discountValue != null && saleMode.discountValue! > 0) {
      if (saleMode.discountType?.toLowerCase() == 'percentage' ||
          saleMode.discountType?.toLowerCase() == 'percent') {
        discountAmount = finalPrice * (saleMode.discountValue! / 100);
      } else {
        discountAmount = saleMode.discountValue!;
      }
      finalPrice -= discountAmount;
    }

    // Update UI
    final displayPrice = saleMode.flatPrice ?? saleMode.unitPrice ?? 0;
    controllers[index]?["price"]?.text = displayPrice.toStringAsFixed(2);
    controllers[index]?["total"]?.text = finalPrice.toStringAsFixed(2);

    // Store data
    products[index]["sale_mode_id"] = saleMode.saleModeId;
    products[index]["sale_mode_name"] = saleMode.saleModeName;
    products[index]["sale_mode_type"] = saleMode.priceType;
    products[index]["discount_amount"] = discountAmount;
    products[index]["discount_type"] = saleMode.discountType;
    products[index]["discount_value"] = saleMode.discountValue;
    products[index]["final_price"] = displayPrice;
    products[index]["total"] = finalPrice;

    setState(() {});
  }

  double _calculateTierPrice(double quantity, ProductSaleModeModel saleMode) {
    if (saleMode.tiers == null || saleMode.tiers!.isEmpty) {
      return quantity * (saleMode.unitPrice ?? 0);
    }

    // Find matching tier
    for (var tier in saleMode.tiers!) {
      if (tier.minQuantity != null &&
          quantity >= tier.minQuantity! &&
          (tier.maxQuantity == null || quantity <= tier.maxQuantity!)) {
        return quantity * (tier.price ?? (saleMode.unitPrice ?? 0));
      }
    }

    // Use last tier
    return quantity * (saleMode.tiers!.last.price ?? (saleMode.unitPrice ?? 0));
  }

  // ==================== CALCULATION METHODS ====================

  double calculateTotalForAllProducts() {
    double total = 0;
    for (var product in products) {
      final totalValue = product["total"] ?? 0;
      if (totalValue is int)
        total += totalValue.toDouble();
      else if (totalValue is String)
        total += double.tryParse(totalValue) ?? 0;
      else if (totalValue is double)
        total += totalValue;
    }
    return total;
  }

  double calculateSpecificDiscountTotal() {
    double discount = 0;
    for (var product in products) {
      final discountAmount = product["discount_amount"] ?? 0;
      if (discountAmount is int)
        discount += discountAmount.toDouble();
      else if (discountAmount is String)
        discount += double.tryParse(discountAmount) ?? 0;
      else if (discountAmount is double)
        discount += discountAmount;
    }
    return discount;
  }

  double calculateTotalTicketForAllProducts() {
    double total = 0;
    for (var product in products) {
      final price = product["final_price"] ?? 0;
      final quantity =
          double.tryParse(product["quantity"]?.toString() ?? "0") ?? 0;
      if (price is int)
        total += price.toDouble() * quantity;
      else if (price is String)
        total += (double.tryParse(price) ?? 0) * quantity;
      else if (price is double)
        total += price * quantity;
    }
    return total;
  }

  double calculateDiscountTotal() {
    final bloc = context.read<CreatePosSaleBloc>();
    final discountText = bloc.discountOverAllController.text;
    if (discountText.isEmpty) return 0.0;

    final discountValue = double.tryParse(discountText) ?? 0.0;
    final subtotal = calculateTotalForAllProducts();

    if (selectedOverallDiscountType == 'percent') {
      return subtotal * (discountValue / 100);
    }
    return discountValue;
  }

  double calculateDeliveryTotal() {
    final bloc = context.read<CreatePosSaleBloc>();
    final deliveryText = bloc.deliveryChargeOverAllController.text;
    if (deliveryText.isEmpty) return 0.0;

    final deliveryValue = double.tryParse(deliveryText) ?? 0.0;
    final subtotal = calculateTotalForAllProducts();

    if (selectedOverallDeliveryType == 'percent') {
      return subtotal * (deliveryValue / 100);
    }
    return deliveryValue;
  }

  double calculateAllFinalTotal() {
    double subtotal = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    // Apply overall discount
    double overallDiscount = calculateDiscountTotal();

    // Apply delivery charge
    double deliveryCharge = calculateDeliveryTotal();

    return (subtotal - overallDiscount) + deliveryCharge;
  }

  void updateTotal(int index) {
    if (_selectedSaleModes[index] != null) {
      _calculatePriceWithSaleMode(index);
      return;
    }

    // Regular calculation without sale mode
    final price =
        double.tryParse(controllers[index]?["price"]?.text ?? "0") ?? 0;
    final quantity =
        int.tryParse(controllers[index]?["quantity"]?.text ?? "0") ?? 0;
    final total = price * quantity;

    controllers[index]?["total"]?.text = total.toStringAsFixed(2);
    products[index]["total"] = total;
    products[index]["discount_amount"] = 0;
    products[index]["discount_type"] = null;
    products[index]["discount_value"] = null;

    setState(() {});
  }

  void onProductChanged(int index, ProductModelStockModel? newVal) {
    if (newVal == null) return;

    // Prevent duplicate
    final alreadyAdded = products.any((p) => p["product_id"] == newVal.id);
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

    // Stock check
    final stockQty = newVal.stockQty ?? 0;
    final openingStock = newVal.openingStock ?? 0;
    final availableStock = stockQty > 0 ? stockQty : openingStock;

    if (availableStock <= 0) {
      showCustomToast(
        context: context,
        title: 'Alert!',
        description: "Product stock not available",
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    setState(() {
      // Clear previous sale mode if any
      _selectedSaleModes.remove(index);
      _availableSaleModes.remove(index);
      _isLoadingSaleModes.remove(index);

      products[index]["product"] = newVal;
      products[index]["product_id"] = newVal.id;
      products[index]["product_name"] = newVal.name;
      products[index]["sale_mode_id"] = null;
      products[index]["sale_mode_name"] = null;
      products[index]["sale_mode_type"] = null;

      // Set price
      final sellingPrice = newVal.sellingPrice ?? 0.0;
      controllers[index]!["price"]!.text = sellingPrice.toStringAsFixed(2);
      products[index]["final_price"] = sellingPrice;

      // Set quantity
      int initialQuantity = 1;
      controllers[index]!["quantity"]!.text = initialQuantity.toString();
      products[index]["quantity"] = initialQuantity.toString();

      // Calculate initial total
      updateTotal(index);

      // Load sale modes in background
      _loadSaleModesForProduct(index, newVal.id!);
    });
  }

  void _updateChangeAmount() {
    final bloc = context.read<CreatePosSaleBloc>();
    final paidAmount = double.tryParse(bloc.payableAmount.text) ?? 0;
    final netTotal = calculateAllFinalTotal();
    final change = paidAmount - netTotal;

    changeAmountController.text = change > 0
        ? change.toStringAsFixed(2)
        : "0.00";
    setState(() {});
  }

  void _validateAndSubmit() {
    if (!_formKey.currentState!.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: "Please fill all required fields",
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    if (products.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: "Please add at least one product",
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Validate all products have been selected
    for (var product in products) {
      if (product["product_id"] == null) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: "Please select product for all items",
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }
    }

    _submitForm();
  }

  void _submitForm() {
    final bloc = context.read<CreatePosSaleBloc>();

    var transferProducts = products.map((product) {
      final saleModeId = product["sale_mode_id"];

      return {
        "product_id": int.tryParse(product["product_id"].toString()),
        "quantity": int.tryParse(product["quantity"].toString()),
        "unit_price": double.tryParse(
          product["final_price"]?.toString() ?? "0",
        ),
        "discount": product["discount_amount"] ?? 0,
        "discount_type": product["discount_type"] ?? "fixed",
        "sale_mode_id": saleModeId != null
            ? int.tryParse(saleModeId.toString())
            : null,
      };
    }).toList();

    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;
    final netTotal = calculateAllFinalTotal();
    final paidAmount = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;
    final user = context.read<ProfileBloc>().permissionModel?.data?.user;

    Map<String, dynamic> body = {
      "type": "normal_sale",
      "sale_date": appWidgets.convertDateTime(
        DateFormat(
          "dd-MM-yyyy",
        ).parse(bloc.dateEditingController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "sale_by": user?.id?.toString() ?? '',
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
    } else {
      body['customer_id'] = selectedCustomer?.id.toString() ?? '';
    }

    if (_isChecked) {
      body['payment_method'] = bloc.selectedPaymentMethod;
      body['account_id'] = bloc.accountModel?.id.toString() ?? '';
    }

    bloc.add(AddPosSale(body: body));
    log('📤 Sale submission body: ${json.encode(body)}');
  }

  Color _getPriceTypeColor(String? priceType) {
    switch (priceType?.toLowerCase()) {
      case 'unit':
        return Colors.blue;
      case 'flat':
        return Colors.green;
      case 'tier':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // ==================== UI BUILDERS ====================

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBg(context),
        title: Text(
          'Create Sale',
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(color: AppColors.text(context)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Reset form
              context.read<CreatePosSaleBloc>().products.clear();
              context.read<CreatePosSaleBloc>().addProduct();
              _selectedSaleModes.clear();
              _availableSaleModes.clear();
              _isLoadingSaleModes.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.bottomNavBg(context),
          child: BlocConsumer<CreatePosSaleBloc, CreatePosSaleState>(
            listener: (context, state) {
              if (state is CreatePosSaleLoading) {
                appLoader(context, "Creating Sale...");
              } else if (state is CreatePosSaleSuccess) {
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: "Sale created successfully!",
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );
                changeAmountController.clear();
                AppRoutes.pushReplacement(context, MobilePosSaleScreen());
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
              final selectedCustomer = bloc.selectClintModel;
              final isWalkInCustomer = selectedCustomer?.id == -1;

              return SingleChildScrollView(
                controller: _scrollController,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Information Section
                        _buildCustomerInfoSection(bloc),
                        const SizedBox(height: 8),

                        // Products Section
                        _buildProductsSection(bloc),
                        const SizedBox(height: 8),

                        // Charges Section
                        _buildChargesSection(bloc),
                        const SizedBox(height: 8),

                        // Summary & Payment Section
                        _buildSummarySection(bloc, isWalkInCustomer),
                        const SizedBox(height: 8),

                        // Submit Button
                        AppButton(
                          onPressed: _validateAndSubmit,
                          name: 'Create Sale',
                          icon: Icon(Icons.check_circle),
                        ),
                        const SizedBox(height: 20),
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

  Widget _buildCustomerInfoSection(CreatePosSaleBloc bloc) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primaryColor(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Customer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown<CustomerActiveModel>(
                label: "Customer *",
                hint: bloc.selectClintModel?.name ?? "Select Customer",
                isSearch: true,
                isRequired: true,
                value: bloc.selectClintModel,
                itemList: [
                  CustomerActiveModel(name: 'Walk-in-customer', id: -1),
                  ...context.read<CustomerBloc>().activeCustomer,
                ],
                onChanged: (newVal) {
                  bloc.selectClintModel = newVal;
                  bloc.customType = (newVal?.id == -1)
                      ? "Walking Customer"
                      : "Saved Customer";
                  if (newVal?.id == -1) {
                    _isChecked = true;
                    bloc.isChecked = true;
                    Future.delayed(const Duration(milliseconds: 100), () {
                      final netTotal = calculateAllFinalTotal();
                      bloc.payableAmount.text = netTotal.toStringAsFixed(2);
                      _updateChangeAmount();
                    });
                  }
                  setState(() {});
                },
                validator: (value) =>
                    value == null ? 'Please select Customer' : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(CreatePosSaleBloc bloc) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final productData = entry.value;
            final product = productData["product"] as ProductModelStockModel?;
            final selectedSaleMode = _selectedSaleModes[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),

              decoration: BoxDecoration(color: AppColors.bottomNavBg(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with remove button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Item ${index + 1}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          index == 0
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          color: index == 0
                              ? AppColors.primaryColor(context)
                              : AppColors.errorColor(context),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: index == 0
                            ? addProduct
                            : () => removeProduct(index),
                      ),
                    ],
                  ),

                  // Category Dropdown
                  BlocBuilder<CategoriesBloc, CategoriesState>(
                    builder: (context, state) {
                      final categoryList = categoriesBloc.list;
                      final selectedCategory = categoriesBloc.selectedState;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: AppDropdown(
                          label: "Category",
                          hint: selectedCategory.isEmpty
                              ? "Select Category"
                              : selectedCategory,
                          isLabel: false,
                          isSearch: true,
                          value: selectedCategory.isEmpty
                              ? null
                              : selectedCategory,
                          itemList: categoryList
                              .map((e) => e.name ?? "")
                              .toList(),
                          onChanged: (newVal) {
                            setState(() {
                              categoriesBloc.selectedState = newVal.toString();
                              final matchingCategory = categoryList.firstWhere(
                                (category) =>
                                    category.name.toString() ==
                                    newVal.toString(),
                                orElse: () => CategoryModel(),
                              );
                              categoriesBloc.selectedStateId =
                                  matchingCategory.id?.toString() ?? "";
                              productData["product"] = null;
                              productData["product_id"] = null;
                              controllers[index]!["price"]!.text = "0";
                              controllers[index]!["quantity"]!.text = "1";
                              updateTotal(index);
                            });
                          },
                        ),
                      );
                    },
                  ),

                  // Product Dropdown
                  BlocBuilder<ProductsBloc, ProductsState>(
                    builder: (context, state) {
                      final selectedCategoryId = categoriesBloc.selectedStateId;
                      final selectedProductIds = products
                          .where((p) => p["product_id"] != null)
                          .map<int>((p) => p["product_id"])
                          .toList();

                      final filteredProducts = context
                          .read<ProductsBloc>()
                          .productList
                          .where((item) {
                            final categoryMatch = selectedCategoryId.isEmpty
                                ? true
                                : item.category?.toString() ==
                                      selectedCategoryId;
                            final notDuplicate =
                                !selectedProductIds.contains(item.id) ||
                                item.id == productData["product_id"];
                            return categoryMatch && notDuplicate;
                          })
                          .toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: AppDropdown<ProductModelStockModel>(
                          isRequired: true,
                          isLabel: false,
                          isSearch: true,
                          label: "Product *",
                          hint: selectedCategoryId.isEmpty
                              ? "Select Category First"
                              : "Select Product",
                          value: product,
                          itemList: filteredProducts,
                          onChanged: (newVal) =>
                              onProductChanged(index, newVal),
                          validator: (value) =>
                              value == null ? 'Please select Product' : null,
                        ),
                      );
                    },
                  ),

                  // 🔥 SALE MODE DROPDOWN
                  if (product != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: _buildSaleModeDropdown(index),
                    ),

                  // Price and Quantity Row
                  Row(
                    children: [
                      // ================= PRICE =================
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),

                              TextField(
                                controller: controllers[index]!["price"],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor(context),
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  prefixText: "৳",
                                ),
                                onChanged: (val) {
                                  final price = double.tryParse(val) ?? 0.0;
                                  productData["price"] = price;

                                  // Recalculate total if needed
                                  updateTotal(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),


                      const SizedBox(width: 8),

                      // ================= QUANTITY =================
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quantity *",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),

                              Row(
                                children: [
                                  // ---------- MINUS ----------
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor(
                                        context,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.remove,
                                        size: 14,
                                        color: AppColors.primaryColor(context),
                                      ),
                                      onPressed: () {
                                        int q =
                                            int.tryParse(
                                              controllers[index]!["quantity"]!
                                                  .text,
                                            ) ??
                                            1;

                                        if (q > 1) {
                                          q--;
                                          controllers[index]!["quantity"]!
                                              .text = q
                                              .toString();
                                          productData["quantity"] = q
                                              .toString();

                                          if (_selectedSaleModes[index] !=
                                              null) {
                                            _calculatePriceWithSaleMode(index);
                                          } else {
                                            updateTotal(index);
                                          }
                                        }
                                      },
                                    ),
                                  ),

                                  // ---------- INPUT ----------
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          controllers[index]!["quantity"],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text(context),
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (val) {
                                        int q = int.tryParse(val) ?? 1;
                                        if (q < 1) q = 1;

                                        final stockQty = product?.stockQty ?? 0;
                                        if (stockQty > 0 && q > stockQty) {
                                          q = stockQty;
                                          controllers[index]!["quantity"]!
                                              .text = q
                                              .toString();
                                        }

                                        productData["quantity"] = q.toString();

                                        if (_selectedSaleModes[index] != null) {
                                          _calculatePriceWithSaleMode(index);
                                        } else {
                                          updateTotal(index);
                                        }
                                      },
                                    ),
                                  ),

                                  // ---------- PLUS ----------
                                  Container(
                                    width: 60,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor(
                                        context,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.add,
                                        size: 14,
                                        color: AppColors.primaryColor(context),
                                      ),
                                      onPressed: () {
                                        int q =
                                            int.tryParse(
                                              controllers[index]!["quantity"]!
                                                  .text,
                                            ) ??
                                            1;

                                        final stockQty = product?.stockQty ?? 0;
                                        if (stockQty == 0 || q < stockQty) {
                                          q++;
                                          controllers[index]!["quantity"]!
                                              .text = q
                                              .toString();
                                          productData["quantity"] = q
                                              .toString();

                                          if (_selectedSaleModes[index] !=
                                              null) {
                                            _calculatePriceWithSaleMode(index);
                                          } else {
                                            updateTotal(index);
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Price Summary (smaller)
                  if (product != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: _buildPriceSummary(
                        index,
                        productData,
                        selectedSaleMode,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSaleModeDropdown(int index) {
    final isLoading = _isLoadingSaleModes[index] ?? false;
    final availableModes = _availableSaleModes[index] ?? [];
    final selectedMode = _selectedSaleModes[index];

    if (isLoading) {
      return Container(
        height: 50,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor(context),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Loading sale modes...",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (availableModes.isEmpty) {
      return Container(
        height: 50,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "No sale modes configured",
                style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Sale Mode",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ProductSaleModeModel>(
                isExpanded: true,
                value: selectedMode,
                hint: Text(
                  'Select Sale Mode',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                items: [
                  DropdownMenuItem<ProductSaleModeModel>(
                    value: null,
                    child: Text(
                      'None (Regular Price)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  ...availableModes.map((mode) {
                    return DropdownMenuItem<ProductSaleModeModel>(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(
                            Icons.sell,
                            size: 16,
                            color: AppColors.primaryColor(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mode.saleModeName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriceTypeColor(mode.priceType),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              mode.priceType?.toUpperCase() ?? 'UNIT',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (newVal) => _onSaleModeChanged(index, newVal),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(
    int index,
    Map<String, dynamic> productData,
    ProductSaleModeModel? saleMode,
  ) {
    final total = double.tryParse(productData["total"]?.toString() ?? "0") ?? 0;
    final discountAmount = productData["discount_amount"] ?? 0;
    final saleModeName = productData["sale_mode_name"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Item Total",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            if (saleModeName != null)
              Text(
                saleModeName,
                style: TextStyle(fontSize: 11, color: Colors.green.shade700),
              ),
            if (discountAmount > 0)
              Text(
                "Discount: -৳${discountAmount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 11, color: Colors.red),
              ),
          ],
        ),
        Text(
          "৳${total.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

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
                  selectedColor: AppColors.primaryColor(context),
                  borderColor: AppColors.primaryColor(context),
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
                    fillColor: AppColors.bottomNavBg(context),
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
        Row(
          children: [
            Expanded(
              child: chargeField(
                "Discount",
                selectedOverallDiscountType,
                context.read<CreatePosSaleBloc>().discountOverAllController,
                (value) {
                  setState(() {
                    selectedOverallDiscountType = value;
                    context
                            .read<CreatePosSaleBloc>()
                            .selectedOverallDiscountType =
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
                            .selectedOverallServiceChargeType =
                        value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummarySection(CreatePosSaleBloc bloc, bool isWalkInCustomer) {
    final productTotal = calculateTotalTicketForAllProducts();
    final subTotal = calculateTotalForAllProducts();
    final specificDiscount = calculateSpecificDiscountTotal();
    final overallDiscount = calculateDiscountTotal();
    final deliveryCharge = calculateDeliveryTotal();
    final netTotal = calculateAllFinalTotal();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize,
                color: AppColors.primaryColor(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Summary & Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer type info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isWalkInCustomer
                  ? Colors.orange.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isWalkInCustomer ? Colors.orange : Colors.green,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isWalkInCustomer ? Icons.person : Icons.person_pin,
                  color: isWalkInCustomer
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isWalkInCustomer
                        ? "Walk-in Customer: Must pay exact amount"
                        : "Saved Customer: Due or advance payment allowed",
                    style: TextStyle(
                      fontSize: 13,
                      color: isWalkInCustomer
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                _buildSummaryRow("Product Total:", productTotal),
                if (specificDiscount > 0)
                  _buildSummaryRow("Specific Discount (-):", specificDiscount),
                _buildSummaryRow("Sub Total:", subTotal),
                if (overallDiscount > 0)
                  _buildSummaryRow("Overall Discount (-):", overallDiscount),
                if (deliveryCharge > 0)
                  _buildSummaryRow("Delivery Charge (+):", deliveryCharge),
                const Divider(height: 16),
                _buildSummaryRow("NET TOTAL:", netTotal, isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Section
          _buildPaymentSection(bloc, isWalkInCustomer, netTotal),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(
    CreatePosSaleBloc bloc,
    bool isWalkInCustomer,
    double netTotal,
  ) {
    void recalculateAndAutoFill() {
      final bloc = context.read<CreatePosSaleBloc>();
      final selectedCustomer = bloc.selectClintModel;

      if (selectedCustomer?.id == -1) {
        // Only auto-fill for walk-in customer
        final netTotal = calculateAllFinalTotal();
        bloc.payableAmount.text = netTotal.toStringAsFixed(2);
        _updateChangeAmount();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Details",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "With Money Receipt",
            style: TextStyle(fontSize: 14, color: AppColors.text(context)),
          ),
          value: _isChecked,
          onChanged: (bool? newValue) {
            setState(() {
              _isChecked = newValue ?? false;
              bloc.isChecked = _isChecked;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),

        if (_isChecked) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppDropdown<String>(
                  label: "Payment Method *",
                  hint: bloc.selectedPaymentMethod.isEmpty
                      ? "Select Payment Method"
                      : bloc.selectedPaymentMethod,
                  isLabel: false,
                  isRequired: true,
                  isNeedAll: false,
                  value: bloc.selectedPaymentMethod.isEmpty
                      ? null
                      : bloc.selectedPaymentMethod,
                  itemList: bloc.paymentMethod,
                  onChanged: (newVal) {
                    bloc.selectedPaymentMethod = newVal.toString();
                    setState(() {});
                  },
                  validator: (value) =>
                      value == null ? 'Please select a payment method' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                    if (state is AccountActiveListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AccountActiveListSuccess) {
                      final filteredList = bloc.selectedPaymentMethod.isNotEmpty
                          ? state.list.where((item) {
                              return item.acType?.toLowerCase() ==
                                  bloc.selectedPaymentMethod.toLowerCase();
                            }).toList()
                          : state.list;

                      final selectedAccount =
                          bloc.accountModel ??
                          (filteredList.isNotEmpty ? filteredList.first : null);
                      bloc.accountModel = selectedAccount;

                      return AppDropdown<AccountActiveModel>(
                        label: "Account *",
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
                      );
                    } else {
                      return Container();
                    }
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
                  controller: changeAmountController,
                  hintText: isWalkInCustomer
                      ? 'Change (0.00)'
                      : 'Change Amount',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInputField(
                      controller: bloc.payableAmount,
                      hintText: 'Payable Amount *',
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

                        // Walk-in customer validation
                        if (isWalkInCustomer && numericValue != netTotal) {
                          return 'Must pay exact: ${netTotal.toStringAsFixed(2)}';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        _updateChangeAmount();
                        recalculateAndAutoFill();
                        setState(() {});
                      },
                    ),
                    if (isWalkInCustomer)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          "Walk-in: Pay exact amount only",
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 8),
        CustomInputField(
          isRequiredLable: true,
          controller: bloc.remarkController,
          hintText: 'Remark *',
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            "৳${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              color: isBold
                  ? AppColors.primaryColor(context)
                  : Colors.grey.shade800,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
