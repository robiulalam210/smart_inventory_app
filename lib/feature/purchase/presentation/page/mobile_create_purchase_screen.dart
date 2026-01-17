import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/feature/purchase/presentation/page/mobile_purchase_screen.dart';
import '/feature/accounts/data/model/account_active_model.dart';
import '/feature/products/product/presentation/bloc/products/products_bloc.dart';
import '/feature/supplier/data/model/supplier_active_model.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../products/categories/data/model/categories_model.dart';
import '../../../products/categories/presentation/bloc/categories/categories_bloc.dart';
import '../../../products/product/data/model/product_stock_model.dart';
import '../bloc/create_purchase/create_purchase_bloc.dart';

class MobileCreatePurchaseScreen extends StatefulWidget {
  const MobileCreatePurchaseScreen({super.key});

  @override
  _CreatePurchaseScreenState createState() => _CreatePurchaseScreenState();
}

class _CreatePurchaseScreenState extends State<MobileCreatePurchaseScreen> {
  // Add missing variable declarations
  late CategoriesBloc categoriesBloc;

  final TextEditingController changeAmountController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();
  double overallTotal = 0.0;
  double serviceCharge = 0.0;
  double deliveryCharge = 0.0;
  double discount = 0.0;
  double vatAmount = 0.0;
  double ticketTotal = 0;
  double specificDiscount = 0;
  double paidAmount = 0.0;
  double dueAmount = 0.0;
  double changeAmount = 0.0;

  List<Map<String, dynamic>> products = [];
  String selectedOverallDiscountType = 'fixed';
  String selectedOverallServiceChargeType = 'fixed';
  String selectedOverallDeliveryType = 'fixed';
  String selectedVatType = 'fixed';
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  Map<int, Map<String, TextEditingController>> controllers = {};

  // Mobile stepper current step
  int currentStep = 0;
  bool _isChecked = false;

  @override
  void initState() {
    context.read<AccountBloc>().add(FetchAccountActiveList(context));
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
    super.initState();
    context.read<ProductsBloc>().add(FetchProductsStockList(context));
    categoriesBloc = context.read<CategoriesBloc>();
    categoriesBloc.add(FetchCategoriesList(context));
    // Initialize date controller
    context.read<CreatePurchaseBloc>().dateEditingController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    // Initialize paid amount controller
    paidAmountController.addListener(_updatePaymentCalculations);

    addProduct(); // Initialize with one product row
  }

  @override
  void dispose() {
    for (var controllers in controllers.values) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    changeAmountController.dispose();
    vatController.dispose();
    paidAmountController.removeListener(_updatePaymentCalculations);
    paidAmountController.dispose();
    super.dispose();
  }

  void _updatePaymentCalculations() {
    if (mounted) {
      setState(() {
        paidAmount = double.tryParse(paidAmountController.text) ?? 0.0;
        final netTotal = calculateAllFinalTotal();

        dueAmount = (netTotal - paidAmount) > 0 ? (netTotal - paidAmount) : 0.0;
        changeAmount = (paidAmount - netTotal) > 0
            ? (paidAmount - netTotal)
            : 0.0;
      });
    }
  }

  double calculateTotalForAllProducts() {
    double totalSum = 0.0;
    for (var product in products) {
      totalSum += product["total"];
    }
    return totalSum;
  }

  void updateTotal(int index) {
    final price =
        double.tryParse(controllers[index]?["price"]?.text ?? '') ?? 0.0;
    final quantity =
        double.tryParse(controllers[index]?["quantity"]?.text ?? '') ?? 0.0;
    final discount =
        double.tryParse(controllers[index]?["discount"]?.text ?? '') ?? 0.0;
    final discountType = products[index]["discount_type"] as String? ?? '';

    double total = price * quantity;

    // update ticket_total controller
    controllers[index]?["ticket_total"]?.text = (price * quantity)
        .toStringAsFixed(2);
    products[index]["ticket_total"] = price * quantity;

    if (discountType == 'fixed') {
      total -= discount;
    } else if (discountType == 'percentage') {
      total -= (total * (discount / 100));
    }

    total = total < 0 ? 0.0 : total;

    controllers[index]!["total"]!.text = total.toStringAsFixed(2);
    setState(() {
      products[index]["total"] = total;
      overallTotal = calculateFinalTotal();
      _updatePaymentCalculations(); // Update payment calculations when totals change
    });
  }

  double calculateVatTotal() {
    double total = calculateTotalForAllProducts();
    double enteredVat = double.tryParse(vatController.text) ?? 0.0;

    vatAmount = (selectedVatType == 'percentage')
        ? (total * (enteredVat / 100))
        : enteredVat;

    return vatAmount;
  }

