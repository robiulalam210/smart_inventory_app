import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/widgets/app_scaffold.dart';
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

  // Sale Mode related - Per product index
  final Map<int, SaleMode?> _selectedSaleModes = {};
  final Map<int, List<SaleMode>> _availableSaleModes = {};
  final Map<int, bool> _isLoadingSaleModes = {};

  // Scroll controller for better UX
  final ScrollController _scrollController = ScrollController();

  // Track disposed controllers to prevent reuse
  final Set<int> _disposedProductIndexes = {};

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

    // Clear local state only, don't dispose controllers (bloc handles that)
    _selectedSaleModes.clear();
    _availableSaleModes.clear();
    _isLoadingSaleModes.clear();
    _disposedProductIndexes.clear();

    super.dispose();
  }

  // Get products and controllers
  List<Map<String, dynamic>> get products =>
      context.read<CreatePosSaleBloc>().products;

  Map<int, Map<String, TextEditingController>> get controllers =>
      context.read<CreatePosSaleBloc>().controllers;

  // Safe controller access methods
  TextEditingController? getController(int index, String key) {
    if (_disposedProductIndexes.contains(index)) return null;
    return controllers[index]?[key];
  }

  void setControllerText(int index, String key, String value) {
    if (_disposedProductIndexes.contains(index)) return;
    final controller = controllers[index]?[key];
    if (controller != null) {
      controller.text = value;
    }
  }

  String getControllerText(int index, String key) {
    if (_disposedProductIndexes.contains(index)) return '';
    final controller = controllers[index]?[key];
    if (controller != null) {
      return controller.text;
    }
    return '';
  }

  void addProduct() {
    context.read<CreatePosSaleBloc>().addProduct();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    setState(() {});
  }

  void removeProduct(int index) {
    // Mark as disposed first
    _disposedProductIndexes.add(index);

    // Clean up local state
    _selectedSaleModes.remove(index);
    _availableSaleModes.remove(index);
    _isLoadingSaleModes.remove(index);

    // Let the bloc handle controller disposal
    context.read<CreatePosSaleBloc>().removeProduct(index);

    setState(() {});
  }

  // ==================== SALE MODE FUNCTIONS ====================

  void _loadSaleModesForProduct(int index, ProductModelStockModel product) {
    if (_disposedProductIndexes.contains(index)) return;
    if (_availableSaleModes.containsKey(index)) return;

    log('🔄 Loading sale modes for product: ${product.name} at index: $index');
    setState(() => _isLoadingSaleModes[index] = true);

    try {
      List<SaleMode> activeConfigs = [];

      // Check if product has pre-configured sale modes in the JSON response
      if (product.saleModes != null && product.saleModes!.isNotEmpty) {
        log(
          '✅ Product ${product.name} has ${product.saleModes!.length} pre-configured sale modes',
        );

        // Get only active sale modes
        activeConfigs = product.saleModes!
            .where((mode) => mode.isActive == true)
            .toList();

        log(
          '✅ Product ${product.name}: Found ${activeConfigs.length} active sale modes',
        );

        for (var mode in activeConfigs) {
          log(
            '   - Mode: ${mode.saleModeName}, Price: ${mode.unitPrice}, Conv: ${mode.conversionFactor}, Base: ${mode.baseUnitName}, Tiers: ${mode.tiers?.length ?? 0}',
          );

          // Log tier details
          if (mode.tiers != null && mode.tiers!.isNotEmpty) {
            for (var tier in mode.tiers!) {
              log('     Tier: ${tier.minQuantity}-${tier.maxQuantity} => ${tier.price}');
            }
          }
        }
      } else {
        log('ℹ️ No pre-configured sale modes for product ${product.name}');
      }

      if (!_disposedProductIndexes.contains(index)) {
        setState(() {
          _availableSaleModes[index] = activeConfigs;
          _isLoadingSaleModes[index] = false;
        });
      }
    } catch (e) {
      log('❌ Error loading sale modes for product ${product.name}: $e');
      if (!_disposedProductIndexes.contains(index)) {
        setState(() {
          _availableSaleModes[index] = [];
          _isLoadingSaleModes[index] = false;
        });
      }
    }
  }
  void _onSaleModeChanged(int index, SaleMode? saleMode) {
    if (_disposedProductIndexes.contains(index)) return;

    setState(() {
      _selectedSaleModes[index] = saleMode;
    });

    if (saleMode == null) {
      // Reset to regular price
      final product = products[index]["product"] as ProductModelStockModel?;
      if (product != null) {
        final sellingPrice = product.sellingPrice ?? 0.0;
        setControllerText(index, "price", sellingPrice.toStringAsFixed(2));
        updateTotal(index);
      }
      return;
    }

    // Apply sale mode pricing
    _applySaleModePricing(index, saleMode);
  }

  void _applySaleModePricing(int index, SaleMode saleMode) {
    if (_disposedProductIndexes.contains(index)) return;

    final quantityStr = getControllerText(index, "quantity");
    final quantity = double.tryParse(quantityStr) ?? 1.0;

    double pricePerUnit = 0;
    double discountAmount = 0;
    SaleModeTier? applicableTier;
    bool isTierPrice = false;

    // Log sale mode details for debugging
    log('🎯 Applying Sale Mode: ${saleMode.saleModeName}');
    log('   - Unit Price: ${saleMode.unitPrice}');
    log('   - Conversion Factor: ${saleMode.conversionFactor}');
    log('   - Base Unit: ${saleMode.baseUnitName}');
    log('   - Price Type: ${saleMode.priceType}');
    log('   - Flat Price: ${saleMode.flatPrice}');
    log('   - Discount: ${saleMode.discountValue} (${saleMode.discountType})');
    log('   - Tiers: ${saleMode.tiers?.length ?? 0}');

    // Check if there are tiers and find applicable tier
    if (saleMode.tiers != null && saleMode.tiers!.isNotEmpty) {
      log('🔍 Checking tiers for quantity: $quantity');

      // Find the applicable tier for the current quantity
      for (var tier in saleMode.tiers!) {
        final minQty = double.tryParse(tier.minQuantity) ?? 0;
        final maxQty = double.tryParse(tier.maxQuantity) ?? double.infinity;

        log('   Tier: ${tier.minQuantity}-${tier.maxQuantity} => ${tier.price}');

        if (quantity >= minQty && quantity <= maxQty) {
          applicableTier = tier;
          isTierPrice = true;
          log('✅ Found applicable tier: ${tier.minQuantity}-${tier.maxQuantity} => ${tier.price}');
          break;
        }
      }

      if (applicableTier != null && isTierPrice) {
        // Use tier price if available - this is the FINAL price (no discount should be applied)
        final tierPrice = double.tryParse(applicableTier.price) ?? 0;
        if (tierPrice > 0) {
          pricePerUnit = tierPrice;
          discountAmount = 0; // Tier prices are FINAL, no additional discounts
          log('💰 Using tier price (final): $pricePerUnit');
          log('💰 Tier price - NO discount applied (tier price is final)');
        } else {
          // Tier price is 0, use regular pricing with discount
          pricePerUnit = _calculateBasePrice(saleMode);
          discountAmount = _calculateDiscount(saleMode, pricePerUnit);
        }
      } else {
        // No matching tier, use regular pricing with discount
        log('⚠️ No matching tier found, using regular pricing with discount');
        pricePerUnit = _calculateBasePrice(saleMode);
        discountAmount = _calculateDiscount(saleMode, pricePerUnit);
      }
    } else {
      // No tiers available, use regular pricing logic with discount
      log('ℹ️ No tiers available, using regular pricing with discount');
      pricePerUnit = _calculateBasePrice(saleMode);
      discountAmount = _calculateDiscount(saleMode, pricePerUnit);
    }

    // If pricePerUnit is still 0, fallback to regular selling price
    if (pricePerUnit == 0) {
      final product = products[index]["product"] as ProductModelStockModel?;
      pricePerUnit = product?.sellingPrice ?? 0.0;
      log('⚠️ Price is 0, using product selling price: $pricePerUnit');
    }

    // Calculate final price
    double finalPrice = pricePerUnit - discountAmount;

    // Ensure final price is not negative
    if (finalPrice < 0) {
      log('⚠️ Warning: Final price is negative ($finalPrice), setting to 0');
      finalPrice = 0;
      discountAmount = pricePerUnit; // Adjust discount to not exceed price
    }

    // Update UI and data using safe methods
    setControllerText(index, "price", finalPrice.toStringAsFixed(2));
    products[index]["sale_mode_id"] = saleMode.id;
    products[index]["sale_mode_name"] = saleMode.saleModeName;
    products[index]["discount_amount"] = discountAmount * quantity;
    products[index]["final_price"] = finalPrice;
    products[index]["current_tier"] = applicableTier;
    products[index]["conversion_factor"] = saleMode.conversionFactor;
    products[index]["is_tier_price"] = isTierPrice; // Store if this is a tier price

    updateTotal(index);

    // Show detailed debug info
    log('📊 FINAL CALCULATION:');
    log('   - Sale Mode: ${saleMode.saleModeName}');
    log('   - Quantity: $quantity');
    log('   - Tier Applied: ${applicableTier != null ? "${applicableTier.minQuantity}-${applicableTier.maxQuantity} => ${applicableTier.price}" : "None"}');
    log('   - Is Tier Price: $isTierPrice');
    log('   - Price Per Unit: $pricePerUnit');
    log('   - Discount: $discountAmount');
    log('   - Final Price Per Unit: $finalPrice');
    log('   - Total: ${finalPrice * quantity}');

    showCustomToast(
      context: context,
      title: 'Sale Mode Applied!',
      description: "${saleMode.saleModeName} selected" +
          (applicableTier != null
              ? " (Tier Price: ${applicableTier.price} - No additional discount)"
              : " (Regular Price: $pricePerUnit, Discount: $discountAmount)"),
      icon: Icons.check_circle,
      primaryColor: Colors.green,
    );
  }

  double _calculateBasePrice(SaleMode saleMode) {
    double price = 0;

    if (saleMode.priceType?.toLowerCase() == 'flat' &&
        saleMode.flatPrice != null) {
      price = saleMode.flatPrice!;
      log('💰 Using flat price: $price');
    } else if (saleMode.unitPrice != null) {
      price = saleMode.unitPrice!;
      log('💰 Using unit price: $price');
    }

    return price;
  }

  double _calculateDiscount(SaleMode saleMode, double pricePerUnit) {
    double discount = 0;

    if (saleMode.discountValue != null && saleMode.discountValue! > 0) {
      if (saleMode.discountType?.toLowerCase() == 'percentage' ||
          saleMode.discountType?.toLowerCase() == 'percent') {
        discount = pricePerUnit * (saleMode.discountValue! / 100);
        log('🎯 Applied percentage discount: ${saleMode.discountValue!}% = $discount');
      } else {
        discount = saleMode.discountValue!;
        log('🎯 Applied fixed discount: $discount');
      }
    }

    return discount;
  }



  double calculateTotalForAllProducts() {
    double total = 0;
    for (int i = 0; i < products.length; i++) {
      if (_disposedProductIndexes.contains(i)) continue;

      final product = products[i];
      final totalValue = product["total"] ?? 0;
      if (totalValue is int) {
        total += totalValue.toDouble();
      } else if (totalValue is String) {
        total += double.tryParse(totalValue) ?? 0;
      } else if (totalValue is double) {
        total += totalValue;
      }
    }
    return total;
  }

  double calculateSpecificDiscountTotal() {
    double discount = 0;
    for (int i = 0; i < products.length; i++) {
      if (_disposedProductIndexes.contains(i)) continue;

      final product = products[i];
      final discountAmount = product["discount_amount"] ?? 0;
      if (discountAmount is int) {
        discount += discountAmount.toDouble();
      } else if (discountAmount is String) {
        discount += double.tryParse(discountAmount) ?? 0;
      } else if (discountAmount is double) {
        discount += discountAmount;
      }
    }
    return discount;
  }

  double calculateTotalTicketForAllProducts() {
    double total = 0;
    for (int i = 0; i < products.length; i++) {
      if (_disposedProductIndexes.contains(i)) continue;

      final product = products[i];
      final price = product["final_price"] ?? 0;
      final quantity =
          double.tryParse(product["quantity"]?.toString() ?? "0") ?? 0;
      if (price is int) {
        total += price.toDouble() * quantity;
      } else if (price is String) {
        total += (double.tryParse(price) ?? 0) * quantity;
      } else if (price is double) {
        total += price * quantity;
      }
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

    // Apply overall discount
    double overallDiscount = calculateDiscountTotal();

    // Apply delivery charge
    double deliveryCharge = calculateDeliveryTotal();

    return (subtotal - overallDiscount) + deliveryCharge;
  }

  void updateTotal(int index) {
    if (_disposedProductIndexes.contains(index)) return;

    final priceStr = getControllerText(index, "price");
    final quantityStr = getControllerText(index, "quantity");

    final price = double.tryParse(priceStr) ?? 0;
    final quantity = int.tryParse(quantityStr) ?? 0;
    final total = price * quantity;

    setControllerText(index, "total", total.toStringAsFixed(2));
    products[index]["total"] = total;

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
      products[index]["discount_amount"] = 0;

      // Set price using safe method
      final sellingPrice = newVal.sellingPrice ?? 0.0;
      setControllerText(index, "price", sellingPrice.toStringAsFixed(2));
      products[index]["final_price"] = sellingPrice;

      // Set quantity using safe method
      int initialQuantity = 1;
      setControllerText(index, "quantity", initialQuantity.toString());
      products[index]["quantity"] = initialQuantity.toString();

      // Calculate initial total
      updateTotal(index);

      // Load sale modes from product data (no API call needed)
      _loadSaleModesForProduct(index, newVal);
    });
  }

  void _updateChangeAmount() {
    final bloc = context.read<CreatePosSaleBloc>();
    final paidAmount = double.tryParse(bloc.payableAmount.text) ?? 0;
    final netTotal = calculateAllFinalTotal();
    final change = paidAmount - netTotal;

    changeAmountController.text =
    change > 0 ? change.toStringAsFixed(2) : "0.00";
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
        "discount_type": "fixed",
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
        DateFormat("dd-MM-yyyy")
            .parse(bloc.dateEditingController.text.trim(), true),
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
    log('📤 Sale submission body: $body');
  }

  // ==================== UI BUILDERS ====================

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBg(context),
        title: Text(
          'Create Sale',
          style: AppTextStyle.titleMedium(context)
              .copyWith(color: AppColors.text(context)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reset form
              context.read<CreatePosSaleBloc>().products.clear();
              context.read<CreatePosSaleBloc>().addProduct();
              _selectedSaleModes.clear();
              _availableSaleModes.clear();
              _isLoadingSaleModes.clear();
              _disposedProductIndexes.clear();
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
                          icon: const Icon(Icons.check_circle),
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
      padding: const EdgeInsets.all(12.0),
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
          Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
            ),
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
                  bloc.customType =
                  (newVal?.id == -1) ? "Walking Customer" : "Saved Customer";
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryColor(context),
                ),
                onPressed: addProduct,
              ),
            ],
          ),

          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final productData = entry.value;
            final product = productData["product"] as ProductModelStockModel?;

            // Skip if this product index is disposed
            if (_disposedProductIndexes.contains(index)) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bottomNavBg(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
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
                          Icons.remove_circle_outline,
                          color: AppColors.errorColor(context),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => removeProduct(index),
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
                          hint: "Select Category",
                          isLabel: true,
                          isSearch: true,
                          value: selectedCategory.isEmpty ? null : selectedCategory,
                          itemList:
                          categoryList.map((e) => e.name ?? "").toList(),
                          onChanged: (newVal) {
                            setState(() {
                              categoriesBloc.selectedState = newVal.toString();
                              final matchingCategory = categoryList.firstWhere(
                                    (category) =>
                                category.name.toString() == newVal.toString(),
                                orElse: () => CategoryModel(),
                              );
                              categoriesBloc.selectedStateId =
                                  matchingCategory.id?.toString() ?? "";
                              productData["product"] = null;
                              productData["product_id"] = null;
                              setControllerText(index, "price", "0");
                              setControllerText(index, "quantity", "1");
                              updateTotal(index);
                            });
                          },
                        ),
                      );
                    },
                  ),

                  // Product Dropdown
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: BlocBuilder<ProductsBloc, ProductsState>(
                          builder: (context, state) {
                            final selectedCategoryId =
                                categoriesBloc.selectedStateId;
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
                            }).toList();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: AppDropdown<ProductModelStockModel>(
                                isRequired: true,
                                isLabel: true,
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
                      ),
                      if (product != null) SizedBox(width: 8),
                      if (product != null)
                        Expanded(
                          flex: 2,
                          child: _buildSaleModeDropdown(index, product),
                        ),
                    ],
                  ),

                  // Price and Quantity Row
                  Row(
                    children: [
                      // Price Input
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),

                              SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: getController(index, "price"),
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}$'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.primaryColor(context),
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    productData["price"] = val;
                                    updateTotal(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Quantity Controls
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quantity *",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  // ➖ Minus Button
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor(context)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () {
                                        int q = int.tryParse(
                                            getControllerText(
                                                index, "quantity")) ??
                                            1;

                                        if (q > 1) {
                                          q--;
                                          setControllerText(
                                              index, "quantity", q.toString());
                                          productData["quantity"] = q.toString();

                                          // Reapply sale mode pricing if selected
                                          final selectedSaleMode = _selectedSaleModes[index];
                                          if (selectedSaleMode != null) {
                                            _applySaleModePricing(index, selectedSaleMode);
                                          } else {
                                            updateTotal(index);
                                          }
                                        }
                                      },
                                    ),
                                  ),

                                  // ✍️ Quantity TextField
                                  Expanded(
                                    child: SizedBox(
                                      height: 32,
                                      child: TextField(
                                        controller:
                                        getController(index, "quantity"),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          int q = int.tryParse(val) ?? 1;

                                          final stockQty = product?.stockQty ?? 0;
                                          if (stockQty > 0 && q > stockQty) {
                                            q = stockQty;
                                            setControllerText(
                                                index, "quantity", q.toString());
                                          }

                                          productData["quantity"] = q.toString();

                                          // Reapply sale mode pricing if selected
                                          final selectedSaleMode = _selectedSaleModes[index];
                                          if (selectedSaleMode != null) {
                                            _applySaleModePricing(index, selectedSaleMode);
                                          } else {
                                            updateTotal(index);
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  // ➕ Plus Button
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor(context)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () {
                                        int q = int.tryParse(
                                            getControllerText(
                                                index, "quantity")) ??
                                            1;

                                        final stockQty = product?.stockQty ?? 0;
                                        if (stockQty == 0 || q < stockQty) {
                                          q++;
                                          setControllerText(
                                              index, "quantity", q.toString());
                                          productData["quantity"] = q.toString();

                                          // Reapply sale mode pricing if selected
                                          final selectedSaleMode = _selectedSaleModes[index];
                                          if (selectedSaleMode != null) {
                                            _applySaleModePricing(index, selectedSaleMode);
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

                  // Total Display
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          "৳${(double.tryParse(getControllerText(index, "total")) ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSaleModeDropdown(int index, ProductModelStockModel product) {
    final isLoading = _isLoadingSaleModes[index] ?? false;
    final availableModes = _availableSaleModes[index] ?? [];
    final selectedMode = _selectedSaleModes[index];

    // Debug log to see what's in the product
    if (product.saleModes != null && product.saleModes!.isNotEmpty) {
      log(
        '🎯 Product ${product.name} has ${product.saleModes!.length} sale modes from API',
      );
      for (var mode in product.saleModes!) {
        log(
          '   - Mode: ${mode.saleModeName}, Active: ${mode.isActive}, Price: ${mode.unitPrice}, Tiers: ${mode.tiers?.length ?? 0}',
        );
      }
    }

    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor(context),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Loading sale modes...",
              style: TextStyle(fontSize: 14, color: Colors.blue.shade800),
            ),
          ],
        ),
      );
    }

    if (availableModes.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No sale modes configured for this product",
                style: TextStyle(fontSize: 14, color: Colors.orange.shade800),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: AppDropdown<SaleMode>(
        label: "Sale Mode (Optional)",
        hint: selectedMode?.saleModeName ?? "Select Sale Mode",
        isLabel: true,
        isSearch: false,
        value: selectedMode,
        itemList: availableModes,
        onChanged: (newVal) => _onSaleModeChanged(index, newVal),
      ),
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

    return Container(
      padding: const EdgeInsets.all(12.0),
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
          Text(
            'Additional Charges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 12),
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
      ),
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
          Text(
            'Summary & Payment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
            ),
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

                      final selectedAccount = bloc.accountModel ??
                          (filteredList.isNotEmpty
                              ? filteredList.first
                              : null);
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
                  hintText:
                  isWalkInCustomer ? 'Change (0.00)' : 'Change Amount',
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

