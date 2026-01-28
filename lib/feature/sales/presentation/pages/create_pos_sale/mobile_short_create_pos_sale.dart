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
  bool _isWalkInCustomer = true; // Track customer type

  // Sale Mode related - Per product index
  final Map<int, SaleMode?> _selectedSaleModes = {};
  final Map<int, List<SaleMode>> _availableSaleModes = {};
  final Map<int, bool> _isLoadingSaleModes = {};

  // Scroll controller for better UX
  final ScrollController _scrollController = ScrollController();

  // Track disposed controllers to prevent reuse
  final Set<int> _disposedProductIndexes = {};

  // Track product stock and unit conversions
  final Map<int, Map<String, dynamic>> _productStockInfo = {};

  // Track if we should auto-update payable amount
  final bool _shouldAutoUpdatePayable = true;

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

    // Listen to charge controller changes
    _setupChargeListeners(bloc);

    Future.microtask(() => setDefaultSalesUser());
  }

  void _setupChargeListeners(CreatePosSaleBloc bloc) {
    // Listen to charge controller changes to update payable amount
    bloc.discountOverAllController.addListener(_updatePayableAndChangeAmount);
    bloc.serviceChargeOverAllController.addListener(
      _updatePayableAndChangeAmount,
    );
    bloc.deliveryChargeOverAllController.addListener(
      _updatePayableAndChangeAmount,
    );
    bloc.vatOverAllController.addListener(_updatePayableAndChangeAmount);
  }

  void _updatePayableAndChangeAmount() {
    if (!_shouldAutoUpdatePayable) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isWalkInCustomer && _isChecked) {
        // Auto-update payable amount for walk-in customer
        _updatePayableAmountForWalkIn();
      }
      _updateChangeAmount();
      setState(() {});
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
    _productStockInfo.clear();

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
    _productStockInfo.remove(index);

    // Let the bloc handle controller disposal
    context.read<CreatePosSaleBloc>().removeProduct(index);

    // Update totals
    _updateAllTotals();
    setState(() {});
  }

  void _clearProductSelection(int index) {
    log('🔄 Clearing product selection at index: $index');

    setState(() {
      // Clear local state
      _selectedSaleModes.remove(index);
      _availableSaleModes.remove(index);
      _isLoadingSaleModes.remove(index);
      _productStockInfo.remove(index);

      // Clear product data
      products[index]["product"] = null;
      products[index]["product_id"] = null;
      products[index]["product_name"] = null;
      products[index]["sale_mode_id"] = null;
      products[index]["sale_mode_name"] = null;
      products[index]["discount_amount"] = 0;
      products[index]["final_price"] = 0;
      products[index]["total"] = 0;
      products[index]["conversion_factor"] = 1.0;

      // Clear controllers
      setControllerText(index, "price", "");
      setControllerText(index, "quantity", "");
      setControllerText(index, "total", "");

      // Update totals
      _updateAllTotals();
    });

    log('✅ Product cleared at index: $index');
  }

  // ==================== SALE MODE FUNCTIONS ====================

  void _loadSaleModesForProduct(int index, ProductModelStockModel product) {
    if (_disposedProductIndexes.contains(index)) return;
    if (_availableSaleModes.containsKey(index)) return;

    log('🔄 LOADING SALE MODES for product: ${product.name}');
    log('   - Product ID: ${product.id}');
    log('   - Product Unit: ${product.unitInfo?.name}');
    log('   - Product Stock: ${product.stockQty}');

    setState(() => _isLoadingSaleModes[index] = true);

    try {
      List<SaleMode> activeConfigs = [];

      // Check if product has pre-configured sale modes in the JSON response
      if (product.saleModes != null && product.saleModes!.isNotEmpty) {
        log('✅ Found ${product.saleModes!.length} sale modes in API response');

        // Dump ALL sale mode data for debugging
        for (var mode in product.saleModes!) {
          log('   ┌─────────────────────────────────────');
          log('   │ SaleMode Object:');
          log('   │   Database ID: ${mode.id}');
          log('   │   Sale Mode ID: ${mode.saleModeId}');
          log('   │   Sale Mode Name: ${mode.saleModeName}');
          log('   │   Base Unit Name: ${mode.baseUnitName}');
          log('   │   Conversion Factor: ${mode.conversionFactor}');
          log('   │   Price Type: ${mode.priceType}');
          log('   │   Unit Price: ${mode.unitPrice}');
          log('   │   Flat Price: ${mode.flatPrice}');
          log('   │   Discount Type: ${mode.discountType}');
          log('   │   Discount Value: ${mode.discountValue}');
          log('   │   Is Active: ${mode.isActive}');

          // Check if this is a "Dozen" type
          if ((mode.saleModeName?.toLowerCase().contains('dozen') == true ||
              mode.saleModeName?.toLowerCase().contains('ডজন') == true) &&
              mode.conversionFactor != null) {
            log('   │   ⚠️ DOZEN DETECTED!');
            log('   │   Conversion: 1 ${mode.saleModeName} = ${mode.conversionFactor} ${mode.baseUnitName}');
            log('   │   User enters ${mode.saleModeName}, convert to ${mode.baseUnitName}');
            log('   │   Formula: baseQuantity = userInput × ${mode.conversionFactor}');
          }

          // Check tiers
          if (mode.tiers != null && mode.tiers!.isNotEmpty) {
            log('   │   Tiers (${mode.tiers!.length}):');
            for (var tier in mode.tiers!) {
              log('   │     └─ ${tier.minQuantity} - ${tier.maxQuantity ?? "∞"} = ${tier.price}');
              // Check tier units
              log('   │         Tier is in: ${mode.baseUnitName}');
            }
          } else {
            log('   │   No tiers');
          }
          log('   └─────────────────────────────────────');
        }

        // Get only active sale modes
        activeConfigs = product.saleModes!
            .where((mode) => mode.isActive == true)
            .toList();

        log('✅ Active sale modes: ${activeConfigs.length}');

        // Sort for better UX
        activeConfigs.sort((a, b) {
          // Put default/commonly used modes first
          final aName = a.saleModeName?.toLowerCase() ?? '';
          final bName = b.saleModeName?.toLowerCase() ?? '';

          // Sort order: Piece/KG first, then others
          if (aName.contains('piece') || aName.contains('pcs')) return -1;
          if (bName.contains('piece') || bName.contains('pcs')) return 1;
          if (aName.contains('kg') || aName.contains('kilo')) return -1;
          if (bName.contains('kg') || bName.contains('kilo')) return 1;

          return aName.compareTo(bName);
        });

      } else {
        log('ℹ️ No pre-configured sale modes for product ${product.name}');

        // Optional: Create default sale mode from product unit
        if (product.unitInfo != null) {
          log('   Creating default sale mode from product unit');
          final defaultMode = SaleMode(
            id: -1, // Temporary ID
            saleModeId: -1,
            saleModeName: product.unitInfo!.name ?? 'Unit',
            baseUnitName: product.unitInfo!.name,
            conversionFactor: 1.0,
            priceType: 'unit',
            unitPrice: product.sellingPrice ?? 0.0,
            isActive: true,
            tiers: [],
          );
          activeConfigs.add(defaultMode);
        }
      }

      if (!_disposedProductIndexes.contains(index)) {
        setState(() {
          _availableSaleModes[index] = activeConfigs;
          _isLoadingSaleModes[index] = false;

          // Auto-select first sale mode if only one exists
          if (activeConfigs.length == 1) {
            _selectedSaleModes[index] = activeConfigs.first;
            _applySaleModePricing(index, activeConfigs.first);
            log('✅ Auto-selected single sale mode: ${activeConfigs.first.saleModeName}');
          }
        });
      }

    } catch (e, stackTrace) {
      log('❌ ERROR loading sale modes for product ${product.name}: $e');
      log('Stack trace: $stackTrace');

      if (!_disposedProductIndexes.contains(index)) {
        setState(() {
          _availableSaleModes[index] = [];
          _isLoadingSaleModes[index] = false;
        });
      }

      showCustomToast(
        context: context,
        title: 'Error',
        description: "Failed to load sale modes",
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
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
    final product = products[index]["product"] as ProductModelStockModel?;

    if (product == null) return;

    log('🔍 APPLYING SALE MODE: ${saleMode.saleModeName}');
    log('   - Price Type: ${saleMode.priceType}');
    log('   - Conversion: 1 ${saleMode.saleModeName} = ${saleMode.conversionFactor} ${saleMode.baseUnitName}');

    // ==================== CORRECT CONVERSION ====================
    final conversionFactor = saleMode.conversionFactor ?? 1.0;

    // User inputs in sale mode unit (Dozon)
    final saleModeQuantity = quantity; // Dojon
    // Convert to base unit for tier checking
    final baseQuantity = quantity * conversionFactor; // Pics

    log('   📐 User Input: $saleModeQuantity ${saleMode.saleModeName}');
    log('   📐 Base Quantity: $baseQuantity ${saleMode.baseUnitName}');

    // ==================== TIER PRICE CALCULATION ====================
    double pricePerUnit = 0;
    double discountAmount = 0;
    SaleModeTier? applicableTier;
    bool isTierPrice = false;

    if (saleMode.priceType?.toLowerCase() == 'tier' &&
        saleMode.tiers != null && saleMode.tiers!.isNotEmpty) {

      log('🔢 CHECKING ${saleMode.tiers!.length} TIERS');
      log('   Tier quantities are in: ${saleMode.baseUnitName}');

      // 🔥 IMPORTANT: Check tiers in BASE UNIT (Pics)
      for (var tier in saleMode.tiers!) {
        final minQty = double.tryParse(tier.minQuantity) ?? 0;
        final maxQtyStr = tier.maxQuantity;
        final maxQty = (maxQtyStr != null && maxQtyStr.isNotEmpty)
            ? double.tryParse(maxQtyStr) ?? double.infinity
            : double.infinity;

        log('   Tier: ${tier.minQuantity} - ${maxQty == double.infinity ? "∞" : tier.maxQuantity} ${saleMode.baseUnitName} @ ${tier.price}');
        log('   Check: $baseQuantity ${saleMode.baseUnitName} >= $minQty && $baseQuantity <= $maxQty');

        if (baseQuantity >= minQty && baseQuantity <= maxQty) {
          applicableTier = tier;
          isTierPrice = true;
          pricePerUnit = double.tryParse(tier.price) ?? 0;

          // 🔥 IMPORTANT: Tier price is in BASE UNIT per SALE MODE UNIT
          // Example: Tier price 140 means 140 per Dojon (not per Pics)
          log('   ✅ TIER MATCHED!');
          log('   💰 Tier Price: $pricePerUnit per ${saleMode.saleModeName}');
          break;
        }
      }

      if (!isTierPrice) {
        log('⚠️ No tier matched for $baseQuantity ${saleMode.baseUnitName}');

        // Check minimum tier requirement in base unit
        final firstTier = saleMode.tiers!.first;
        final minTierQty = double.tryParse(firstTier.minQuantity) ?? 0;

        if (baseQuantity < minTierQty) {
          log('⚠️ Below minimum tier requirement');
          log('   Required: $minTierQty ${saleMode.baseUnitName}');
          log('   Current: $baseQuantity ${saleMode.baseUnitName}');
          log('   In ${saleMode.saleModeName}: ${minTierQty / conversionFactor}');

          showCustomToast(
            context: context,
            title: 'Minimum Quantity Required!',
            description: "Minimum ${(minTierQty / conversionFactor).toStringAsFixed(2)} ${saleMode.saleModeName} "
                "($minTierQty ${saleMode.baseUnitName}) required for tier pricing",
            icon: Icons.warning,
            primaryColor: Colors.orange,
          );
        }

        // Use default price
        pricePerUnit = _calculateBasePriceForTier(saleMode, product);
      }
    } else {
      // Not tier pricing
      pricePerUnit = _calculateBasePrice(saleMode, product);
      discountAmount = _calculateDiscount(saleMode, pricePerUnit);
    }

    double finalPrice = pricePerUnit - discountAmount;
    if (finalPrice < 0) finalPrice = 0;

    // ==================== SAVE TO STATE ====================
    setControllerText(index, "price", finalPrice.toStringAsFixed(2));
    products[index]["sale_mode_id"] = saleMode.saleModeId;
    products[index]["sale_mode_name"] = saleMode.saleModeName;
    products[index]["discount_amount"] = discountAmount * saleModeQuantity;
    products[index]["final_price"] = finalPrice;
    products[index]["current_tier"] = applicableTier;
    products[index]["conversion_factor"] = conversionFactor;
    products[index]["is_tier_price"] = isTierPrice;
    products[index]["price_type"] = saleMode.priceType;
    products[index]["sale_mode_quantity"] = saleModeQuantity;
    products[index]["base_quantity"] = baseQuantity;

    updateTotal(index);

    // ==================== SHOW MESSAGE ====================
    if (isTierPrice && applicableTier != null) {
      showCustomToast(
        context: context,
        title: 'Tier Price Applied!',
        description: "${applicableTier.minQuantity}-${applicableTier.maxQuantity} ${saleMode.baseUnitName} = "
            "$finalPrice per ${saleMode.saleModeName}",
        icon: Icons.star,
        primaryColor: Colors.green,
      );
    }
  }

// নতুন হেল্পার ফাংশন Tier এর জন্য
  double _calculateBasePriceForTier(SaleMode saleMode, ProductModelStockModel product) {
    final conversionFactor = saleMode.conversionFactor ?? 1.0;
    final productPrice = product.sellingPrice ?? 0.0;

    // Calculate price per sale mode unit
    return productPrice * conversionFactor;
  }
  double _calculateBasePrice(SaleMode saleMode, ProductModelStockModel? product) {
    double price = 0;

    log('💰 CALCULATING BASE PRICE for ${saleMode.saleModeName}');
    log('   - Price Type: ${saleMode.priceType}');
    log('   - Unit Price: ${saleMode.unitPrice}');
    log('   - Flat Price: ${saleMode.flatPrice}');
    log('   - Product Selling Price: ${product?.sellingPrice}');
    log('   - Conversion Factor: ${saleMode.conversionFactor}');

    // First check sale mode specific prices
    if (saleMode.priceType?.toLowerCase() == 'flat') {
      if (saleMode.flatPrice != null && saleMode.flatPrice! > 0) {
        price = saleMode.flatPrice!;
        log('   ✅ Using sale mode flat price: $price');
      } else if (saleMode.unitPrice != null && saleMode.unitPrice! > 0) {
        price = saleMode.unitPrice!;
        log('   ⚠️ Flat price is null, using unit price: $price');
      }
    } else if (saleMode.priceType?.toLowerCase() == 'unit') {
      if (saleMode.unitPrice != null && saleMode.unitPrice! > 0) {
        price = saleMode.unitPrice!;
        log('   ✅ Using sale mode unit price: $price');
      }
    }

    // If still 0, check product price
    if (price == 0 && product != null) {
      final productPrice = product.sellingPrice ?? 0.0;
      final conversionFactor = saleMode.conversionFactor ?? 1.0;

      log('   ⚠️ Sale mode price is 0, using product price: $productPrice');
      log('   📐 Conversion Factor: $conversionFactor');

      // 🔥 IMPORTANT FIX: Correct conversion logic
      if (conversionFactor > 1) {
        // Sale mode is LARGER unit (Dogon/Dozen = 12 Pics)
        // Price should be HIGHER, not lower!
        // Example: 1 Dozen = 12 Pics × 12 Taka = 144 Taka
        price = productPrice * conversionFactor;
        log('   🔥 MULTIPLY: $productPrice × $conversionFactor = $price');
        log('   💡 1 ${saleMode.saleModeName} (${conversionFactor} ${saleMode.baseUnitName}) = $price Tk');
      } else if (conversionFactor < 1) {
        // Sale mode is SMALLER unit (Gram = 0.001 Kg)
        // Price should be LOWER
        price = productPrice * conversionFactor;
        log('   🔥 MULTIPLY (smaller): $productPrice × $conversionFactor = $price');
      } else {
        // No conversion
        price = productPrice;
        log('   🔥 No conversion: $price');
      }
    }

    log('   💰 Final Base Price: $price');
    return price;
  }

  double _calculateDiscount(SaleMode saleMode, double pricePerUnit) {
    double discount = 0;

    if (saleMode.discountValue != null && saleMode.discountValue! > 0) {
      if (saleMode.discountType?.toLowerCase() == 'percentage' ||
          saleMode.discountType?.toLowerCase() == 'percent') {
        discount = pricePerUnit * (saleMode.discountValue! / 100);
        log(
          '🎯 Applied percentage discount: ${saleMode.discountValue!}% = $discount',
        );
      } else {
        discount = saleMode.discountValue!;
        log('🎯 Applied fixed discount: $discount');
      }
    }

    return discount;
  }

  // NEW: Calculate base quantity for stock validation
  double _calculateBaseQuantity(int index, double saleQuantity) {
    if (_disposedProductIndexes.contains(index)) return saleQuantity;

    final saleMode = _selectedSaleModes[index];
    final conversionFactor = saleMode?.conversionFactor ?? 1.0;

    return saleQuantity * conversionFactor;
  }

  bool _validateStockForProduct(
      int index,
      ProductModelStockModel product,
      double quantity,
      ) {
    if (_disposedProductIndexes.contains(index)) return true;

    final saleMode = _selectedSaleModes[index];

    log('📦 STOCK VALIDATION START for ${product.name}');
    log('   - Product ID: ${product.id}');
    log('   - Product Unit: ${product.unitInfo?.name}');
    log('   - Available Stock: ${product.stockQty} ${product.unitInfo?.name}');
    log('   - User Quantity: $quantity');

    if (saleMode == null) {
      // No sale mode - validate directly in product units
      final availableStock = product.stockQty ?? 0;

      if (quantity > availableStock) {
        log('❌ STOCK FAILED: No sale mode, direct comparison');
        showCustomToast(
          context: context,
          title: 'Stock Insufficient!',
          description:
          "Not enough stock for ${product.name}\n"
              "Available: $availableStock ${product.unitInfo?.name ?? 'units'}\n"
              "Requested: $quantity ${product.unitInfo?.name ?? 'units'}",
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return false;
      }

      log('✅ STOCK OK: No sale mode');
      return true;
    }

    // With sale mode - need conversion
    final conversionFactor = saleMode.conversionFactor ?? 1.0;
    final baseUnitName = saleMode.baseUnitName ?? product.unitInfo?.name ?? 'units';
    final saleModeName = saleMode.saleModeName ?? 'units';

    log('   - Sale Mode: $saleModeName');
    log('   - Conversion Factor: $conversionFactor');
    log('   - Base Unit Name: $baseUnitName');

    // 🔧 FIXED: CORRECT CONVERSION
    double baseQuantity;

    if (conversionFactor >= 1 && conversionFactor != 1.0) {
      // User is entering in larger unit (dozen, kg)
      // Convert to smaller base unit (pieces, grams)
      baseQuantity = quantity * conversionFactor;
      log('   - Convert: $quantity $saleModeName × $conversionFactor = $baseQuantity $baseUnitName');
    } else if (conversionFactor < 1) {
      // User is entering in smaller unit (gram), convert to larger (kg)
      baseQuantity = quantity * conversionFactor;
      log('   - Convert: $quantity × $conversionFactor = $baseQuantity');
    } else {
      // No conversion (1:1)
      baseQuantity = quantity;
      log('   - No conversion needed: $baseQuantity');
    }

    // Product stock is always in BASE UNIT (product.unitInfo)
    final availableStock = product.stockQty ?? 0;
    final productUnitName = product.unitInfo?.name ?? 'units';

    log('   - Base Quantity Needed: $baseQuantity $productUnitName');
    log('   - Available Stock: $availableStock $productUnitName');

    // Check if baseQuantity exceeds available stock
    if (baseQuantity > availableStock) {
      log('❌ STOCK FAILED: Insufficient');

      // Calculate maximum possible quantity user can order
      double maxPossible;
      if (conversionFactor >= 1 && conversionFactor != 1.0) {
        maxPossible = (availableStock / conversionFactor).floorToDouble();
      } else if (conversionFactor < 1) {
        maxPossible = (availableStock / conversionFactor).floorToDouble();
      } else {
        maxPossible = availableStock.toDouble();
      }

      showCustomToast(
        context: context,
        title: 'Stock Insufficient!',
        description:
        "Not enough stock for ${product.name}\n\n"
            "📊 Details:\n"
            "• Available: $availableStock $productUnitName\n"
            "• Requested: $quantity $saleModeName\n"
            "• = $baseQuantity $baseUnitName\n\n"
            "📦 You can order max: ${maxPossible.toStringAsFixed(2)} $saleModeName\n"
            "   (= ${(maxPossible * conversionFactor).toStringAsFixed(2)} $baseUnitName)",
        icon: Icons.error,
        primaryColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
      );
      return false;
    }

    log('✅ STOCK OK: Sufficient');
    return true;
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
    final discountText = bloc.discountOverAllController.text.trim();
    if (discountText.isEmpty) return 0.0;

    final discountValue = double.tryParse(discountText) ?? 0.0;
    final subtotal = calculateTotalForAllProducts();

    if (selectedOverallDiscountType == 'percent') {
      return subtotal * (discountValue / 100);
    }
    return discountValue;
  }

  double calculateServiceChargeTotal() {
    final bloc = context.read<CreatePosSaleBloc>();
    final serviceText = bloc.serviceChargeOverAllController.text.trim();
    if (serviceText.isEmpty) return 0.0;

    final serviceValue = double.tryParse(serviceText) ?? 0.0;
    final subtotal = calculateTotalForAllProducts();

    if (selectedOverallServiceChargeType == 'percent') {
      return subtotal * (serviceValue / 100);
    }
    return serviceValue;
  }

  double calculateDeliveryTotal() {
    final bloc = context.read<CreatePosSaleBloc>();
    final deliveryText = bloc.deliveryChargeOverAllController.text.trim();
    if (deliveryText.isEmpty) return 0.0;

    final deliveryValue = double.tryParse(deliveryText) ?? 0.0;
    final subtotal = calculateTotalForAllProducts();

    if (selectedOverallDeliveryType == 'percent') {
      return subtotal * (deliveryValue / 100);
    }
    return deliveryValue;
  }

  double calculateVatTotal() {
    final bloc = context.read<CreatePosSaleBloc>();
    final vatText = bloc.vatOverAllController.text.trim();
    if (vatText.isEmpty) return 0.0;

    final vatValue = double.tryParse(vatText) ?? 0.0;
    final subtotal = calculateTotalForAllProducts();

    if (selectedOverallVatType == 'percent') {
      return subtotal * (vatValue / 100);
    }
    return vatValue;
  }

  double calculateAllFinalTotal() {
    double subtotal = calculateTotalForAllProducts();

    // Apply overall discount
    double overallDiscount = calculateDiscountTotal();

    // Apply service charge
    double serviceCharge = calculateServiceChargeTotal();

    // Apply delivery charge
    double deliveryCharge = calculateDeliveryTotal();

    // Apply VAT
    double vatCharge = calculateVatTotal();

    double finalTotal =
        (subtotal - overallDiscount) +
        serviceCharge +
        deliveryCharge +
        vatCharge;

    // Ensure non-negative
    return finalTotal > 0 ? finalTotal : 0;
  }

  void updateTotal(int index) {
    if (_disposedProductIndexes.contains(index)) return;

    final priceStr = getControllerText(index, "price");
    final quantityStr = getControllerText(index, "quantity");
    final saleMode = _selectedSaleModes[index];
    final priceType = products[index]["price_type"] as String?;

    double price = double.tryParse(priceStr) ?? 0;
    double quantity = double.tryParse(quantityStr) ?? 1;
    double total;

    // Handle FLAT price differently
    if (priceType?.toLowerCase() == 'flat' && saleMode != null) {
      // For flat price, price is already the total for the quantity
      // But we need to multiply by quantity if it's per sale mode unit
      total = price * quantity;
      log('🔄 FLAT PRICE Total Calculation:');
      log('   - Flat Price: $price per ${saleMode.saleModeName}');
      log('   - Quantity: $quantity ${saleMode.saleModeName}');
      log('   - Total: $total');
    } else {
      // Normal unit price calculation
      total = price * quantity;
      log('🔄 UNIT PRICE Total Calculation: $price × $quantity = $total');
    }

    setControllerText(index, "total", total.toStringAsFixed(2));
    products[index]["total"] = total;

    // Auto-update payable amount for walk-in customer when money receipt is checked
    if (_isWalkInCustomer && _isChecked) {
      _updatePayableAmountForWalkIn();
    }

    setState(() {});
  }

  void _updateAllTotals() {
    // Recalculate all totals and update UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isWalkInCustomer && _isChecked) {
        _updatePayableAmountForWalkIn();
      }
      _updateChangeAmount();
      setState(() {});
    });
  }

  void onProductChanged(int index, ProductModelStockModel? newVal) {
    if (newVal == null) {
      // Clear product selection
      _clearProductSelection(index);
      return;
    }

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

    // Stock check (initial check without sale mode)
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
      _productStockInfo.remove(index);

      products[index]["product"] = newVal;
      products[index]["product_id"] = newVal.id;
      products[index]["product_name"] = newVal.name;
      products[index]["sale_mode_id"] = null;
      products[index]["sale_mode_name"] = null;
      products[index]["discount_amount"] = 0;
      products[index]["conversion_factor"] = 1.0;

      // Set default price to product selling price
      final sellingPrice = newVal.sellingPrice ?? 0.0;
      setControllerText(index, "price", sellingPrice.toStringAsFixed(2));
      setControllerText(index, "quantity", "1");
      setControllerText(index, "total", sellingPrice.toStringAsFixed(2));

      // Load sale modes from product data (no API call needed)
      _loadSaleModesForProduct(index, newVal);

      // Update total after setting values
      updateTotal(index);
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

  void _updatePayableAmountForWalkIn() {
    if (!_isWalkInCustomer || !_isChecked) return;

    final bloc = context.read<CreatePosSaleBloc>();
    final netTotal = calculateAllFinalTotal();

    // Only auto-update if the user hasn't manually changed it
    // or if it's different from the calculated total
    final currentPayable = double.tryParse(bloc.payableAmount.text) ?? 0;
    if (currentPayable != netTotal) {
      bloc.payableAmount.text = netTotal.toStringAsFixed(2);
      _updateChangeAmount();
    }
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
    for (int i = 0; i < products.length; i++) {
      if (_disposedProductIndexes.contains(i)) continue;

      final product = products[i];
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

      // Validate product price and quantity are entered
      final price = getControllerText(i, "price");
      final quantity = getControllerText(i, "quantity");

      if (price.isEmpty || double.tryParse(price) == 0) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: "Please enter price for item ${i + 1}",
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }

      if (quantity.isEmpty || int.tryParse(quantity) == 0) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: "Please enter quantity for item ${i + 1}",
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }

      // Validate stock with unit conversion
      final productModel = product["product"] as ProductModelStockModel?;
      final saleQuantity = double.tryParse(quantity) ?? 0;
      if (productModel != null &&
          !_validateStockForProduct(i, productModel, saleQuantity)) {
        return; // Stock validation failed, don't submit
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
        "quantity":
            double.tryParse(product["quantity"].toString())?.toInt() ?? 1,
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
        DateFormat(
          "dd-MM-yyyy",
        ).parse(bloc.dateEditingController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "sale_by": user?.id?.toString() ?? '',

      "overall_service_type": selectedOverallServiceChargeType.toLowerCase(),
      "service_charge": bloc.serviceChargeOverAllController.text.isEmpty
          ? 0
          : double.tryParse(bloc.serviceChargeOverAllController.text),
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

    // Log the body for debugging
    final jsonBody = jsonEncode(body);
    log('📤 Sale submission body: $jsonBody');

    // Log sale_mode_ids being sent
    for (var item in transferProducts) {
      if (item["sale_mode_id"] != null) {
        log('   - Item sale_mode_id: ${item["sale_mode_id"]}');
      }
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reset form
              context.read<CreatePosSaleBloc>().products.clear();
              context.read<CreatePosSaleBloc>().addProduct();
              _selectedSaleModes.clear();
              _availableSaleModes.clear();
              _isLoadingSaleModes.clear();
              _disposedProductIndexes.clear();
              _productStockInfo.clear();
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
                Navigator.pop(context);
                AppRoutes.pushReplacement(context, MobilePosSaleScreen());
              } else if (state is CreatePosSaleFailed) {
                Navigator.pop(context);

                // Check if error is about insufficient stock
                final errorMessage = state.content.toLowerCase();
                if (errorMessage.contains('insufficient stock') ||
                    errorMessage.contains('not enough stock')) {
                  // Show stock-specific error
                  showCustomToast(
                    context: context,
                    title: 'Stock Error',
                    description: state.content,
                    icon: Icons.error,
                    primaryColor: Colors.red,
                  );
                } else {
                  // Show generic error dialog
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
              }
            },
            builder: (context, state) {
              final bloc = context.read<CreatePosSaleBloc>();
              final selectedCustomer = bloc.selectClintModel;
              final isWalkInCustomer = selectedCustomer?.id == -1;

              // Calculate final total for display
              final netTotal = calculateAllFinalTotal();

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
                        _buildSummarySection(bloc, isWalkInCustomer, netTotal),

                        // Submit Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AppButton(
                              size: 100,
                              isOutlined: true,
                              onPressed: () {
                                // Cancel button - go back or clear form
                                AppRoutes.pop(context);
                              },
                              name: 'Cancel',
                            ),
                            AppButton(
                              size: 100,
                              onPressed: _validateAndSubmit,
                              name: 'Create Sale',
                            ),
                          ],
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
          const SizedBox(height: 6),

          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              // Fast View: Special গ্রাহক আগে, Regular পরে
              List<CustomerActiveModel> sortedCustomers = [
                ...context.read<CustomerBloc>().activeCustomer.where(
                  (c) => c.specialCustomer == true,
                ),
                ...context.read<CustomerBloc>().activeCustomer.where(
                  (c) => c.specialCustomer != true,
                ),
              ];

              return AppDropdown<CustomerActiveModel>(
                label: "Customer *",
                hint: bloc.selectClintModel?.name ?? "Select Customer",
                isSearch: true,
                isRequired: true,
                value: bloc.selectClintModel,
                itemList: [
                  CustomerActiveModel(name: 'Walk-in-customer', id: -1),
                  ...sortedCustomers,
                ],
                onChanged: (newVal) {
                  setState(() {
                    bloc.selectClintModel = newVal;
                    bloc.customType = (newVal?.id == -1)
                        ? "Walking Customer"
                        : "Saved Customer";
                    _isWalkInCustomer = newVal?.id == -1;

                    if (newVal?.id == -1) {
                      _isChecked = true;
                      bloc.isChecked = true;

                      Future.delayed(const Duration(milliseconds: 100), () {
                        final netTotal = calculateAllFinalTotal();
                        bloc.payableAmount.text = netTotal.toStringAsFixed(2);
                        _updateChangeAmount();
                      });
                    } else {
                      _isChecked = false;
                      bloc.isChecked = false;

                      bloc.payableAmount.clear();
                      changeAmountController.clear();
                    }
                  });
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                ),
              ),
              InkWell(
                onTap: addProduct,
                child: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryColor(context),
                ),
              ),
            ],
          ),

          gapH8,
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final productData = entry.value;
            final product = productData["product"] as ProductModelStockModel?;

            // Skip if this product index is disposed
            if (_disposedProductIndexes.contains(index)) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
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
                        margin: const EdgeInsets.only(bottom: 6),
                        child: AppDropdown(
                          label: "Category",
                          hint: "Select Category",
                          isLabel: true,
                          isSearch: true,
                          value: selectedCategory,
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
                              _clearProductSelection(index);
                            });
                          },
                        ),
                      );
                    },
                  ),

                  // Product Dropdown - FIXED: Added onClear callback
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
                                  final categoryMatch =
                                      selectedCategoryId.isEmpty
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
                                isLabel: true,
                                isSearch: true,
                                onClear: (value) {
                                  // Clear product selection
                                  _clearProductSelection(index);
                                },
                                label: "Product",
                                hint: selectedCategoryId.isEmpty
                                    ? "Select Category First"
                                    : "Select Product",
                                value: product,
                                itemList: filteredProducts,
                                onChanged: (newVal) =>
                                    onProductChanged(index, newVal),
                                validator: (value) => value == null
                                    ? 'Please select Product'
                                    : null,
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

                  // Stock Info Display
                  if (product != null && _selectedSaleModes[index] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Stock: ${product.stockQty ?? 0} ${product.unitInfo?.name ?? 'units'} "
                              "(${_calculateBaseQuantity(index, 1).toStringAsFixed(3)} ${_selectedSaleModes[index]?.baseUnitName} per ${_selectedSaleModes[index]?.saleModeName})",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                "Price *",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),

                              SizedBox(
                                height: 32,
                                child: TextFormField(
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
                                    hintStyle: AppTextStyle.body(context)
                                        .copyWith(
                                          color: AppColors.greyColor(context),
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter price';
                                    }
                                    final price = double.tryParse(value);
                                    if (price == null) {
                                      return 'Enter valid price';
                                    }
                                    if (price <= 0) {
                                      return 'Price must be greater than 0';
                                    }
                                    return null;
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
                                  color: AppColors.text(context),
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
                                      color: AppColors.primaryColor(
                                        context,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () {
                                        int q =
                                            int.tryParse(
                                              getControllerText(
                                                index,
                                                "quantity",
                                              ),
                                            ) ??
                                            1;

                                        if (q > 1) {
                                          q--;
                                          setControllerText(
                                            index,
                                            "quantity",
                                            q.toString(),
                                          );
                                          productData["quantity"] = q
                                              .toString();

                                          // Reapply sale mode pricing if selected
                                          final selectedSaleMode =
                                              _selectedSaleModes[index];
                                          if (selectedSaleMode != null) {
                                            _applySaleModePricing(
                                              index,
                                              selectedSaleMode,
                                            );
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
                                      child: TextFormField(
                                        controller: getController(
                                          index,
                                          "quantity",
                                        ),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintStyle: AppTextStyle.body(context)
                                              .copyWith(
                                                color: AppColors.greyColor(
                                                  context,
                                                ),
                                              ),
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          int q = int.tryParse(val) ?? 1;

                                          // Check stock with unit conversion
                                          final saleMode =
                                              _selectedSaleModes[index];
                                          if (saleMode != null &&
                                              product != null) {
                                            final conversionFactor =
                                                saleMode.conversionFactor ??
                                                1.0;
                                            final baseQuantity =
                                                q * conversionFactor;
                                            final stockQty =
                                                product.stockQty ?? 0;

                                            if (baseQuantity > stockQty) {
                                              // Find maximum possible quantity
                                              final maxPossible =
                                                  (stockQty / conversionFactor)
                                                      .floor();
                                              if (maxPossible > 0) {
                                                q = maxPossible;
                                                setControllerText(
                                                  index,
                                                  "quantity",
                                                  q.toString(),
                                                );
                                              } else {
                                                q = 0;
                                                setControllerText(
                                                  index,
                                                  "quantity",
                                                  "0",
                                                );
                                                showCustomToast(
                                                  context: context,
                                                  title: 'Stock Limit',
                                                  description:
                                                      "Not enough stock for this sale mode",
                                                  icon: Icons.warning,
                                                  primaryColor: Colors.orange,
                                                );
                                              }
                                            }
                                          } else {
                                            // Normal stock check without sale mode
                                            final stockQty =
                                                product?.stockQty ?? 0;
                                            if (stockQty > 0 && q > stockQty) {
                                              q = stockQty;
                                              setControllerText(
                                                index,
                                                "quantity",
                                                q.toString(),
                                              );
                                            }
                                          }

                                          productData["quantity"] = q
                                              .toString();

                                          // Reapply sale mode pricing if selected
                                          final selectedSaleMode =
                                              _selectedSaleModes[index];
                                          if (selectedSaleMode != null) {
                                            _applySaleModePricing(
                                              index,
                                              selectedSaleMode,
                                            );
                                          } else {
                                            updateTotal(index);
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter quantity';
                                          }
                                          final qty = int.tryParse(value);
                                          if (qty == null) {
                                            return 'Enter valid number';
                                          }
                                          if (qty <= 0) {
                                            return 'Quantity must be > 0';
                                          }

                                          // Additional stock validation with unit conversion
                                          if (product != null) {
                                            final saleMode =
                                                _selectedSaleModes[index];
                                            final conversionFactor =
                                                saleMode?.conversionFactor ??
                                                1.0;
                                            final baseQuantity =
                                                qty * conversionFactor;
                                            final stockQty =
                                                product.stockQty ?? 0;

                                            if (baseQuantity > stockQty) {
                                              return 'Insufficient stock (${baseQuantity.toStringAsFixed(3)} ${product.unitInfo?.name ?? 'units'} needed)';
                                            }
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ),

                                  // ➕ Plus Button
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor(
                                        context,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () {
                                        int q =
                                            int.tryParse(
                                              getControllerText(
                                                index,
                                                "quantity",
                                              ),
                                            ) ??
                                            1;

                                        final saleMode =
                                            _selectedSaleModes[index];
                                        if (saleMode != null &&
                                            product != null) {
                                          final conversionFactor =
                                              saleMode.conversionFactor ?? 1.0;
                                          final baseQuantity =
                                              (q + 1) * conversionFactor;
                                          final stockQty =
                                              product.stockQty ?? 0;

                                          if (baseQuantity <= stockQty) {
                                            q++;
                                            setControllerText(
                                              index,
                                              "quantity",
                                              q.toString(),
                                            );
                                            productData["quantity"] = q
                                                .toString();

                                            // Reapply sale mode pricing if selected
                                            if (saleMode != null) {
                                              _applySaleModePricing(
                                                index,
                                                saleMode,
                                              );
                                            } else {
                                              updateTotal(index);
                                            }
                                          }
                                        } else {
                                          // Normal stock check without sale mode
                                          final stockQty =
                                              product?.stockQty ?? 0;
                                          if (stockQty == 0 || q < stockQty) {
                                            q++;
                                            setControllerText(
                                              index,
                                              "quantity",
                                              q.toString(),
                                            );
                                            productData["quantity"] = q
                                                .toString();

                                            // Reapply sale mode pricing if selected
                                            final selectedSaleMode =
                                                _selectedSaleModes[index];
                                            if (selectedSaleMode != null) {
                                              _applySaleModePricing(
                                                index,
                                                selectedSaleMode,
                                              );
                                            } else {
                                              updateTotal(index);
                                            }
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
          '   - Mode: ${mode.saleModeName}, Sale Mode ID: ${mode.saleModeId}, ID: ${mode.id}',
        );
      }
    }

    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
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
      return SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: AppDropdown<SaleMode>(
        label: "Sale Mode ",
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
                    onChanged: (_) {
                      // Update payable and change amounts when charges change
                      _updatePayableAndChangeAmount();
                      setState(() {});
                    },
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
      padding: const EdgeInsets.all(8.0),
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
          const SizedBox(height: 6),
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
                      // Update payable amount
                      _updatePayableAndChangeAmount();
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
                      // Update payable amount
                      _updatePayableAndChangeAmount();
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

  Widget _buildSummarySection(
    CreatePosSaleBloc bloc,
    bool isWalkInCustomer,
    double netTotal,
  ) {
    final productTotal = calculateTotalTicketForAllProducts();
    final subTotal = calculateTotalForAllProducts();
    final specificDiscount = calculateSpecificDiscountTotal();
    final overallDiscount = calculateDiscountTotal();
    final serviceCharge = calculateServiceChargeTotal();
    final deliveryCharge = calculateDeliveryTotal();

    return Container(
      padding: const EdgeInsets.all(8.0),
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
          const SizedBox(height: 6),

          // Customer type info
          Container(
            padding: const EdgeInsets.all(6),
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
          const SizedBox(height: 8),

          // Summary
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.greyColor(context).withValues(alpha: 0.1),
            ),
            child: Column(
              children: [
                _buildSummaryRow("Product Total:", productTotal),
                if (specificDiscount > 0)
                  _buildSummaryRow("Specific Discount (-):", specificDiscount),
                _buildSummaryRow("Sub Total:", subTotal),
                if (overallDiscount > 0)
                  _buildSummaryRow("Overall Discount (-):", overallDiscount),
                if (serviceCharge > 0)
                  _buildSummaryRow("Service Charge (+):", serviceCharge),
                if (deliveryCharge > 0) const Divider(height: 8),
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

              if (isWalkInCustomer && _isChecked) {
                // Walk-in with money receipt: auto-fill exact amount (read-only)
                Future.delayed(const Duration(milliseconds: 50), () {
                  final netTotal = calculateAllFinalTotal();
                  bloc.payableAmount.text = netTotal.toStringAsFixed(2);
                  _updateChangeAmount();
                });
              } else if (!isWalkInCustomer && _isChecked) {
                // Saved customer with money receipt: auto-fill with net total (editable)
                Future.delayed(const Duration(milliseconds: 50), () {
                  final netTotal = calculateAllFinalTotal();
                  bloc.payableAmount.text = netTotal.toStringAsFixed(2);
                  _updateChangeAmount();
                });
              } else if (!_isChecked) {
                // Money receipt unchecked for both: clear fields
                bloc.payableAmount.clear();
                changeAmountController.clear();
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),

        // Add a note about payment options
        if (!isWalkInCustomer && !_isChecked)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Without money receipt: No payment tracking",
                    style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        if (_isChecked) ...[
          const SizedBox(height: 4),
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
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomInputField(
                  controller: changeAmountController,
                  hintText: 'Change Amount',
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
                      hintText: isWalkInCustomer
                          ? 'Payable Amount (Exact)'
                          : 'Payable Amount *',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      readOnly: isWalkInCustomer && _isChecked,
                      // Read-only for walk-in
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
                        if (isWalkInCustomer && _isChecked) {
                          final netTotal = calculateAllFinalTotal();
                          if (numericValue != netTotal) {
                            return 'Must pay exact amount: ৳${netTotal.toStringAsFixed(2)}';
                          }
                        }

                        return null;
                      },
                      onChanged: (value) {
                        _updateChangeAmount();
                        setState(() {});
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 4),
                      child: Text(
                        isWalkInCustomer && _isChecked
                            ? "Walk-in: Pay exact total (auto-filled)"
                            : isWalkInCustomer
                            ? "Walk-in: Enter amount (no receipt)"
                            : "Saved: Enter due or advance amount",
                        style: TextStyle(
                          color: isWalkInCustomer && _isChecked
                              ? Colors.orange[700]
                              : Colors.green[700],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Display due/advance amount for saved customer
          if (!isWalkInCustomer && bloc.payableAmount.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total: ৳${netTotal.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (bloc.payableAmount.text.isNotEmpty)
                          FutureBuilder<double>(
                            future: Future.value(calculateAllFinalTotal()),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final netTotal = snapshot.data!;
                                final payable =
                                    double.tryParse(bloc.payableAmount.text) ??
                                    0;
                                final difference = payable - netTotal;

                                if (difference != 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      difference > 0
                                          ? "Advance: ৳${difference.abs().toStringAsFixed(2)}"
                                          : "Due: ৳${difference.abs().toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: difference > 0
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
