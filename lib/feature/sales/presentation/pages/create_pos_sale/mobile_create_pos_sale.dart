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

class MobileCreatePosSale extends StatefulWidget {
  const MobileCreatePosSale({super.key});

  @override
  _CreatePosSalePageState createState() => _CreatePosSalePageState();
}

class _CreatePosSalePageState extends State<MobileCreatePosSale> {
  // Separate form keys for each step
  final GlobalKey<FormState> _formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep4 = GlobalKey<FormState>();

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

  // Track validation state for each step

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
    final netTotal = calculateAllFinalTotal();
    final changeAmount = payableAmount - netTotal;

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
      final totalValue = product["total"] ?? 0;

      // Convert to double safely
      if (totalValue is int) {
        totalSum += totalValue.toDouble();
      } else if (totalValue is String) {
        totalSum += double.tryParse(totalValue) ?? 0;
      } else if (totalValue is double) {
        totalSum += totalValue;
      }
    }
    return totalSum;
  }

  double calculateTotalTicketForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      final ticketTotalValue = product["ticket_total"] ?? 0;

      // Convert to double safely
      if (ticketTotalValue is int) {
        totalSum += ticketTotalValue.toDouble();
      } else if (ticketTotalValue is String) {
        totalSum += double.tryParse(ticketTotalValue) ?? 0;
      } else if (ticketTotalValue is double) {
        totalSum += ticketTotalValue;
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

      final discountValue = product["discount_value"] ?? 0;
      final ticketTotalValue = product["ticket_total"] ?? 0;

      // Convert both to double safely - handle int, string, and double
      if (discountValue is int) {
        productDiscount = discountValue.toDouble();
      } else if (discountValue is String) {
        productDiscount = double.tryParse(discountValue) ?? 0;
      } else if (discountValue is double) {
        productDiscount = discountValue;
      } else {
        productDiscount = 0;
      }

      if (ticketTotalValue is int) {
        ticketTotal = ticketTotalValue.toDouble();
      } else if (ticketTotalValue is String) {
        ticketTotal = double.tryParse(ticketTotalValue) ?? 0;
      } else if (ticketTotalValue is double) {
        ticketTotal = ticketTotalValue;
      } else {
        ticketTotal = 0;
      }

      final discountType = product["discount_type"]?.toString() ?? "fixed";

      if (discountType.toLowerCase() == 'percentage' ||
          discountType.toLowerCase() == 'percent') {
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

    final price = double.tryParse(priceText) ?? 0;
    final quantity = int.tryParse(quantityText) ?? 0;

    final productData = products[index];
    final product = productData["product"] as ProductModelStockModel?;

    // 🔴 Stock validation
    if (product != null) {
      final stockQty = product.stockQty ?? 0;
      final openingStock = product.openingStock ?? 0;
      final availableStock = stockQty > 0 ? stockQty : openingStock;

      if (quantity > availableStock) {
        // Reset to maximum available stock
        final maxQuantity = availableStock;
        controllers[index]!["quantity"]!.text = maxQuantity.toString();
        products[index]["quantity"] = maxQuantity.toString();

        showCustomToast(
          context: context,
          title: 'Stock Adjusted!',
          description: "Quantity reduced to available stock: $maxQuantity",
          icon: Icons.info,
          primaryColor: Colors.blue,
        );

        // Continue with adjusted quantity
        return updateTotal(index);
      }
    }

    /// 🔹 Get proper final price PER UNIT
    double finalPricePerUnit = price; // Default to selling price

    // Check if product has auto-discount
    if (product != null) {
      final bool hasAutoDiscount = product.discountApplied == true;

      if (hasAutoDiscount && product.finalPrice != null) {
        // Use backend-calculated final_price per unit
        finalPricePerUnit = product.finalPrice!;
      } else if (product.sellingPrice != null) {
        // Fallback to selling price per unit
        finalPricePerUnit = product.sellingPrice!;
      }
    }

    /// 🔹 Ticket total (without discount) = Original Price * Quantity
    final double ticketTotal = price * quantity;
    controllers[index]?["ticket_total"]?.text = ticketTotal.toStringAsFixed(2);
    products[index]["ticket_total"] = ticketTotal;

    /// 🔹 Final total (with auto-discount if applied) = Final Price Per Unit * Quantity
    final double total = finalPricePerUnit * quantity;

    controllers[index]?["total"]?.text = total.toStringAsFixed(2);
    products[index]["total"] = total;

    /// 🔹 Store auto-discount info for display
    if (product != null && product.discountApplied == true) {
      products[index]["discountApplied"] = true;
      products[index]["discount_type"] = product.discountType ?? "fixed";

      // Ensure discount_value is stored as double
      products[index]["discount_value"] = product.discountValue ?? 0.0;

      // Store final price per unit
      products[index]["final_price"] = finalPricePerUnit;

      // Auto-fill discount display (read-only)
      if (product.discountValue != null) {
        controllers[index]?["discount"]?.text = product.discountValue!
            .toStringAsFixed(2);
      } else {
        controllers[index]?["discount"]?.text = "0";
      }
    } else {
      products[index]["discountApplied"] = false;
      products[index]["discount_type"] = "fixed";
      products[index]["discount_value"] = 0.0;
      products[index]["final_price"] = price;
    }

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

    // 🔴 Prevent duplicate product
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

    // 🔴 Stock check
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
      // ✅ Basic product data
      products[index]["product"] = newVal;
      products[index]["product_id"] = newVal.id;

      // ✅ Set price to selling price - ensure it's not null
      final sellingPrice = newVal.sellingPrice ?? 0.0;
      controllers[index]!["price"]!.text = sellingPrice.toStringAsFixed(2);

      // ✅ Auto-discount handling
      final bool hasAutoDiscount = newVal.discountApplied == true;
      products[index]["discountApplied"] = hasAutoDiscount;

      double finalPricePerUnit = sellingPrice;
      if (hasAutoDiscount && newVal.finalPrice != null) {
        finalPricePerUnit = newVal.finalPrice!;
        products[index]["discount_type"] = newVal.discountType ?? "fixed";
        products[index]["discount_value"] = newVal.discountValue ?? 0.0;
      } else {
        products[index]["discount_type"] = "fixed";
        products[index]["discount_value"] = 0.0;
      }

      products[index]["final_price"] = finalPricePerUnit;

      // ✅ Set initial quantity to 1, but check if stock is available
      int initialQuantity = 1;
      if (availableStock < 1) {
        initialQuantity = 0;
        showCustomToast(
          context: context,
          title: 'Stock Warning!',
          description: "Product has very low stock: $availableStock",
          icon: Icons.warning,
          primaryColor: Colors.orange,
        );
      }

      controllers[index]!["quantity"]!.text = initialQuantity.toString();
      products[index]["quantity"] = initialQuantity.toString();

      // ✅ Calculate initial total
      updateTotal(index);
    });
  }

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBg(context),
        title: Text(
          'Sale',
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(color: AppColors.text(context)),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.bottomNavBg(context),
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
                AppRoutes.pushReplacement(context, MobilePosSaleScreen());
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

              return Stepper(
                physics: const ClampingScrollPhysics(),
                type: StepperType.vertical,
                currentStep: currentStep,

                onStepContinue: () {
                  _validateAndMoveToNextStep();
                },
                onStepCancel: () {
                  if (currentStep > 0) {
                    setState(() {
                      currentStep -= 1;
                    });
                  }
                },
                onStepTapped: (step) {
                  if (step <= currentStep) {
                    setState(() {
                      currentStep = step;
                    });
                  }
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
                              color: AppColors.errorColor(context),
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
                      style: AppTextStyle.cardLevelHead(
                        context,
                      ).copyWith(color: AppColors.text(context)),
                    ),
                    content: _buildMobileTopFormSection(bloc),
                    isActive: currentStep >= 0,
                    state: _getStepState(0),
                  ),

                  // Step 2: Products
                  Step(
                    title: Text(
                      'Products',
                      style: AppTextStyle.cardLevelHead(
                        context,
                      ).copyWith(color: AppColors.text(context)),
                    ),
                    content: _buildMobileProductListSection(bloc),
                    isActive: currentStep >= 1,
                    state: _getStepState(1),
                  ),

                  // Step 3: Charges
                  Step(
                    title: Text(
                      'Charges',
                      style: AppTextStyle.cardLevelHead(
                        context,
                      ).copyWith(color: AppColors.text(context)),
                    ),
                    content: _buildMobileChargesSection(bloc),
                    isActive: currentStep >= 2,
                    state: _getStepState(2),
                  ),

                  // Step 4: Summary & Payment
                  Step(
                    title: Text(
                      'Summary & Payment',
                      style: AppTextStyle.cardLevelHead(
                        context,
                      ).copyWith(color: AppColors.text(context)),
                    ),
                    content: _buildSummarySection(bloc, isWalkInCustomer),
                    isActive: currentStep >= 3,
                    state: _getStepState(3),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  StepState _getStepState(int stepIndex) {
    if (currentStep > stepIndex) {
      return StepState.complete;
    } else if (currentStep == stepIndex) {
      return StepState.indexed;
    } else {
      return StepState.indexed;
    }
  }

  void _validateAndMoveToNextStep() {
    switch (currentStep) {
      case 0:
        _validateStep1();
        break;
      case 1:
        _validateStep2();
        break;
      case 2:
        _validateStep3();
        break;
      case 3:
        _validateStep4();
        break;
    }
  }

  void _validateStep1() {
    // Validate form first
    if (!_formKeyStep1.currentState!.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please fix the errors in Customer Information',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Then validate business logic
    final bloc = context.read<CreatePosSaleBloc>();

    if (bloc.selectClintModel == null) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please select a customer',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }
    final user = context.read<ProfileBloc>().permissionModel?.data?.user;
    final isAdmin = user?.role == "SUPER_ADMIN" || user?.role == "ADMIN";

    if (isAdmin && bloc.selectSalesModel == null) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please select a sales person',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    if (bloc.dateEditingController.text.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please select a sale date',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    setState(() {
      currentStep += 1;
    });
  }

  void _validateStep2() {
    // Create a form state for step 2 validation
    final formState = _formKeyStep2.currentState;
    if (formState != null && !formState.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please fix product selection errors',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Validate at least one product is added
    if (products.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please add at least one product',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Validate each product has quantity > 0
    for (int i = 0; i < products.length; i++) {
      final quantity = int.tryParse(controllers[i]!["quantity"]!.text) ?? 0;
      if (quantity <= 0) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: 'Please enter a valid quantity for item ${i + 1}',
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return;
      }

      // Validate stock availability
      final product = products[i]["product"] as ProductModelStockModel?;
      if (product != null) {
        final stockQty = product.stockQty ?? 0;
        if (quantity > stockQty) {
          showCustomToast(
            context: context,
            title: 'Stock Error',
            description:
                'Insufficient stock for ${product.name}. Available: $stockQty',
            icon: Icons.error,
            primaryColor: Colors.red,
          );
          return;
        }
      }
    }

    setState(() {
      currentStep += 1;
    });
  }

  void _validateStep3() {
    // Validate form first
    if (!_formKeyStep3.currentState!.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please fix the errors in Charges section',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    final bloc = context.read<CreatePosSaleBloc>();

    // Validate numeric fields
    final validationErrors = <String>[];

    final vatValue = double.tryParse(bloc.vatOverAllController.text) ?? 0;
    if (vatValue < 0) validationErrors.add('VAT cannot be negative');

    final discountValue =
        double.tryParse(bloc.discountOverAllController.text) ?? 0;
    if (discountValue < 0) validationErrors.add('Discount cannot be negative');

    final serviceChargeValue =
        double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0;
    if (serviceChargeValue < 0) {
      validationErrors.add('Service charge cannot be negative');
    }

    final deliveryChargeValue =
        double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0;
    if (deliveryChargeValue < 0) {
      validationErrors.add('Delivery charge cannot be negative');
    }

    if (validationErrors.isNotEmpty) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: validationErrors.join('\n'),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    setState(() {
      currentStep += 1;
    });
  }

  void _validateStep4() {
    // First validate the form
    if (!_formKeyStep4.currentState!.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please fix the errors in Summary & Payment',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    // Then validate business logic
    final bloc = context.read<CreatePosSaleBloc>();
    final selectedCustomer = bloc.selectClintModel;
    final isWalkInCustomer = selectedCustomer?.id == -1;
    final netTotal = calculateAllFinalTotal();
    final paidAmount = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;

    // Validate walk-in customer: Must pay exact amount
    if (isWalkInCustomer) {
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
    }

    // Validate saved customer: Paid amount should not be negative
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

    // Validate money receipt section
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
    }

    _submitForm();
  }

  Widget _buildMobileTopFormSection(CreatePosSaleBloc bloc) {
    final user = context.read<ProfileBloc>().permissionModel?.data?.user;
    final isAdmin = user?.role == "SUPER_ADMIN" || user?.role == "ADMIN";
    return Form(
      key: _formKeyStep1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  return AppDropdown<CustomerActiveModel>(
                    label: "Customer",
                    hint: bloc.selectClintModel?.name ?? "Select Customer",
                    isSearch: true,
                    isNeedAll: false,
                    isRequired: true,
                    value: bloc.selectClintModel,
                    itemList:
                        [
                          CustomerActiveModel(name: 'Walk-in-customer', id: -1),
                        ] +
                        context.read<CustomerBloc>().activeCustomer,
                    onChanged: (newVal) {
                      bloc.selectClintModel = newVal;
                      bloc.customType = (newVal?.id == -1)
                          ? "Walking Customer"
                          : "Saved Customer";
                      if (newVal?.id == -1) {
                        _isChecked = true;
                        bloc.isChecked = true;
                        // Auto-set payable amount to net total for walk-in customer
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
              gapH8,
              if (isAdmin)
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return AppDropdown(
                      label: "Sales By",
                      hint: "Select Sales",
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
              CustomInputField(
                isRequired: true,
                readOnly: true,
                controller: bloc.dateEditingController,
                hintText: 'Sale Date',
                keyboardType: TextInputType.datetime,
                autofillHints: AutofillHints.name,
                fillColor: AppColors.whiteColor(context),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter date' : null,
                onTap: _selectDate,
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildMobileProductListSection(CreatePosSaleBloc bloc) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final bool discountApplied = product["discountApplied"] == true;

          // 🔥 SAFELY extract and convert values to double
          final type = product["discount_type"]?.toString() ?? "fixed";
          final value = product["discount_value"] ?? 0;
          final total = product["ticket_total"] ?? 0.0;
// Inside your product container (Auto Discount Section)
          final double finalPricePerUnit = product["final_price"] is String
              ? double.tryParse(product["final_price"]) ?? 0.0
              : product["final_price"] ?? 0.0;

          final int quantity = int.tryParse(
              controllers[index]!["quantity"]!.text) ??
              1;

          final double totalFinalPrice = finalPricePerUnit * quantity;
          // Convert to double safely
          final double doubleValue = value is int
              ? value.toDouble()
              : value is String
              ? double.tryParse(value) ?? 0.0
              : value is double
              ? value
              : 0.0;

          final double doubleTotal = total is int
              ? total.toDouble()
              : total is String
              ? double.tryParse(total) ?? 0.0
              : total is double
              ? total
              : 0.0;

          // Discount calculation
          final double discountAmount =
              type.toLowerCase() == "percentage" ||
                  type.toLowerCase() == "percent"
              ? doubleTotal * (doubleValue / 100)
              : doubleValue;

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Product ${index + 1}",
                      style: AppTextStyle.cardTitle(context),
                    ),
                    IconButton(
                      icon: Icon(
                        index == 0 ? HugeIcons.strokeRoundedAddCircle : HugeIcons.strokeRoundedDelete02,
                        color: index == 0 ? AppColors.primaryColor(context) : AppColors.errorColor(context),
                      ),
                      onPressed: index == 0
                          ? addProduct
                          : () => removeProduct(index),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    final selectedCategory = categoriesBloc.selectedState;
                    final categoryList = categoriesBloc.list;

                    return AppDropdown(
                      label: "Category",
                      hint:  "Select Category"
                          ,
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
                    );
                  },
                ),
                gapH8,

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
                      isRequired: true,
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
                    );
                  },
                ),

                const SizedBox(height: 4),

                /// PRICE + QTY
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(

                        controller: controllers[index]!["price"],
                        readOnly: true,
                        decoration:  InputDecoration(
                          contentPadding: EdgeInsets.zero,


                            labelText: "Original Price"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                int q =
                                    int.tryParse(
                                      controllers[index]!["quantity"]!.text,
                                    ) ??
                                    1;
                                if (q > 1) {
                                  controllers[index]!["quantity"]!.text =
                                      (q - 1).toString();
                                  products[index]["quantity"] = (q - 1)
                                      .toString();
                                  updateTotal(index);
                                }
                              },
                            ),
                            Expanded(
                              child: Text(
                                controllers[index]!["quantity"]!.text,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.cardTitle(context),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                final productData = products[index];
                                final product =
                                    productData["product"]
                                        as ProductModelStockModel?;

                                if (product == null) {
                                  showCustomToast(
                                    context: context,
                                    title: 'Error!',
                                    description:
                                        "Please select a product first",
                                    icon: Icons.error,
                                    primaryColor: Colors.redAccent,
                                  );
                                  return;
                                }

                                final currentQuantity =
                                    int.tryParse(
                                      controllers[index]!["quantity"]!.text,
                                    ) ??
                                    1;
                                final stockQty = product.stockQty ?? 0;
                                final openingStock = product.openingStock ?? 0;
                                final availableStock = stockQty > 0
                                    ? stockQty
                                    : openingStock;

                                if (availableStock <= 0) {
                                  showCustomToast(
                                    context: context,
                                    title: 'Stock Error!',
                                    description: "Product stock not available",
                                    icon: Icons.error,
                                    primaryColor: Colors.redAccent,
                                  );
                                  return;
                                }

                                if (currentQuantity >= availableStock) {
                                  showCustomToast(
                                    context: context,
                                    title: 'Stock Limit!',
                                    description:
                                        "Cannot exceed available stock: $availableStock",
                                    icon: Icons.warning,
                                    primaryColor: Colors.orange,
                                  );
                                  return;
                                }

                                controllers[index]!["quantity"]!.text =
                                    (currentQuantity + 1).toString();
                                products[index]["quantity"] =
                                    (currentQuantity + 1).toString();
                                updateTotal(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                /// 🔥 AUTO DISCOUNT VIEW (ONLY IF EXISTS)
                if (discountApplied) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.discount,
                              size: 16,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Auto Discount Applied",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              type.toLowerCase() == "percentage" ||
                                      type.toLowerCase() == "percent"
                                  ? "Discount (${doubleValue.toStringAsFixed(2)}%)"
                                  : "Discount (৳${doubleValue.toStringAsFixed(2)})",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "-৳ ${discountAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Final Price Per Unit:",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "৳${product["final_price"]?.toStringAsFixed(2) ?? "0.00"}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Final Price :",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "৳${totalFinalPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileChargesSection(CreatePosSaleBloc bloc) {
    return Form(
      key: _formKeyStep3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Additional Charges",
            style: AppTextStyle.cardLevelHead(
              context,
            ).copyWith(color: AppColors.text(context)),
          ),
          const SizedBox(height: 12),
          _buildChargesSection(bloc),
        ],
      ),
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
            calculateDiscountTotal();
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
            calculateVatTotal();
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
            calculateServiceChargeTotal();
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
            calculateDeliveryTotal();
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
                  selectedColor: AppColors.primaryColor(context),
                  borderColor: AppColors.primaryColor(context),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 140,
                child: CustomInputFieldPayRoll(
                  isRequiredLevle: false,
                  controller: controller,
                  hintText: label,

                  fillColor: AppColors.bottomNavBg(context),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    _updateChangeAmount();
                    setState(() {});
                  },
                  autofillHints: '',
                  levelText: '',
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      final numericValue = double.tryParse(value);
                      if (numericValue == null) {
                        return 'Enter valid number';
                      }
                      if (numericValue < 0) {
                        return 'Cannot be negative';
                      }
                    }
                    return null;
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
    final netTotal = calculateAllFinalTotal();

    return Form(
      key: _formKeyStep4,
      child: Column(
        children: [
          // Show customer type info
          if (isWalkInCustomer)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.bottomNavBg(context),
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
                color: AppColors.bottomNavBg(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Saved Customer: Due or advance payment allowed.",
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ResponsiveRow(
            spacing: 8,
            runSpacing: 8,
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
                    color: AppColors.bottomNavBg(context),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow("Product Total", productTotal),
                      _buildSummaryRow(
                        "Specific Discount (-)",
                        calculateSpecificDiscountTotal(),
                      ),
                      _buildSummaryRow("Sub Total", subTotal),
                      _buildSummaryRow(
                        "Discount (-)",
                        calculateDiscountTotal(),
                      ),
                      _buildSummaryRow("Vat (+)", calculateVatTotal()),
                      _buildSummaryRow(
                        "Service Charge (+)",
                        calculateServiceChargeTotal(),
                      ),
                      _buildSummaryRow(
                        "Delivery Charge (+)",
                        calculateDeliveryTotal(),
                      ),
                      _buildSummaryRow("Net Total", netTotal, isBold: true),
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
          ),
          const SizedBox(height: 20),
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
        const SizedBox(height: 10),
        CheckboxListTile(
          title: Text(
            "With Money Receipt",
            style: AppTextStyle.headerTitle(
              context,
            ).copyWith(color: AppColors.text(context)),
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
          Wrap(
            spacing: 10,
            children: [
              SizedBox(
                child: AppDropdown<String>(
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
                  itemList: bloc.paymentMethod,
                  onChanged: (newVal) {
                    bloc.selectedPaymentMethod = newVal.toString();
                    setState(() {});
                  },
                  validator: (value) =>
                      value == null ? 'Please select a payment method' : null,
                ),
              ),
              gapH8,
              SizedBox(
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
          Wrap(
            spacing: 6,
            children: [
              SizedBox(
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
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInputField(
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
                    if (isWalkInCustomer)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          "Walk-in: Pay exact amount only",
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    final netTotal = calculateAllFinalTotal();
    final paidAmount = double.tryParse(bloc.payableAmount.text.trim()) ?? 0;
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

      // "sale_by": bloc.selectSalesModel?.id.toString() ?? '',
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
    log(body.toString());
  }
}
