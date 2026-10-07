import 'package:meherinMart/desktop/widgets/sidebar.dart';
import 'dart:developer';

import '../../shared/create_pos_sale/sale_payment_rules.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';
import '/feature/products/product/data/model/product_stock_model.dart';
import '/feature/users_list/presentation/bloc/users/user_bloc.dart';

import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../../products/categories/data/model/categories_model.dart';
import '../../../../products/categories/presentation/bloc/categories/categories_bloc.dart';
import '../../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';

class CreatePosSalePage extends StatefulWidget {
  const CreatePosSalePage({super.key});

  @override
  _CreatePosSalePageState createState() => _CreatePosSalePageState();
}

class _CreatePosSalePageState extends State<CreatePosSalePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController changeAmountController = TextEditingController();
  late CategoriesBloc categoriesBloc;

  // Add these missing variables that were causing errors
  double discount = 0;
  double vat = 0;
  double serviceCharge = 0;
  double deliveryCharge = 0;
  double ticketTotal = 0;
  double specificDiscount = 0;
  double overallTotal = 0;
  bool _isChecked = false;

  // Add missing variables for charge types
  String selectedOverallVatType = 'fixed';
  String selectedOverallDiscountType = 'fixed';
  String selectedOverallServiceChargeType = 'fixed';
  String selectedOverallDeliveryType = 'fixed';

  @override
  void initState() {
    context.read<AccountBloc>().add(FetchAccountActiveList(context));
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    context.read<UserBloc>().add(FetchUserList(context));
    context.read<ProductsBloc>().add(FetchProductsStockList(context));
    categoriesBloc = context.read<CategoriesBloc>();
    categoriesBloc.add(FetchCategoriesList(context));

    super.initState();

    // Initialize dates
    final bloc = context.read<CreatePosSaleBloc>();
    bloc.dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );
    bloc.withdrawDateController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );

    // Initialize charge types from BLoC
    selectedOverallVatType = bloc.selectedOverallVatType;
    selectedOverallDiscountType = bloc.selectedOverallDiscountType;
    selectedOverallServiceChargeType = bloc.selectedOverallServiceChargeType;
    selectedOverallDeliveryType = bloc.selectedOverallDeliveryType;
    _isChecked = bloc.isChecked;

    Future.microtask(() {
      setDefaultSalesUser();
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

    // Get all users from Bloc
    final userList = context.read<UserBloc>().list;

    if (userList.isEmpty) return;

    // Find matched user
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
    super.dispose();
  }

  void _updateChangeAmount() {
    final bloc = context.read<CreatePosSaleBloc>();
    final payableAmount = double.tryParse(bloc.payableAmount.text) ?? 0.0;
    // Align with mobile behavior: change = payable - netTotal
    final changeAmount = payableAmount - calculateAllFinalTotal();

    setState(() {
      changeAmountController.text = changeAmount.toStringAsFixed(2);
    });
  }

  // Helper: normalize any incoming discount type string into internal keys ('percent' | 'fixed')
  String _normalizeDiscountType(dynamic raw) {
    if (raw == null) return 'fixed';
    final s = raw.toString().toLowerCase();
    if (s == 'percent' || s == 'percentage' || s.startsWith('perc')) return 'percent';
    // treat anything else as fixed
    return 'fixed';
  }

  // Get products from BLoC
  List<Map<String, dynamic>> get products {
    return context.read<CreatePosSaleBloc>().products;
  }

  // Get controllers from BLoC
  Map<int, Map<String, TextEditingController>> get controllers {
    return context.read<CreatePosSaleBloc>().controllers;
  }

  // Add product method
  void addProduct() {
    context.read<CreatePosSaleBloc>().addProduct();
    setState(() {});
  }

  // Remove product method
  void removeProduct(int index) {
    context.read<CreatePosSaleBloc>().removeProduct(index);
    setState(() {});
  }

  // Calculation methods
  double calculateTotalForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      final totalValue = product["total"] ?? 0;

      // Convert to double safely (int / String / double)
      if (totalValue is int) {
        totalSum += totalValue.toDouble();
      } else if (totalValue is String) {
        totalSum += double.tryParse(totalValue) ?? 0;
      } else if (totalValue is double) {
        totalSum += totalValue;
      } else {
        // fallback
        totalSum += 0;
      }
    }
    return totalSum;
  }

  double calculateTotalTicketForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      final ticketValue = product["ticket_total"] ?? 0;

      if (ticketValue is int) {
        totalSum += ticketValue.toDouble();
      } else if (ticketValue is String) {
        totalSum += double.tryParse(ticketValue) ?? 0;
      } else if (ticketValue is double) {
        totalSum += ticketValue;
      } else {
        totalSum += 0;
      }
    }
    return totalSum;
  }

  double calculateSpecificDiscountTotal() {
    double discountSum = 0;

    for (var product in products) {
      // Parse safely
      double productDiscount = 0;
      double ticketTotal = 0;

      final discountValue = product["discount"] ?? 0;
      final ticketTotalValue = product["ticket_total"] ?? 0;

      // Convert both to double safely
      productDiscount = discountValue is String
          ? double.tryParse(discountValue) ?? 0
          : (discountValue is num ? discountValue.toDouble() : 0);

      ticketTotal = ticketTotalValue is String
          ? double.tryParse(ticketTotalValue) ?? 0
          : (ticketTotalValue is num ? ticketTotalValue.toDouble() : 0);

      final discountType = _normalizeDiscountType(product["discount_type"]);

      if (discountType == 'percent') {
        productDiscount = ticketTotal * (productDiscount / 100);
      }

      discountSum += productDiscount;
    }

    return discountSum;
  }

  double calculateDiscountTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    discount = double.tryParse(bloc.discountOverAllController.text) ?? 0.0;

    if (selectedOverallDiscountType == 'percent') {
      discount = total * (discount / 100);
    }
    return discount;
  }

  double calculateVatTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    vat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;

    if (selectedOverallVatType == 'percent') {
      vat = total * (vat / 100);
    }
    return vat;
  }

  double calculateServiceChargeTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    serviceCharge =
        double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;

    if (selectedOverallServiceChargeType == 'percent') {
      serviceCharge = total * (serviceCharge / 100);
    }
    return serviceCharge;
  }

  double calculateDeliveryTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    deliveryCharge =
        double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;

    if (selectedOverallDeliveryType == 'percent') {
      deliveryCharge = total * (deliveryCharge / 100);
    }
    return deliveryCharge;
  }

  void updateTotal(int index) {
    // Defensive checks for controllers and product map
    if (controllers[index] == null || products[index].isEmpty) {
      return;
    }

    final priceText = controllers[index]?["price"]?.text ?? "0";
    final quantityText = controllers[index]?["quantity"]?.text ?? "0";
    final discountText = controllers[index]?["discount"]?.text ?? "0";

    final discountType = _normalizeDiscountType(products[index]["discount_type"]);

    final price = double.tryParse(priceText) ?? 0;
    final quantity = int.tryParse(quantityText) ?? 0;
    final discountValue = double.tryParse(discountText) ?? 0;

    // Calculate ticket total (price * quantity)
    double ticketTotal = price * quantity;
    controllers[index]?["ticket_total"]?.text = ticketTotal.toStringAsFixed(2);
    products[index]["ticket_total"] = ticketTotal;

    // Calculate discount amount
    double discountAmount = 0;
    if (discountType == 'fixed') {
      discountAmount = discountValue;
    } else if (discountType == 'percent') {
      discountAmount = ticketTotal * (discountValue / 100);
    }

    // Calculate final total (ticket total - discount)
    double finalTotal = ticketTotal - discountAmount;
    finalTotal = finalTotal < 0 ? 0.0 : finalTotal;

    controllers[index]?["total"]?.text = finalTotal.toStringAsFixed(2);
    products[index]["total"] = finalTotal;

    setState(() {});
  }

  double calculateAllFinalTotal() {
    double subtotal = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    // Apply overall discount
    double overallDiscount =
        double.tryParse(bloc.discountOverAllController.text) ?? 0.0;
    if (selectedOverallDiscountType == 'percent') {
      overallDiscount = subtotal * (overallDiscount / 100);
    }
    double totalAfterDiscount = subtotal - overallDiscount;

    // Apply other charges on subtotal
    double overallVat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;
    if (selectedOverallVatType == 'percent') {
      overallVat = subtotal * (overallVat / 100);
    }

    double overallServiceCharge =
        double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;
    if (selectedOverallServiceChargeType == 'percent') {
      overallServiceCharge = subtotal * (overallServiceCharge / 100);
    }

    double overallDeliveryCharge =
        double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;
    if (selectedOverallDeliveryType == 'percent') {
      overallDeliveryCharge = subtotal * (overallDeliveryCharge / 100);
    }

    // Calculate final total
    double finalTotal =
        totalAfterDiscount +
            overallVat +
            overallServiceCharge +
            overallDeliveryCharge;

    return finalTotal;
  }

  void onProductChanged(int index, ProductModelStockModel? newVal) {
    if (newVal == null) return;

    // 🔴 Check if product already exists (except current index)
    final alreadyAdded = products.asMap().entries.any((entry) {
      return entry.key != index && entry.value["product_id"] == newVal.id;
    });

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

    final totalStock = newVal.stockQty ?? 0;

    if (totalStock <= 0) {
      showCustomToast(
        context: context,
        title: 'Alert!',
        description: "Product stock not available",
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    // ✅ Set product data
    products[index]["product"] = newVal;
    products[index]["product_id"] = newVal.id;

    // Ensure controllers index exists before assigning (defensive)
    if (controllers[index] != null) {
      final sellingPrice = newVal.sellingPrice ?? 0.0;
      controllers[index]!["price"]!.text = sellingPrice.toStringAsFixed(2);
    } else {
      // fallback assignment into product map
      products[index]["price"] = newVal.sellingPrice ?? 0.0;
    }

    // Normalize incoming discount type to internal keys ('percent'|'fixed')
    products[index]["discount_type"] = _normalizeDiscountType(newVal.discountType);

    // Use discountValue if present, convert to double
    products[index]["discount"] = newVal.discountValue ?? 0.0;
    products[index]["discountApplied"] = newVal.discountApplied;

    // If controller exists, set discount field for display
    if (controllers[index] != null) {
      controllers[index]!["discount"]!.text = newVal.discountApplied == true
          ? (newVal.discountValue?.toString() ?? "0")
          : "0";
    }

    // If price not set in map, set it
    products[index]["price"] = newVal.sellingPrice ?? 0.0;

    updateTotal(index);
  }

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final isSmallScreen = Responsive.isSmallDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (!isSmallScreen)
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
          sm: 11,
          md: 11,
          lg: 10,
          xl: 10,
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
            context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 2));
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
          final selectedCustomer = bloc.selectClintModel;
          final isWalkInCustomer = selectedCustomer?.id == -1;
          return Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // প্রতিটা অংশ আলাদা card এ — POS screen এর সাথে মিল রেখে
                _card(child: _buildTopFormSection(bloc)),
                _card(title: 'Items', child: _buildProductListSection(bloc)),
                _card(title: 'Adjustments', child: _buildChargesSection(bloc)),
                _card(
                  title: 'Summary & Payment',
                  child: _buildSummarySection(bloc, isWalkInCustomer),
                ),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card({String? title, required Widget child}) {
    final border = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : AppColors.borderLight;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildTopFormSection(CreatePosSaleBloc bloc) {
    final user = context.read<ProfileBloc>().permissionModel?.data?.user;
    final isAdmin = user?.role == "SUPER_ADMIN" || user?.role == "ADMIN";
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRow(
            spacing: 6,
            runSpacing: 6,
            children: [
              ResponsiveCol(
                xs: 12,
                sm: 6,
                md: 3,
                lg: 3,
                xl: 3,
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
                      itemList: [
                        CustomerActiveModel(
                          name: 'Walk-in-customer',
                          id: -1,
                        ),
                      ] +
                          context.read<CustomerBloc>().activeCustomer,
                      onChanged: (newVal) {
                        bloc.selectClintModel = newVal;
                        bloc.customType = (newVal?.id == -1)
                            ? "Walking Customer"
                            : "Saved Customer";
                        if (newVal?.id == -1) {
                          _isChecked = true;
                        }
                        setState(() {});
                      },
                      validator: (value) =>
                      value == null ? 'Please select Customer' : null,
                    );
                  },
                ),
              ),
              if (isAdmin)
                ResponsiveCol(
                  xs: 12,
                  sm: 6,
                  md: 3,
                  lg: 3,
                  xl: 3,
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return AppDropdown(
                        label: "Sales By",
                        hint:
                        bloc.selectSalesModel?.username ?? "Select Sales",
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
                        value == null ? 'Please select Sales' : null,
                      );
                    },
                  ),
                ),
              ResponsiveCol(
                xs: 12,
                sm: 6,
                md: 2,
                lg: 2,
                xl: 2,
                child: CustomInputField(
                  isRequired: true,
                  readOnly: true,
                  isRequiredLable: true,
                  labelText: 'Sale Date',
                  controller: bloc.dateEditingController,
                  hintText: 'Sale Date',
                  keyboardType: TextInputType.datetime,
                  autofillHints: AutofillHints.name,
                  fillColor: AppColors.whiteColor(context),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter date' : null,
                  onTap: _selectDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductListSection(CreatePosSaleBloc bloc) {
    return Column(
      children: products.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;

        final discountApplied = product["discountApplied"] == true;

        // Ensure discount_type fallback and safety for segmented control
        final discountTypeSafe = _normalizeDiscountType(product["discount_type"]);

        return Container(
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ResponsiveRow(
            spacing: 4,
            runSpacing: 0,
            children: [
              // ================= CATEGORY =================
              ResponsiveCol(
                xs: 12,
                sm: 2,
                md: 2,
                lg: 2,
                xl: 2,
                child: BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    final selectedCategory = categoriesBloc.selectedState;
                    final categoryList = categoriesBloc.list;

                    return AppDropdown(
                      label: "Category",
                      hint:  "Select Category"
                          ,
                      isRequired: false,
                      isNeedAll: true,
                      isLabel: false,
                      isSearch: true,
                      value: selectedCategory.isEmpty ? null : selectedCategory,
                      itemList: categoryList.map((e) => e.name ?? "").toList(),
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

                          // 🔴 Reset product when category changes
                          product["product"] = null;
                          product["product_id"] = null;
                          controllers[index]!["price"]!.text = "0";
                          controllers[index]!["quantity"]!.text = "1";
                          controllers[index]!["discount"]!.text = "0";
                          updateTotal(index);
                        });
                      },
                    );
                  },
                ),
              ),

              // ================= PRODUCT =================
              ResponsiveCol(
                xs: 12,
                sm: 2.5,
                md: 2.5,
                lg: 2.5,
                xl: 2.5,
                child: BlocBuilder<ProductsBloc, ProductsState>(
                  builder: (context, state) {
                    final selectedCategoryId = categoriesBloc.selectedStateId;

                    // selected product ids (duplicate prevention)
                    final selectedProductIds = products
                        .where((p) => p["product_id"] != null)
                        .map<int>((p) => p["product_id"])
                        .toList();

                    // 🔥 CATEGORY + DUPLICATE FILTER
                    final filteredProducts = context
                        .read<ProductsBloc>()
                        .productList
                        .where((item) {
                      final categoryMatch = selectedCategoryId.isEmpty
                          ? true
                          : item.id.toString() == selectedCategoryId;

                      final notDuplicate =
                          !selectedProductIds.contains(item.id) ||
                              item.id == product["product_id"];

                      return categoryMatch && notDuplicate;
                    }).toList();

                    return AppDropdown<ProductModelStockModel>(
                      isRequired: false,
                      isLabel: false,
                      isSearch: true,
                      label: "Product",
                      hint: selectedCategoryId.isEmpty
                          ? "Select Category First"
                          : "Select Product",
                      value: product["product"],
                      itemList: filteredProducts,
                      onChanged: (newVal) => onProductChanged(index, newVal),
                      validator: (value) =>
                      value == null ? 'Please select Product' : null,
                    );
                  },
                ),
              ),

              // Price
              ResponsiveCol(
                xs: 12,
                sm: 1,
                md: 1,
                lg: 1,
                xl: 1,
                child: TextFormField(
                  style: AppTextStyle.cardLevelText(context),
                  controller: controllers[index]?["price"],
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  decoration: InputDecoration(
                    label: Text(
                      "Price",
                      style: AppTextStyle.cardLevelText(context),
                    ),
                    fillColor: AppColors.whiteColor(context),
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor(context).withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor(context).withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.only(
                      top: 13.0,
                      bottom: 13.0,
                      left: 12,
                    ),
                    isDense: true,
                    hintText: "price",
                  ),
                ),
              ),

              // Discount type
              ResponsiveCol(
                xs: 12,
                sm: 1,
                md: 1,
                lg: 1,
                xl: 1,
                child: AbsorbPointer(
                  absorbing: discountApplied,
                  child: CupertinoSegmentedControl<String>(
                    padding: EdgeInsets.zero,
                    children: {
                      'fixed': Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                          vertical: 7,
                        ),
                        child: Text(
                          'TK',
                          style: TextStyle(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            color: discountTypeSafe == 'fixed' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      'percent': Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                          vertical: 7,
                        ),
                        child: Text(
                          '%',
                          style: TextStyle(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            color: discountTypeSafe == 'percent' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: discountApplied
                        ? (_) {}
                        : (value) {
                      // Update product discount type and recalc totals
                      setState(() {
                        product["discount_type"] = value; // 'fixed' | 'percent'
                        updateTotal(index);
                      });
                    },
                    groupValue: discountTypeSafe,
                    unselectedColor: Colors.grey[300],
                    selectedColor: AppColors.primaryColor(context),
                    borderColor: AppColors.primaryColor(context),
                  ),
                ),
              ),

              // Discount input
              ResponsiveCol(
                xs: 12,
                sm: 0.7,
                md: 0.7,
                lg: 0.7,
                xl: 0.7,
                child: TextFormField(
                  controller: controllers[index]?["discount"],
                  style: AppTextStyle.cardLevelText(context),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  readOnly: true,
                  decoration: InputDecoration(
                    fillColor: AppColors.whiteColor(context),
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.only(
                      top: 13.0,
                      bottom: 13.0,
                      left: 10,
                    ),
                    isDense: true,
                    hintText: "Discount",
                  ),
                  onChanged: discountApplied
                      ? null
                      : (value) {
                    products[index]["discount"] = double.tryParse(value) ?? 0.0;
                    updateTotal(index);
                  },
                ),
              ),

              // Quantity controls
              ResponsiveCol(
                xs: 12,
                sm: 1,
                md: 1.2,
                lg: 1.2,
                xl: 1.2,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int? currentQuantity = int.tryParse(
                          controllers[index]?["quantity"]?.text ?? "0",
                        );
                        if (currentQuantity != null && currentQuantity > 1) {
                          controllers[index]!["quantity"]!.text =
                              (currentQuantity - 1).toString();
                          products[index]["quantity"] =
                              controllers[index]!["quantity"]!.text;
                          updateTotal(index);
                        }
                      },
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      controllers[index]!["quantity"]!.text,
                      style: AppTextStyle.cardTitle(context),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int currentQuantity = int.tryParse(
                          controllers[index]!["quantity"]!.text,
                        ) ??
                            0;
                        controllers[index]!["quantity"]!.text =
                            (currentQuantity + 1).toString();
                        products[index]["quantity"] =
                            controllers[index]!["quantity"]!.text;
                        updateTotal(index);
                      },
                    ),
                  ],
                ),
              ),

              // Ticket total (Before discount)
              ResponsiveCol(
                xs: 12,
                sm: 1,
                md: 1,
                lg: 1,
                xl: 1,
                child: TextFormField(
                  style: AppTextStyle.cardLevelText(context),
                  controller: controllers[index]?["ticket_total"],
                  readOnly: true,
                  decoration: InputDecoration(
                    label: Text(
                      "Ticket Total",
                      style: AppTextStyle.cardLevelText(context),
                    ),
                    fillColor: AppColors.whiteColor(context),
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.only(
                      top: 13.0,
                      bottom: 13.0,
                      left: 12,
                    ),
                    isDense: true,
                    hintText: "ticket total",
                  ),
                ),
              ),

              // Final total (After discount)
              ResponsiveCol(
                xs: 12,
                sm: 1,
                md: 1,
                lg: 1,
                xl: 1,
                child: TextFormField(
                  style: AppTextStyle.cardLevelText(context),
                  controller: controllers[index]?["total"],
                  readOnly: true,
                  decoration: InputDecoration(
                    label: Text(
                      "Final Total",
                      style: AppTextStyle.cardLevelText(context),
                    ),
                    fillColor: AppColors.whiteColor(context),
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.only(
                      top: 13.0,
                      bottom: 13.0,
                      left: 12,
                    ),
                    isDense: true,
                    hintText: "final total",
                  ),
                ),
              ),

              // Add/Remove button
              ResponsiveCol(
                xs: 12,
                sm: 1,
                md: 0.5,
                lg: 0.5,
                xl: 0.5,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    product == products[products.length - 1] ? Icons.add : Icons.remove,
                    color: products.length == 1 ? AppColors.success : AppColors.danger,
                  ),
                  onPressed: () {
                    if (product == products[products.length - 1]) {
                      addProduct();
                    } else {
                      removeProduct(index);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChargesSection(CreatePosSaleBloc bloc) {
    return ResponsiveRow(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildChargeField(
          "Overall Discount",
          selectedOverallDiscountType,
          bloc.discountOverAllController,
              (value) {
            setState(() {
              selectedOverallDiscountType = value;
              bloc.selectedOverallDiscountType = value;
            });
            _updateChangeAmount();
          },
        ),
        _buildChargeField(
          "Overall Vat",
          selectedOverallVatType,
          bloc.vatOverAllController,
              (value) {
            setState(() {
              selectedOverallVatType = value;
              bloc.selectedOverallVatType = value;
            });
            _updateChangeAmount();
          },
        ),
        _buildChargeField(
          "Service Charge",
          selectedOverallServiceChargeType,
          bloc.serviceChargeOverAllController,
              (value) {
            setState(() {
              selectedOverallServiceChargeType = value;
              bloc.selectedOverallServiceChargeType = value;
            });
            _updateChangeAmount();
          },
        ),
        _buildChargeField(
          "Delivery Charge",
          selectedOverallDeliveryType,
          bloc.deliveryChargeOverAllController,
              (value) {
            setState(() {
              selectedOverallDeliveryType = value;
              bloc.selectedOverallDeliveryType = value;
            });
            _updateChangeAmount();
          },
        ),
      ],
    );
  }

  Widget _buildChargeField(
      String label,
      String selectedType,
      TextEditingController controller,
      Function(String) onTypeChanged,
      ) {
    return ResponsiveCol(
      xs: 12,
      sm:  2.5,
      md: 2.5,
      lg: 2.5,
      xl: 2.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.cardLevelText(context)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: CupertinoSegmentedControl<String>(
                  padding: EdgeInsets.zero,
                  children: {
                    'fixed': Text(
                      'TK',
                      style: TextStyle(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        color: selectedType == 'fixed' ? Colors.white : Colors.black,
                      ),
                    ),
                    'percent': Text(
                      '%',
                      style: TextStyle(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        color: selectedType == 'percent' ? Colors.white : Colors.black,
                      ),
                    ),
                  },
                  onValueChanged: onTypeChanged,
                  groupValue: selectedType,
                  unselectedColor: Colors.grey[300],
                  selectedColor: AppColors.primaryColor(context),
                  borderColor: AppColors.primaryColor(context),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 125,
                child: CustomInputFieldPayRoll(
                  isRequiredLevle: false,
                  controller: controller,
                  hintText: label,
                  fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  // ঋণাত্মক নয়, % হলে ১০০ এর বেশি নয়
                  validator: AppValidators.number(
                    label,
                    max: selectedType == 'percent' ? 100 : null,
                  ),
                  onChanged: (value) {
                    _updateChangeAmount();
                    setState(() {});
                  },
                  autofillHints: '',
                  levelText: '',
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
    final specificDiscount = calculateSpecificDiscountTotal();
    final subTotal = calculateTotalForAllProducts();
    final netTotal = calculateAllFinalTotal();

    return ResponsiveRow(
      spacing: 20,
      runSpacing: 10,
      children: [
        ResponsiveCol(
          xs: 12,
          sm: 5,
          md: 5,
          lg: 5,
          xl: 5,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: [
                _buildSummaryRow("Product Total", productTotal),
                _buildSummaryRow("Specific Discount (-)", specificDiscount),
                _buildSummaryRow("Sub Total", subTotal),
                _buildSummaryRow("Discount (-)", discount),
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
          child: _buildPaymentSection(bloc, isWalkInCustomer, netTotal),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(CreatePosSaleBloc bloc,

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
        const SizedBox(height: 10),
        CheckboxListTile(
          title: Text(
            "With Money Receipt",
            style: AppTextStyle.headerTitle(context),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppDropdown(
                  label: "Payment Method",
                  hint: bloc.selectedPaymentMethod.isEmpty
                      ? "Select Payment Method"
                      : bloc.selectedPaymentMethod,
                  isLabel: false,
                  isRequired: true,
                  isNeedAll: false,
                  value: bloc.selectedPaymentMethod.isEmpty ? null : bloc.selectedPaymentMethod,
                  itemList: [] + bloc.paymentMethod,
                  onChanged: (newVal) {
                    bloc.selectedPaymentMethod = newVal.toString();
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
                      final filteredList = bloc.selectedPaymentMethod.isNotEmpty
                          ? state.list.where((item) {
                        return item.acType?.toLowerCase() ==
                            bloc.selectedPaymentMethod.toLowerCase();
                      }).toList()
                          : state.list;

                      final selectedAccount =
                          bloc.accountModel ?? (filteredList.isNotEmpty ? filteredList.first : null);
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
          gapH8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CustomInputField(
                  // isRequiredLable: false,
                  controller: changeAmountController,
                  hintText: 'Change Amount',
                  // fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child:     CustomInputField(
                  controller: bloc.payableAmount,
                  hintText: isWalkInCustomer
                      ? 'Payable Amount (${netTotal.toStringAsFixed(2)})'
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
                // child: CustomInputField(
                //   // isRequiredLable: false,
                //   controller: bloc.payableAmount,
                //   hintText: 'Payable Amount',
                //   // fillColor: Colors.white,
                //   keyboardType: const TextInputType.numberWithOptions(
                //     decimal: true,
                //   ),
                //   validator: (value) => value!.isEmpty ? 'Please enter Payable Amount' : null,
                //   onChanged: (value) {
                //     _updateChangeAmount();
                //     setState(() {});
                //   },
                // ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isBold
                  ? AppTextStyle.cardLevelHead(
                context,
              ).copyWith(fontWeight: FontWeight.bold)
                  : AppTextStyle.cardLevelHead(context),
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: isBold
                ? AppTextStyle.cardLevelText(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor(context),
            )
                : AppTextStyle.cardLevelText(context),
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
          // আগে Preview বাটন কিছুই করত না — এখন sale এর সারাংশ popover এ
          PopoverButton(label: 'Preview', onPressed: _showPreview),
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

  List<int> get _filledRows => [
        for (int i = 0; i < products.length; i++)
          if (products[i]["product_id"] != null) i,
      ];

  void _showPreview() {
    final bloc = context.read<CreatePosSaleBloc>();
    final rows = _filledRows;
    showAppPopover<void>(
      context: context,
      mode: PopoverAnchorMode.aligned,
      builder: (ctx) => AppPopoverCard(
        width: 500,
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
            if (rows.isEmpty) const Text('No items added.'),
            for (final i in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (products[i]["product"] is ProductModelStockModel)
                            ? (products[i]["product"] as ProductModelStockModel)
                                    .name ??
                                '-'
                            : '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${products[i]["quantity"]} × ${products[i]["price"]}',
                        style: const TextStyle(fontSize: 12.5)),
                  ],
                ),
              ),
            const Divider(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text('Net Total',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text(
                  '৳ ${calculateAllFinalTotal().toStringAsFixed(2)}',
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
          PopoverButton(label: 'Close', onPressed: () => Navigator.of(ctx).pop()),
          PopoverButton(
            label: 'Submit Sale',
            primary: true,
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

  /// Submit এর আগে item যাচাই — প্রথম সমস্যাটা জানিয়ে false ফেরত দেয়
  bool _validateSaleItems() {
    final rows = _filledRows;
    String? problem;
    if (rows.isEmpty) {
      problem = 'Add at least one product before submitting.';
    } else {
      for (int n = 0; n < rows.length && problem == null; n++) {
        final row = products[rows[n]];
        final qty = double.tryParse(row["quantity"].toString()) ?? 0;
        final price = double.tryParse(row["price"].toString()) ?? 0;
        final disc = double.tryParse(row["discount"].toString()) ?? 0;
        final p = row["product"];
        final stock = (p is ProductModelStockModel && p.stockQty != null)
            ? p.stockQty!.toDouble()
            : double.infinity;
        final isPercent =
            _normalizeDiscountType(row["discount_type"]) == 'percent';
        if (qty <= 0) {
          problem = 'Item ${n + 1}: quantity must be at least 1';
        } else if (qty > stock) {
          problem =
              'Item ${n + 1}: only ${stock.toStringAsFixed(0)} in stock';
        } else if (price <= 0) {
          problem = 'Item ${n + 1}: price is zero';
        } else if (disc < 0 || (isPercent && disc > 100)) {
          problem = 'Item ${n + 1}: invalid discount';
        } else if (!isPercent && disc > price * qty) {
          problem = 'Item ${n + 1}: discount is more than the item total';
        }
      }
    }
    if (problem != null) {
      showCustomToast(
        context: context,
        title: 'Check items',
        description: problem,
        icon: Icons.error_outline,
        primaryColor: AppColors.danger,
      );
      return false;
    }
    return true;
  }

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

  void _submitForm() {
    if (formKey.currentState!.validate() && _validateSaleItems()) {
      final bloc = context.read<CreatePosSaleBloc>();

      // খালি row (product বাছা হয়নি) server এ পাঠানো হয় না
      var transferProducts = products
          .where((product) => product["product_id"] != null)
          .map((product) {
        // convert internal discount_type ('percent'|'fixed') to backend expected value ('percentage' or 'fixed')
        final internalType = _normalizeDiscountType(product["discount_type"]);
        final backendType = internalType == 'percent' ? 'percentage' : 'fixed';

        return {
          "product_id": int.tryParse(product["product_id"].toString()),
          "quantity": double.tryParse(product["quantity"].toString()) ?? 0, // FIX: 1.5 kg এর মতো দশমিক পরিমাণ
          "unit_price": double.tryParse(product["price"].toString()),
          "discount": double.tryParse(product["discount"].toString()),
          "discount_type": backendType,
        };
      }).toList();

      final selectedCustomer = bloc.selectClintModel;
      final isWalkInCustomer = selectedCustomer?.id == -1;
      final user = context.read<ProfileBloc>().permissionModel?.data?.user;
      final isAdmin = user?.role == "SUPER_ADMIN" || user?.role == "ADMIN";
      Map<String, dynamic> body = {
        "type": "normal_sale",
        "sale_date": appWidgets.convertDateTime(
          DateFormat(
            "dd-MM-yyyy",
          ).parse(bloc.dateEditingController.text.trim(), true),
          "yyyy-MM-dd",
        ),
        "sale_by": (isAdmin)
            ? bloc.selectSalesModel?.id?.toString() ?? ''
            : user?.id?.toString() ?? '',
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
        "paid_amount": double.tryParse(bloc.payableAmount.text.trim()) ?? 0,
      };

      if (isWalkInCustomer) {
        body.remove('customer_id');
      } else {
        body['customer_id'] = selectedCustomer?.id.toString() ?? '';
      }

      if (isWalkInCustomer) {
        final netTotal = calculateAllFinalTotal();
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
  }
}