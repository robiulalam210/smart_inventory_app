import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

class MobileCreatePosSale extends StatefulWidget {
  const MobileCreatePosSale({super.key});

  @override
  _CreatePosSalePageState createState() => _CreatePosSalePageState();
}

class _CreatePosSalePageState extends State<MobileCreatePosSale> {
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
    final changeAmount = calculateAllFinalTotal() - payableAmount;

    setState(() {
      changeAmountController.text = changeAmount.toStringAsFixed(2);
    });
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
      totalSum += (product["total"] ?? 0).toDouble();
    }
    return totalSum;
  }

  double calculateTotalTicketForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      totalSum += (product["ticket_total"] ?? 0).toDouble();
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

      if (product["discount_type"] == 'percent') {
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
    if (controllers[index] == null || products[index].isEmpty) {
      return;
    }

    final priceText = controllers[index]?["price"]?.text ?? "0";
    final quantityText = controllers[index]?["quantity"]?.text ?? "0";
    final discountText = controllers[index]?["discount"]?.text ?? "0";
    final discountType = products[index]["discount_type"] as String? ?? "fixed";

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
        primaryColor: Colors.orange,
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
    products[index]["price"] = newVal.sellingPrice;
    products[index]["discount"] = newVal.discountValue;
    products[index]["discount_type"] = newVal.discountType ?? "fixed";
    products[index]["discountApplied"] = newVal.discountApplied;

    controllers[index]!["price"]!.text = newVal.sellingPrice.toString();

    // ✅ Discount handling
    controllers[index]!["discount"]!.text = newVal.discountApplied == true
        ? newVal.discountValue.toString()
        : "0";

    updateTotal(index);
  }

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) ||
        Responsive.isMaxDesktop(context) ||
        Responsive.isSmallDesktop(context);

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: isBigScreen ? _buildDesktopLayout() : _buildMobileLayout(),
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

  Widget _buildMobileLayout() {
    return Container(child: _buildMobileStepperContent());
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
              primaryColor: Colors.green,
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

          return Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopFormSection(bloc),
                const SizedBox(height: 0),
                _buildProductListSection(bloc),
                const SizedBox(height: 8),
                _buildChargesSection(bloc),
                const SizedBox(height: 8),
                _buildSummarySection(bloc),
                const SizedBox(height: 8),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileStepperContent() {
    return BlocConsumer<CreatePosSaleBloc, CreatePosSaleState>(
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

        return Form(
          key: formKey,
          child: Stepper(
            physics: const ClampingScrollPhysics(), // 👈 important
            type: StepperType.vertical,
            currentStep: currentStep,
            onStepContinue: () {
              if (currentStep < 3) {
                setState(() {
                  currentStep += 1;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  debugPrint("after rebuild currentStep: $currentStep");
                });
              } else {
                // 👇 LAST STEP → SUBMIT
                _submitForm();
              }
            },

            onStepCancel: () {
              if (currentStep > 0) {
                setState(() {
                  currentStep -= 1;
                });
              }
            },
            onStepTapped: (step) {
              setState(() {
                currentStep = step;
              });
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: AppButton(
                          onPressed: details.onStepCancel,
                          name: "Back",
                          color: AppColors.redColor,
                        ),
                      ),
                    if (currentStep > 0) const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        onPressed: details.onStepContinue,
                        name: currentStep < 3 ? 'Next' : 'Submit',
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              // Step 1: Customer Information
              Step(
                title: Text(
                  'Customer Info',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                content: _buildMobileTopFormSection(bloc),
                isActive: currentStep >= 0,
                state: currentStep > 0 ? StepState.complete : StepState.indexed,
              ),

              // Step 2: Products
              Step(
                title: Text(
                  'Products',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                content: _buildMobileProductListSection(bloc),
                isActive: currentStep >= 1,
                state: currentStep > 1 ? StepState.complete : StepState.indexed,
              ),

              // Step 3: Charges
              Step(
                title: Text(
                  'Charges',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                content: _buildMobileChargesSection(bloc),
                isActive: currentStep >= 2,
                state: currentStep > 2 ? StepState.complete : StepState.indexed,
              ),

              // Step 4: Summary & Payment
              Step(
                title: Text(
                  'Summary & Payment',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                content: Column(
                  children: [
                    _buildSummarySection(bloc),
                    const SizedBox(height: 20),

                    // Final submit button
                  ],
                ),
                isActive: currentStep >= 3,
                state: StepState.indexed,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileTopFormSection(CreatePosSaleBloc bloc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            BlocBuilder<CustomerBloc, CustomerState>(
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
            const SizedBox(height: 12),
            BlocBuilder<UserBloc, UserState>(
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
            const SizedBox(height: 12),
            CustomInputField(
              radius: 8,
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
          ],
        ),
      ],
    );
  }

  Widget _buildMobileProductListSection(CreatePosSaleBloc bloc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final discountApplied = product["discountApplied"] == true;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Product ${index + 1}",
                      style: AppTextStyle.cardTitle(context),
                    ),
                    if (index > 0)
                      IconButton(
                        icon: const Icon(
                          HugeIcons.strokeRoundedDelete02,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => removeProduct(index),
                        padding: EdgeInsets.zero,
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          HugeIcons.strokeRoundedAddCircleHalfDot,
                          color: Colors.green,
                        ),
                        onPressed: addProduct,
                      ),

                  ],
                ),
                const SizedBox(height: 6),

                // Category
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    final selectedCategory = categoriesBloc.selectedState;
                    final categoryList = categoriesBloc.list;

                    return AppDropdown(
                      label: "Category",
                      context: context,
                      hint: selectedCategory.isEmpty
                          ? "Select Category"
                          : selectedCategory,
                      isRequired: false,
                      isNeedAll: true,
                      isLabel: true,
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
                          product["product"] = null;
                          product["product_id"] = null;
                          controllers[index]!["price"]!.text = "0";
                          controllers[index]!["quantity"]!.text = "1";
                          controllers[index]!["discount"]!.text = "0";
                          updateTotal(index);
                        });
                      },
                      itemBuilder: (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.toString()),
                      ),
                    );
                  },
                ),

                // Product
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
                              : item.category?.toString() == selectedCategoryId;
                          final notDuplicate =
                              !selectedProductIds.contains(item.id) ||
                              item.id == product["product_id"];
                          return categoryMatch && notDuplicate;
                        })
                        .toList();

                    return AppDropdown<ProductModelStockModel>(
                      context: context,
                      isRequired: false,
                      isLabel: true,
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
                      itemBuilder: (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.toString()),
                      ),
                    );
                  },
                ),

                // Price & Quantity Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Price", style: AppTextStyle.bodySmall(context)),
                          const SizedBox(height: 4),
                          TextFormField(
                            style: AppTextStyle.cardLevelText(context),
                            controller: controllers[index]?["price"],
                            keyboardType: TextInputType.number,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.whiteColor,
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quantity",
                            style: AppTextStyle.bodySmall(context),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () {
                                    int? currentQuantity = int.tryParse(
                                      controllers[index]?["quantity"]?.text ??
                                          "0",
                                    );
                                    if (currentQuantity != null &&
                                        currentQuantity > 1) {
                                      controllers[index]!["quantity"]!.text =
                                          (currentQuantity - 1).toString();
                                      products[index]["quantity"] =
                                          controllers[index]!["quantity"]!.text;
                                      updateTotal(index);
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    controllers[index]!["quantity"]!.text,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.cardTitle(context),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () {
                                    int currentQuantity =
                                        int.tryParse(
                                          controllers[index]!["quantity"]!.text,
                                        ) ??
                                        0;
                                    controllers[index]!["quantity"]!.text =
                                        (currentQuantity + 1).toString();
                                    products[index]["quantity"] =
                                        controllers[index]!["quantity"]!.text;
                                    updateTotal(index);
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Discount Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Discount", style: AppTextStyle.bodySmall(context)),
                    const SizedBox(height: 4),
                    Row(                  crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: discountApplied,
                            child: CupertinoSegmentedControl<String>(
                              padding: EdgeInsets.zero,
                              children: {
                                'fixed': Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'TK',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: GoogleFonts.playfairDisplay()
                                          .fontFamily,
                                      color: product["discount_type"] == 'fixed'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                'percent': Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: GoogleFonts.playfairDisplay()
                                          .fontFamily,
                                      color:
                                          product["discount_type"] == 'percent'
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
                              unselectedColor: Colors.grey[300],
                              selectedColor: AppColors.primaryColor,
                              borderColor: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: controllers[index]?["discount"],
                            style: AppTextStyle.cardLevelText(context),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            readOnly: discountApplied,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.whiteColor,
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ),
                            onChanged: discountApplied
                                ? null
                                : (value) {
                                    products[index]["discount"] =
                                        double.tryParse(value) ?? 0.0;
                                    updateTotal(index);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMobileChargesSection(CreatePosSaleBloc bloc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Additional Charges", style: AppTextStyle.cardLevelHead(context)),
        const SizedBox(height: 12),
        _buildChargesSection(bloc),
      ],
    );
  }

  Widget _buildTopFormSection(CreatePosSaleBloc bloc) {
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
                      context: context,
                      label: "Customer",
                      hint: bloc.selectClintModel?.name ?? "Select Customer",
                      isSearch: true,
                      isNeedAll: false,
                      isRequired: true,
                      value: bloc.selectClintModel,
                      itemList:
                          [
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
              ResponsiveCol(
                xs: 12,
                sm: 6,
                md: 3,
                lg: 3,
                xl: 3,
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
              ResponsiveCol(
                xs: 12,
                sm: 6,
                md: 2,
                lg: 2,
                xl: 2,
                child: CustomInputField(
                  radius: 8,
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
      ),
    );
  }

  Widget _buildProductListSection(CreatePosSaleBloc bloc) {
    return Column(
      children: products.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;

        final discountApplied = product["discountApplied"] == true;

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
                      context: context,
                      hint: selectedCategory.isEmpty
                          ? "Select Category"
                          : selectedCategory,
                      isRequired: false,
                      isNeedAll: true,
                      isLabel: true,
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
                      // validator: (value) =>
                      // value == null ? 'Please select Category' : null,
                      itemBuilder: (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.toString()),
                      ),
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
                        })
                        .toList();

                    return AppDropdown<ProductModelStockModel>(
                      context: context,
                      isRequired: false,
                      isLabel: true,
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
                      itemBuilder: (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.toString()),
                      ),
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
                    fillColor: AppColors.whiteColor,
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.5),
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
                            fontFamily:
                                GoogleFonts.playfairDisplay().fontFamily,
                            color: product["discount_type"] == 'fixed'
                                ? Colors.white
                                : Colors.black,
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
                            fontFamily:
                                GoogleFonts.playfairDisplay().fontFamily,
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
                              // product["discount_type"] = value;
                              // updateTotal(index);
                            });
                          },
                    groupValue: product["discount_type"],
                    unselectedColor: Colors.grey[300],
                    selectedColor: AppColors.primaryColor,
                    borderColor: AppColors.primaryColor,
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
                    fillColor: AppColors.whiteColor,
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
                          products[index]["discount"] =
                              double.tryParse(value) ?? 0.0;
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
                        int currentQuantity =
                            int.tryParse(
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
                    fillColor: AppColors.whiteColor,
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
                    fillColor: AppColors.whiteColor,
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
                    product == products[products.length - 1]
                        ? Icons.add
                        : Icons.remove,
                    color: products.length == 1 ? Colors.green : Colors.red,
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
      sm: 2,
      md: 2,
      lg: 2,
      xl: 2,
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
                        color: selectedType == 'fixed'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    'percent': Text(
                      '%',
                      style: TextStyle(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        color: selectedType == 'percent'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  },
                  onValueChanged: onTypeChanged,
                  groupValue: selectedType,
                  unselectedColor: Colors.grey[300],
                  selectedColor: AppColors.primaryColor,
                  borderColor: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 110,
                child: CustomInputFieldPayRoll(
                  isRequiredLevle: false,
                  controller: controller,
                  hintText: label,
                  fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
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

  Widget _buildSummarySection(CreatePosSaleBloc bloc) {
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
          child: _buildPaymentSection(bloc),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(CreatePosSaleBloc bloc) {
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
                  itemBuilder: (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item.toString()),
                  ),
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
                          bloc.accountModel ??
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
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
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
                child: AppTextField(
                  // isRequiredLable: false,
                  controller: bloc.payableAmount,
                  hintText: 'Payable Amount',
                  // fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter Payable Amount' : null,
                  onChanged: (value) {
                    _updateChangeAmount();
                    setState(() {});
                  },
                ),
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
                    color: AppColors.primaryColor,
                  )
                : AppTextStyle.cardLevelText(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: () async {
              // Preview functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff800000),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Preview', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
    if (formKey.currentState!.validate()) {
      final bloc = context.read<CreatePosSaleBloc>();

      var transferProducts = products
          .map(
            (product) => {
              "product_id": int.tryParse(product["product_id"].toString()),
              "quantity": int.tryParse(product["quantity"].toString()),
              "unit_price": double.tryParse(product["price"].toString()),
              "discount": double.tryParse(product["discount"].toString()),
              "discount_type": product["discount_type"].toString(),
            },
          )
          .toList();

      final selectedCustomer = bloc.selectClintModel;
      final isWalkInCustomer = selectedCustomer?.id == -1;

      Map<String, dynamic> body = {
        "type": "normal_sale",
        "sale_date": appWidgets.convertDateTime(
          DateFormat(
            "dd-MM-yyyy",
          ).parse(bloc.dateEditingController.text.trim(), true),
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
            description:
                "Walk-in customer: Full payment required. No due allowed.",
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
  }
}