  double calculateDeliveryTotal() {
    double total = calculateTotalForAllProducts();
    deliveryCharge =
        double.tryParse(
          context
              .read<CreatePurchaseBloc>()
              .deliveryChargeOverAllController
              .text,
        ) ??
            0.0;

    if (selectedOverallDeliveryType == 'percentage') {
      deliveryCharge = (total * (deliveryCharge / 100));
    }
    return deliveryCharge;
  }

  double calculateDiscountTotal() {
    double total = calculateTotalForAllProducts();
    discount =
        double.tryParse(
          context.read<CreatePurchaseBloc>().discountOverAllController.text,
        ) ??
            0.0;

    if (selectedOverallDiscountType == 'percentage') {
      discount = (total * (discount / 100));
    }
    return discount;
  }

  double calculateTotalTicketForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      totalSum += product["ticket_total"] ?? 0;
    }
    return totalSum;
  }

  double calculateServiceChargeTotal() {
    double total = calculateTotalForAllProducts();
    double enteredServiceCharge =
        double.tryParse(
          context
              .read<CreatePurchaseBloc>()
              .serviceChargeOverAllController
              .text,
        ) ??
            0.0;

    serviceCharge = (selectedOverallServiceChargeType == 'percentage')
        ? (total * (enteredServiceCharge / 100))
        : enteredServiceCharge;

    return serviceCharge;
  }

  double calculateAllFinalTotal() {
    double total = calculateTotalForAllProducts();

    // Apply discount
    double discount = calculateDiscountTotal();
    total -= discount;

    // Apply delivery charge
    double deliveryCharge = calculateDeliveryTotal();
    total += deliveryCharge;

    // Apply service charge
    double serviceCharge = calculateServiceChargeTotal();
    total += serviceCharge;

    // Apply VAT
    double vat = calculateVatTotal();
    total += vat;

    return total;
  }

  double calculateFinalTotal() {
    double total = calculateTotalForAllProducts();
    total += calculateServiceChargeTotal();
    total += calculateDeliveryTotal();
    total += calculateVatTotal();
    total -= calculateDiscountTotal();
    total = total < 0 ? 0.0 : total;
    return total;
  }

  void addProduct() {
    setState(() {
      final newIndex = products.length;
      products.add({
        "id": newIndex,
        "product": null,
        "product_id": null,
        "discount_type": 'fixed',
        "product_name": "",
        "price": 0.0,
        "stock": 0,
        "quantity": 1,
        "discount": 0.0,
        "total": 0.0,
        "ticket_total": 0.0,
      });

      controllers[newIndex] = {
        "quantity": TextEditingController(text: "1"),
        "price": TextEditingController(text: "0.0"),
        "discount": TextEditingController(text: "0.0"),
        "total": TextEditingController(text: "0.0"),
        "ticket_total": TextEditingController(text: "0.0"),
      };
    });
  }

  void removeProduct(int index) {
    setState(() {
      if (controllers.containsKey(index)) {
        for (var controller in controllers[index]!.values) {
          controller.dispose();
        }
        controllers.remove(index);
      }

      products.removeAt(index);

      Map<int, Map<String, TextEditingController>> newControllers = {};
      controllers.forEach((key, value) {
        if (key > index) {
          newControllers[key - 1] = value;
        } else {
          newControllers[key] = value;
        }
      });

      controllers.clear();
      controllers.addAll(newControllers);
      _updatePaymentCalculations(); // Update payment calculations when product is removed
    });
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

    setState(() {
      products[index]["product"] = newVal;
      products[index]["product_id"] = newVal.id;
      products[index]["product_name"] = newVal.name;
      controllers[index]?["price"]?.text = (newVal.sellingPrice ?? 0.0)
          .toString();
      products[index]["price"] = newVal.sellingPrice ?? 0.0;
      controllers[index]?["discount"]?.text = (newVal.discountValue ?? 0.0)
          .toString();
      products[index]["discount"] = newVal.discountValue ?? 0.0;
      products[index]["discount_type"] = newVal.discountType ?? 'fixed';
      updateTotal(index);
    });
  }

  void _payFullAmount() {
    setState(() {
      paidAmountController.text = calculateAllFinalTotal().toStringAsFixed(2);
      paidAmount = calculateAllFinalTotal();
      dueAmount = 0.0;
      changeAmount = 0.0;
    });
  }

  void _clearPayment() {
    setState(() {
      paidAmountController.clear();
      paidAmount = 0.0;
      dueAmount = calculateAllFinalTotal();
      changeAmount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppScaffold(
        appBar: AppBar(
          title: Text("Purchase", style: AppTextStyle.titleMedium(context)),
        ),
        body: _buildMobileLayout(),
      ),
    );
  }

  // -----------------------
  // Mobile layout & stepper
  // -----------------------

  Widget _buildMobileLayout() {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 12,
      xl: 12,
      child: BlocConsumer<CreatePurchaseBloc, CreatePurchaseState>(
        listener: (context, state) {
          if (state is CreatePurchaseLoading) {
            appLoader(context, "Creating Purchase, please wait...");
          } else if (state is CreatePurchaseSuccess) {
            Navigator.pop(context);
            AppRoutes.pushReplacement(context, MobilePurchaseScreen());
          } else if (state is CreatePurchaseFailed) {
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: _buildMobileStepperContent(),
          );
        },
      ),
    );
  }

  Widget _buildMobileStepperContent() {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      type: StepperType.vertical,
      currentStep: currentStep,
      onStepContinue: () {
        debugPrint("onStepContinue called, currentStep: $currentStep");

        // Validate current step before moving
        if (!_validateCurrentStep()) {
          return; // Don't proceed if validation fails
        }

        // Check if we're at the last step
        if (currentStep == 3) {
          _submitForm();
        } else {
          // Move to next step
          setState(() {
            currentStep += 1;
          });
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
        Step(
          title: Text(
            'Supplier & Date',
            style: AppTextStyle.cardLevelHead(context),
          ),
          content: _buildMobileTopFormSection(),
          isActive: currentStep >= 0,
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text('Products', style: AppTextStyle.cardLevelHead(context)),
          content: _buildMobileProductListSection(),
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text('Charges', style: AppTextStyle.cardLevelHead(context)),
          content: _buildMobileChargesSection(),
          isActive: currentStep >= 2,
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text(
            'Summary & Payment',
            style: AppTextStyle.cardLevelHead(context),
          ),
          content: _buildSummarySection(),
          isActive: currentStep >= 3,
          state: StepState.indexed,
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0: // Supplier & Date
        return _validateStep1();
      case 1: // Products
        return _validateStep2();
      case 2: // Charges
        return true; // No validation needed for charges
      case 3: // Summary & Payment
        return _validateStep4();
      default:
        return true;
    }
  }

  bool _validateStep1() {
    debugPrint("=== Validating Step 1 ===");

    // Check if form is initialized
    if (formKey1.currentState == null) {
      debugPrint("Form key 1 is not initialized!");
      return false;
    }

    // Validate the form
    bool formValid = formKey1.currentState!.validate();
    debugPrint("Form validation result: $formValid");

    final bloc = context.read<CreatePurchaseBloc>();

    // Additional validation for supplier
    if (bloc.supplierListModel == null) {
      debugPrint("Supplier not selected");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: 'Please select a supplier',
          icon: Icons.error,
          primaryColor: Colors.red,
        );
      });
      return false;
    }

    return formValid;
  }

  bool _validateStep2() {
    debugPrint("=== Validating Step 2 ===");

    // Check if at least one product is added
    if (products.isEmpty) {
      debugPrint("No products added");
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please add at least one product',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return false;
    }

    // Check each product has valid data
    bool hasValidProduct = false;
    List<String> validationErrors = [];

    for (int i = 0; i < products.length; i++) {
      var product = products[i];

      // Check if product is selected
      if (product["product_id"] != null) {
        hasValidProduct = true;

        // Validate price
        double price = double.tryParse(controllers[i]?["price"]?.text ?? '') ?? 0.0;
        if (price <= 0) {
          validationErrors.add("Product ${i + 1}: Please enter valid price");
        }

        // Validate quantity
        int qty = int.tryParse(controllers[i]?["quantity"]?.text ?? '') ?? 0;
        if (qty <= 0) {
          validationErrors.add("Product ${i + 1}: Please enter valid quantity");
        }
      } else {
        validationErrors.add("Product ${i + 1}: Please select a product");
      }
    }

    if (!hasValidProduct) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please select at least one product',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return false;
    }

    if (validationErrors.isNotEmpty) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: validationErrors.join('\n'),
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return false;
    }

    return true;
  }

  bool _validateStep4() {
    debugPrint("=== Validating Step 4 ===");

    // If instant pay is checked, validate payment method
    if (_isChecked) {
      final paymentMethod = context.read<CreatePurchaseBloc>().selectedPaymentMethod;
      final accountId = context.read<CreatePurchaseBloc>().selectedAccountId;

      if (paymentMethod.isEmpty) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: 'Please select payment method',
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return false;
      }

      if (accountId.isEmpty) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: 'Please select account',
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return false;
      }

      // Validate paid amount
      final paidAmountValue = double.tryParse(paidAmountController.text) ?? 0.0;
      if (paidAmountValue <= 0) {
        showCustomToast(
          context: context,
          title: 'Validation Error',
          description: 'Please enter valid paid amount',
          icon: Icons.error,
          primaryColor: Colors.red,
        );
        return false;
      }
    }

    return true;
  }

  Widget _buildMobileTopFormSection() {
    final bloc = context.read<CreatePurchaseBloc>();

    return Form(
      key: formKey1,
      autovalidateMode: currentStep == 0 ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
            builder: (context, state) {
              return AppDropdown<SupplierActiveModel>(
                label: "Supplier",
                hint: "Select Supplier",
                isLabel: false,
                isRequired: true,
                isNeedAll: false,
                value: bloc.supplierListModel,
                itemList: context.read<SupplierInvoiceBloc>().supplierActiveList,
                onChanged: (newVal) {
                  bloc.supplierListModel = newVal;
                  setState(() {});
                },
                validator: (value) {
                  return value == null ? 'Please select Supplier' : null;
                },

              );
            },
          ),
          const SizedBox(height: 12),
          CustomInputField(
            radius: 10,
            isRequired: true,
            readOnly: true,
            controller: bloc.dateEditingController,
            hintText: 'Purchase Date',
            keyboardType: TextInputType.datetime,
            bottom: 15.0,
            fillColor: AppColors.whiteColor(context),
            validator: (value) {
              return value!.isEmpty ? 'Please enter date' : null;
            },
            onTap: _selectDate,
          ),
          const SizedBox(height: 8),
          // Optional: VAT small input in mobile top (if needed)
          Row(
            children: [
              Expanded(
                child: CupertinoSegmentedControl<String>(
                  padding: EdgeInsets.zero,
                  children: {
                    'fixed': Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 8,
                      ),
                      child: Text(
                        'TK',
                        style: TextStyle(
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          color: selectedVatType == 'fixed'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    'percentage': Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 8,
                      ),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          color: selectedVatType == 'percentage'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      selectedVatType = value;
                      calculateVatTotal();
                      _updatePaymentCalculations();
                    });
                  },
                  groupValue: selectedVatType,
                  unselectedColor: Colors.grey[300],
                  selectedColor: AppColors.primaryColor(context),
                  borderColor: AppColors.primaryColor(context),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                child: CustomInputField(
                  controller: vatController,
                  hintText: 'VAT',
                  isRequiredLable: false,
                  fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    calculateVatTotal();
                    _updatePaymentCalculations();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProductListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductRows(),
        const SizedBox(height: 8),
        Center(
          child: AppButton(name: 'Add Product', onPressed: addProduct),
        ),
      ],
    );
  }

  Widget _buildMobileChargesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildChargesSection()],
    );
  }

  // -----------------------
  // End mobile-specific UI
  // -----------------------

  Widget _buildProductRows() {
    return Form(
      key: formKey2,
      autovalidateMode: currentStep == 1 ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        children: products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;

          if (!controllers.containsKey(index)) {
            controllers[index] = {
              "quantity": TextEditingController(
                text: product["quantity"].toString(),
              ),
              "price": TextEditingController(text: product["price"].toString()),
              "discount": TextEditingController(
                text: product["discount"].toString(),
              ),
              "total": TextEditingController(text: product["total"].toString()),
              "ticket_total": TextEditingController(
                text: product["ticket_total"].toString(),
              ),
            };
          }

          return Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ResponsiveRow(
              spacing: 5,
              runSpacing: 6,
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

                      );
                    },
                  ),
                ),

                // ================= PRODUCT =================
                ResponsiveCol(
                  xs: 12,
                  sm: 4,
                  md: 4,
                  lg: 4,
                  xl: 4,
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
                ),

                ResponsiveCol(
                  xs: 3,
                  sm: 1,
                  md: 1,
                  lg: 1,
                  xl: 1,
                  child: TextFormField(
                    style: AppTextStyle.cardLevelText(context),
                    controller: controllers[index]?["price"],
                    keyboardType: TextInputType.number,
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
                        top: 10.0,
                        bottom: 10.0,
                        left: 12,
                      ),
                      isDense: true,
                      hintText: "price",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter price';
                      final priceValue = double.tryParse(value);
                      if (priceValue == null || priceValue <= 0) {
                        return 'Price must be > 0';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        final parsedValue = double.tryParse(value) ?? 1;
                        products[index]["price"] = parsedValue;
                        controllers[index]?["price"]?.text = parsedValue
                            .toString();
                        updateTotal(index);
                      });
                    },
                  ),
                ),
                ResponsiveCol(
                  xs: 3,
                  sm: 1,
                  md: 1,
                  lg: 1,
                  xl: 1,
                  child: CupertinoSegmentedControl<String>(
                    padding: EdgeInsets.zero,
                    children: {
                      'fixed': Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          'TK',
                          style: TextStyle(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            color: products[index]["discount_type"] == 'fixed'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      'percentage': Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          ' %',
                          style: TextStyle(
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            color:
                            products[index]["discount_type"] == 'percentage'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        products[index]["discount_type"] = value;
                        updateTotal(index);
                      });
                    },
                    groupValue: products[index]["discount_type"],
                    unselectedColor: Colors.grey[300],
                    selectedColor: AppColors.primaryColor(context),
                    borderColor: AppColors.primaryColor(context),
                  ),
                ),
                ResponsiveCol(
                  xs: 3,
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
                    decoration: InputDecoration(
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
                        top: 10.0,
                        bottom: 10.0,
                        left: 10,
                      ),
                      isDense: true,
                      hintText: "Discount",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                    validator: (value) {
                      final discountValue = double.tryParse(value ?? '');
                      if (discountValue == null || discountValue < 0) {
                        return 'Discount must be >= 0';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        products[index]["discount"] =
                            double.tryParse(value) ?? 0.0;
                        updateTotal(index);
                      });
                    },
                  ),
                ),
                ResponsiveCol(
                  xs: 4.5,
                  sm: 1.1,
                  md: 1.1,
                  lg: 1.1,
                  xl: 1.1,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
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
                          });
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
                          setState(() {
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
                          });
                        },
                      ),
                    ],
                  ),
                ),

                ResponsiveCol(
                  xs: 2.8,
                  sm: 0.8,
                  md: 0.8,
                  lg: 0.8,
                  xl: 0.8,
                  child: TextFormField(
                    style: AppTextStyle.cardLevelText(context),
                    controller: controllers[index]?["ticket_total"],
                    keyboardType: TextInputType.number,
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
                        top: 10.0,
                        bottom: 10.0,
                        left: 12,
                      ),
                      isDense: true,
                      hintText: "ticket total",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        products[index]["ticket_total"] =
                            double.tryParse(value) ?? 0.0;
                        updateTotal(index);
                      });
                    },
                  ),
                ),
                ResponsiveCol(
                  xs: 4,
                  sm: 1,
                  md: 1,
                  lg: 1,
                  xl: 1,
                  child: TextFormField(
                    style: AppTextStyle.cardLevelText(context),
                    controller: controllers[index]?["total"],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text(
                        "Total Amount",
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
                        top: 10.0,
                        bottom: 10.0,
                        left: 12,
                      ),
                      isDense: true,
                      hintText: "total",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        products[index]["total"] = double.tryParse(value) ?? 0.0;
                        updateTotal(index);
                      });
                    },
                  ),
                ),
                product == products[products.length - 1]
                    ? SizedBox.shrink()
                    : ResponsiveCol(
                  xs: 12,
                  sm: 1,
                  md: 1,
                  lg: 1,
                  xl: 1,
                  child: IconButton(
                    icon: Icon(
                      product == products[products.length - 1]
                          ? Icons.add
                          : Icons.remove,
                      color: products.length == 1
                          ? Colors.green
                          : Colors.red,
                    ),
                    onPressed: () {
                      if (product == products[products.length - 1]) {
                        // addProduct();
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
      ),
    );
  }

  Widget _buildChargesSection() {
    return ResponsiveRow(
      spacing: 20,
      runSpacing: 10,
      children: [
        _buildChargeField(
          "Overall Discount",
          context.read<CreatePurchaseBloc>().discountOverAllController,
          selectedOverallDiscountType,
              (value) {
            setState(() {
              selectedOverallDiscountType = value;
              calculateDiscountTotal();
              _updatePaymentCalculations();
            });
          },
        ),
        _buildChargeField(
          "Service Charge",
          context.read<CreatePurchaseBloc>().serviceChargeOverAllController,
          selectedOverallServiceChargeType,
              (value) {
            setState(() {
              selectedOverallServiceChargeType = value;
              calculateServiceChargeTotal();
              _updatePaymentCalculations();
            });
          },
        ),
        _buildChargeField(
          "Delivery Charge",
          context.read<CreatePurchaseBloc>().deliveryChargeOverAllController,
          selectedOverallDeliveryType,
              (value) {
            setState(() {
              selectedOverallDeliveryType = value;
              calculateDeliveryTotal();
              _updatePaymentCalculations();
            });
          },
        ),
      ],
    );
  }

  Widget _buildChargeField(
      String label,
      TextEditingController controller,
      String selectedType,
      Function(String) onTypeChanged,
      ) {
    return ResponsiveCol(
      xs: 12,
      sm: 3,
      md: 3,
      lg: 3,
      xl: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.cardLevelText(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: CupertinoSegmentedControl<String>(
                  padding: EdgeInsets.zero,
                  children: {
                    'fixed': Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                    'percentage': Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          color: selectedType == 'percentage'
                              ? Colors.white
                              : Colors.black,
                        ),
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
              const SizedBox(width: 8),
              Expanded(
                child: CustomInputField(
                  controller: controller,
                  hintText: '$label ',
                  isRequiredLable: false,
                  fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    if (label.contains('Discount')) calculateDiscountTotal();
                    if (label.contains('Service')) {
                      calculateServiceChargeTotal();
                    }
                    if (label.contains('Delivery')) calculateDeliveryTotal();
                    _updatePaymentCalculations();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Form(
      key: formKey3,
      autovalidateMode: currentStep == 3 ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: ResponsiveRow(
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
                  _buildSummaryRow(
                    "Ticket Total",
                    calculateTotalTicketForAllProducts().toStringAsFixed(2),
                  ),
                  _buildSummaryRow(
                    "Specific Discount (-)",
                    discount.toStringAsFixed(2),
                  ),
                  _buildSummaryRow(
                    "Sub Total",
                    calculateTotalForAllProducts().toStringAsFixed(2),
                  ),
                  _buildSummaryRow("Discount (-)", discount.toStringAsFixed(2)),
                  _buildSummaryRow(
                    "Service Charge (+)",
                    serviceCharge.toStringAsFixed(2),
                  ),
                  _buildSummaryRow(
                    "Delivery Charge (+)",
                    deliveryCharge.toStringAsFixed(2),
                  ),
                  _buildSummaryRow("VAT (+)", vatAmount.toStringAsFixed(2)),
                  const Divider(),
                  _buildSummaryRow(
                    "Net Total",
                    calculateAllFinalTotal().toStringAsFixed(2),
                    isBold: true,
                  ),
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
                    "Instant Pay",
                    style: AppTextStyle.cardTitle(context),
                  ),
                  value: _isChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isChecked = newValue ?? false;
                      if (_isChecked) {
                        _payFullAmount();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 10),
                _isChecked ? _buildPaymentSection() : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: isBold
                  ? AppTextStyle.cardTitle(context)
                  : AppTextStyle.cardLevelHead(context),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: isBold
                  ? AppTextStyle.cardTitle(context)
                  : AppTextStyle.cardLevelText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Information", style: AppTextStyle.cardTitle(context)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppDropdown<String>(
                  label: "Payment Method",
                  hint:
                  context
                      .read<CreatePurchaseBloc>()
                      .selectedPaymentMethod
                      .isEmpty
                      ? "Select Payment Method"
                      : context
                      .read<CreatePurchaseBloc>()
                      .selectedPaymentMethod,
                  isLabel: false,
                  isRequired: true,
                  isNeedAll: false,
                  value:
                  context
                      .read<CreatePurchaseBloc>()
                      .selectedPaymentMethod
                      .isEmpty
                      ? null
                      : context
                      .read<CreatePurchaseBloc>()
                      .selectedPaymentMethod,
                  itemList: const ['cash', 'bank', 'cheque', 'digital'],
                  onChanged: (newVal) {
                    context.read<CreatePurchaseBloc>().selectedPaymentMethod =
                        newVal.toString();
                    setState(() {});
                  },
                  validator: (value) {
                    return value == null
                        ? 'Please select a payment method'
                        : null;
                  },

                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                    if (state is AccountActiveListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AccountActiveListSuccess) {
                      final filteredList =
                      context
                          .read<CreatePurchaseBloc>()
                          .selectedPaymentMethod
                          .isNotEmpty
                          ? state.list.where((item) {
                        final paymentMethod = context
                            .read<CreatePurchaseBloc>()
                            .selectedPaymentMethod
                            .toLowerCase();
                        final accountType =
                            item.acType?.toLowerCase() ?? '';

                        if (paymentMethod == 'cash') {
                          return accountType == 'cash';
                        } else if (paymentMethod == 'bank') {
                          return accountType == 'bank';
                        } else if (paymentMethod == 'digital') {
                          return accountType == 'mobile banking';
                        } else {
                          return true;
                        }
                      }).toList()
                          : state.list;

                      return AppDropdown<AccountActiveModel>(
                        label: "Account",
                        hint: "Select Account",
                        isLabel: false,
                        isRequired: true,
                        isNeedAll: false,
                        value: context
                            .read<CreatePurchaseBloc>()
                            .accountActiveModel,
                        itemList: filteredList,
                        onChanged: (newVal) {
                          if (newVal != null) {
                            context
                                .read<CreatePurchaseBloc>()
                                .accountActiveModel =
                                newVal;
                            context
                                .read<CreatePurchaseBloc>()
                                .selectedAccountId =
                                newVal.id?.toString() ?? "";
                          } else {
                            context
                                .read<CreatePurchaseBloc>()
                                .selectedAccountId =
                            "";
                          }
                        },
                        validator: (value) {
                          return value == null
                              ? 'Please select an account'
                              : null;
                        },

                      );
                    } else if (state is AccountListFailed) {
                      return Center(
                        child: Text(
                          'Failed to load accounts: ${state.content}',
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomInputField(
                  controller: paidAmountController,
                  hintText: 'Paid Amount',
                  isRequiredLable: true,
                  fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (_isChecked) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter paid amount';
                      }
                      final paid = double.tryParse(value);
                      if (paid == null || paid <= 0) {
                        return 'Paid amount must be > 0';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _updatePaymentCalculations();
                  },
                ),
              ),
              const SizedBox(width: 10),
              AppButton(
                name: 'Full Payment',
                onPressed: _payFullAmount,
                color: AppColors.primaryColor(context),
              ),
              const SizedBox(width: 10),
              AppButton(
                name: 'Clear',
                onPressed: _clearPayment,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPaymentSummary(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          _buildPaymentRow(
            "Net Total:",
            calculateAllFinalTotal().toStringAsFixed(2),
          ),
          _buildPaymentRow("Paid Amount:", paidAmount.toStringAsFixed(2)),
          _buildPaymentRow(
            "Due Amount:",
            dueAmount.toStringAsFixed(2),
            color: dueAmount > 0 ? Colors.red : Colors.green,
          ),
          _buildPaymentRow(
            "Change Amount:",
            changeAmount.toStringAsFixed(2),
            color: changeAmount > 0 ? Colors.green : Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyle.cardLevelHead(context)),
          ),
          Text(
            value,
            style: AppTextStyle.cardLevelText(
              context,
            ).copyWith(color: color, fontWeight: FontWeight.bold),
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
      setState(() {
        context.read<CreatePurchaseBloc>().dateEditingController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _submitForm() {
    debugPrint("========== SUBMIT FORM CALLED ==========");

    // Validate all steps first
    bool allStepsValid = true;
    for (int i = 0; i <= 3; i++) {
      if (!_validateStepWithIndex(i)) {
        allStepsValid = false;
        setState(() {
          currentStep = i;
        });
        break;
      }
    }

    if (!allStepsValid) {
      debugPrint("❌ Some steps failed validation");
      return;
    }

    debugPrint("✅ All validations passed");

    // Validate that at least one product is selected
    bool hasValidProducts = false;
    bool hasValidPrices = true;

    for (var product in products) {
      debugPrint("Checking product: ${product.toString()}");
      if (product["product_id"] != null) {
        hasValidProducts = true;
        debugPrint("✅ Product found with ID: ${product["product_id"]}");

        // Check if price is valid (greater than 0)
        double price = double.tryParse(product["price"].toString()) ?? 0.0;
        debugPrint("Product price: $price");

        if (price <= 0) {
          debugPrint("❌ Invalid price found: $price");
          hasValidPrices = false;
          break;
        }
      }
    }

    debugPrint("hasValidProducts: $hasValidProducts");
    debugPrint("hasValidPrices: $hasValidPrices");

    if (!hasValidProducts) {
      debugPrint("❌ No valid products found - showing alert");
      appAlertDialog(
        context,
        "Please add at least one product to the purchase.",
        title: "Validation Error",
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
      return;
    }

    if (!hasValidPrices) {
      debugPrint("❌ Invalid prices found - showing alert");
      appAlertDialog(
        context,
        "Please enter valid prices (greater than 0) for all products.",
        title: "Validation Error",
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
      return;
    }

    debugPrint("✅ All product validations passed");

    // Calculate totals from products
    double subtotal = 0.0;
    var transferProducts = products
        .where((product) => product["product_id"] != null)
        .map((product) {
      debugPrint("Processing product for transfer: ${product.toString()}");

      // Calculate the actual price from the product data
      double price = double.tryParse(product["price"].toString()) ?? 0.0;
      int qty = int.tryParse(product["quantity"].toString()) ?? 1;
      double discount =
          double.tryParse(product["discount"].toString()) ?? 0.0;
      String discountType = product["discount_type"].toString();

      debugPrint("Price: $price, Qty: $qty, Discount: $discount ($discountType)");

      // Calculate item total
      double itemTotal = price * qty;
      double itemDiscount = 0.0;

      if (discountType == 'percentage') {
        itemDiscount = itemTotal * (discount / 100);
      } else {
        itemDiscount = discount;
      }

      double itemNetTotal = itemTotal - itemDiscount;
      subtotal += itemNetTotal;

      debugPrint("Item Total: $itemTotal, Discount: $itemDiscount, Net Total: $itemNetTotal");
      debugPrint("Subtotal so far: $subtotal");

      return {
        "product_id": product["product_id"].toString(),
        "qty": qty,
        "price": price,
        "discount": discount,
        "discount_type": discountType,
      };
    })
        .toList();

    debugPrint("✅ Products processed. Transfer products count: ${transferProducts.length}");
    debugPrint("✅ Final subtotal: $subtotal");

    // Calculate charges based on subtotal
    double overallDiscount =
        double.tryParse(
          context.read<CreatePurchaseBloc>().discountOverAllController.text,
        ) ??
            0.0;

    double serviceCharge =
        double.tryParse(
          context
              .read<CreatePurchaseBloc>()
              .serviceChargeOverAllController.text,
        ) ??
            0.0;

    double deliveryCharge =
        double.tryParse(
          context
              .read<CreatePurchaseBloc>()
              .deliveryChargeOverAllController.text,
        ) ??
            0.0;

    double vat = double.tryParse(vatController.text) ?? 0.0;

    debugPrint("Charges:");
    debugPrint("  Overall Discount: $overallDiscount ($selectedOverallDiscountType)");
    debugPrint("  Service Charge: $serviceCharge ($selectedOverallServiceChargeType)");
    debugPrint("  Delivery Charge: $deliveryCharge ($selectedOverallDeliveryType)");
    debugPrint("  VAT: $vat ($selectedVatType)");

    Map<String, dynamic> body = {
      "instant_pay": _isChecked,
      "supplier": context
          .read<CreatePurchaseBloc>()
          .supplierListModel
          ?.id
          .toString(),
      "purchase_date": context
          .read<CreatePurchaseBloc>()
          .dateEditingController
          .text
          .trim(),
      "purchase_items": transferProducts,

      // Charges
      "overall_discount": overallDiscount,
      "overall_discount_type": selectedOverallDiscountType,

      "overall_service_charge": serviceCharge,
      "overall_service_charge_type": selectedOverallServiceChargeType,

      "overall_delivery_charge": deliveryCharge,
      "overall_delivery_charge_type": selectedOverallDeliveryType,

      "vat": vat,
      "vat_type": selectedVatType,

      // "remark": context.read<CreatePurchaseBloc>().remarkController.text.trim(),
    };

    debugPrint("✅ Body created with ${body.length} fields");

    // Add payment information if payment method is selected
    if (context.read<CreatePurchaseBloc>().selectedPaymentMethod.isNotEmpty) {
      debugPrint("✅ Payment method selected: ${context.read<CreatePurchaseBloc>().selectedPaymentMethod}");
      body["payment_method"] = context
          .read<CreatePurchaseBloc>()
          .selectedPaymentMethod;
      body["account_id"] = context
          .read<CreatePurchaseBloc>()
          .selectedAccountId;
      body["paid_amount"] = paidAmount;
      debugPrint("✅ Paid amount: $paidAmount");
    } else {
      debugPrint("⚠️ No payment method selected");
    }

    // Log the request body for debugging
    debugPrint("📦 FINAL REQUEST BODY:");
    debugPrint(body.toString());

    debugPrint("🚀 Sending AddPurchase event...");

    // Send the request
    context.read<CreatePurchaseBloc>().add(AddPurchase(body: body));

    debugPrint("✅ AddPurchase event dispatched");

    debugPrint("========== SUBMIT FORM COMPLETE ==========");
  }

  bool _validateStepWithIndex(int stepIndex) {
    switch (stepIndex) {
      case 0: // Supplier & Date
        return _validateStep1();
      case 1: // Products
        return _validateStep2();
      case 2: // Charges
        return true;
      case 3: // Summary & Payment
        return _validateStep4();
      default:
        return true;
    }
  }
}