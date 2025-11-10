import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_inventory/core/core.dart';
import 'package:smart_inventory/feature/products/product/data/model/product_stock_model.dart';
import 'package:smart_inventory/feature/users_list/presentation/bloc/users/user_bloc.dart';
import 'dart:developer';

import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
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

    super.initState();

    // Initialize dates
    final bloc = context.read<CreatePosSaleBloc>();
    bloc.dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(DateTime.now());
    bloc.withdrawDateController.text = appWidgets.convertDateTimeDDMMYYYY(DateTime.now());

    // Initialize charge types from BLoC
    selectedOverallVatType = bloc.selectedOverallVatType;
    selectedOverallDiscountType = bloc.selectedOverallDiscountType;
    selectedOverallServiceChargeType = bloc.selectedOverallServiceChargeType;
    selectedOverallDeliveryType = bloc.selectedOverallDeliveryType;
    _isChecked = bloc.isChecked;
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
      double productDiscount = (product["discount"] ?? 0).toDouble();
      double ticketTotal = (product["ticket_total"] ?? 0).toDouble();

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
    total -= discount;

    return total;
  }

  double calculateVatTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    vat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;

    if (selectedOverallVatType == 'percent') {
      vat = total * (vat / 100);
    }
    total += vat;

    return total;
  }

  double calculateServiceChargeTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    serviceCharge = double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;

    if (selectedOverallServiceChargeType == 'percent') {
      serviceCharge = total * (serviceCharge / 100);
    }
    total += serviceCharge;

    return total;
  }

  double calculateDeliveryTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    deliveryCharge = double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;

    if (selectedOverallDeliveryType == 'percent') {
      deliveryCharge = total * (deliveryCharge / 100);
    }
    total += deliveryCharge;

    return total;
  }

  double calculateAllFinalTotal() {
    double total = calculateTotalForAllProducts();
    final bloc = context.read<CreatePosSaleBloc>();

    // Apply discount
    discount = double.tryParse(bloc.discountOverAllController.text) ?? 0.0;
    if (selectedOverallDiscountType == 'percent') {
      discount = total * (discount / 100);
    }
    total -= discount;

    // Apply VAT
    vat = double.tryParse(bloc.vatOverAllController.text) ?? 0.0;
    if (selectedOverallVatType == 'percent') {
      vat = calculateTotalForAllProducts() * (vat / 100);
    }
    total += vat;

    // Apply Service Charge
    serviceCharge = double.tryParse(bloc.serviceChargeOverAllController.text) ?? 0.0;
    if (selectedOverallServiceChargeType == 'percent') {
      serviceCharge = calculateTotalForAllProducts() * (serviceCharge / 100);
    }
    total += serviceCharge;

    // Apply Delivery Charge
    deliveryCharge = double.tryParse(bloc.deliveryChargeOverAllController.text) ?? 0.0;
    if (selectedOverallDeliveryType == 'percent') {
      deliveryCharge = calculateTotalForAllProducts() * (deliveryCharge / 100);
    }
    total += deliveryCharge;

    return total;
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
    final discount = double.tryParse(discountText) ?? 0;

    double total = price * quantity;
    controllers[index]?["ticket_total"]?.text = total.toStringAsFixed(2);
    products[index]["ticket_total"] = total;

    if (discountType == 'fixed') {
      total -= discount;
    } else if (discountType == 'percent') {
      final discountAmount = (total * (discount / 100));
      total -= discountAmount;
    }

    total = total < 0 ? 0.0 : total;
    controllers[index]?["total"]?.text = total.toStringAsFixed(2);
    products[index]["total"] = total;

    setState(() {});
  }

  void onProductChanged(int index, ProductModelStockModel? newVal) {
    if (newVal == null) return;

    final totalStock = newVal.stockQty ?? 0;

    if (totalStock > 0) {
      products[index]["product"] = newVal;
      products[index]["product_id"] = newVal.id;
      products[index]["price"] = newVal.sellingPrice;
      products[index]["discount"] = 0;

      controllers[index]!["price"]!.text = newVal.sellingPrice.toString();
      controllers[index]!["discount"]!.text = "0";

      updateTotal(index);
    } else {
      appSnackBar(context, "Product stock not available");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
          spacing: 0,
          runSpacing: 0,
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return ResponsiveCol(
      xs: 0, sm: 1, md: 1, lg: 2, xl: 2,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    final bloc = context.read<DashboardBloc>();

    return ResponsiveCol(
      xs: 12, sm: 12, md: 12, lg: 10, xl: 10,
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          context.read<AccountBloc>().add(FetchAccountList(context));
          context.read<CustomerBloc>().add(FetchCustomerList(context, dropdownFilter: "?status=1"));
        },
        child: BlocConsumer<CreatePosSaleBloc, CreatePosSaleState>(
          listener: (context, state) {
            if (state is CreatePosSaleLoading) {
              appLoader(context, "Creating PosSale, please wait...");
            } else if (state is CreatePosSaleSuccess) {
              Navigator.pop(context);
              appSnackBar(context, "Sale created successfully!", color: Colors.green);
              // Reset local state when form is cleared
              changeAmountController.clear();
              // bloc.add(ChangeDashboardScreen(index: 1));
              context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 2));

              // AppRoutes.push(context, RootScreen());
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildTopFormSection(bloc),
                    const SizedBox(height: 10),
                    _buildProductListSection(bloc),
                    const SizedBox(height: 10),
                    _buildChargesSection(bloc),
                    const SizedBox(height: 10),
                    _buildSummarySection(bloc),
                    const SizedBox(height: 10),
                    gapH20,
                    _buildActionButtons(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopFormSection(CreatePosSaleBloc bloc) {
    return ResponsiveRow(
      spacing: 20,
      runSpacing: 10,
      children: [
        ResponsiveCol(xs: 12, sm: 3, md: 3, lg: 3, xl: 3,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown(
                context: context,
                label: "Customer",
                hint: "Select Customer",
                isSearch: true,
                isNeedAll: false,
                isRequired: true,
                value: bloc.selectClintModel,
                itemList: [
                  CustomerActiveModel(name: 'Walk-in-customer', id: -1),
                ] + context.read<CustomerBloc>().activeCustomer,
                onChanged: (newVal) {
                  bloc.selectClintModel = newVal;
                  bloc.customType = (newVal?.id == -1) ? "Walking Customer" : "Saved Customer";
                  setState(() {});
                },
                validator: (value) => value == null ? 'Please select Customer' : null,
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
        ResponsiveCol(xs: 12, sm: 3, md: 3, lg: 3, xl: 3,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return AppDropdown(
                context: context,
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
                validator: (value) => value == null ? 'Please select Sales' : null,
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
        ResponsiveCol(xs: 12, sm: 2, md: 2, lg: 2, xl: 2,
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
            validator: (value) => value!.isEmpty ? 'Please enter date' : null,
            onTap: _selectDate,
          ),
        ),
        ResponsiveCol(xs: 12, sm: 3, md: 3, lg: 3, xl: 3, child: SizedBox()),
      ],
    );
  }

  Widget _buildProductListSection(CreatePosSaleBloc bloc) {
    return Column(
      children: products.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;

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
              ResponsiveCol(xs: 12, sm: 3, md: 3, lg: 3, xl: 3,
                child: BlocBuilder<ProductsBloc, ProductsState>(
                  builder: (context, state) {
                    return SizedBox(
                      child: AppDropdown<ProductModelStockModel>(
                        context: context,
                        isRequired: false,
                        isLabel: true,
                        isSearch: true,
                        label: "Product",
                        hint: "Select Product",
                        value: product["product"],
                        itemList: context.read<ProductsBloc>().productList,
                        onChanged: (newVal) => onProductChanged(index, newVal),
                        validator: (value) => value == null ? 'Please select Product' : null,
                        itemBuilder: (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.toString()),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ResponsiveCol(xs: 12, sm: 1, md: 1, lg: 1, xl: 1,
                child: TextFormField(
                  style: AppTextStyle.cardLevelText(context),
                  controller: controllers[index]?["price"],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text("Price", style: AppTextStyle.cardLevelText(context)),
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
                    contentPadding: const EdgeInsets.only(top: 13.0, bottom: 13.0, left: 12),
                    isDense: true,
                    hintText: "price",
                  ),
                  onChanged: (value) {
                    final parsedValue = double.tryParse(value) ?? 0;
                    products[index]["price"] = parsedValue;
                    updateTotal(index);
                  },
                ),
              ),
              ResponsiveCol(xs: 12, sm: 2, md: 2, lg: 2, xl: 2,
                child: CupertinoSegmentedControl<String>(
                  padding: EdgeInsets.zero,
                  children: {
                    'fixed': Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0,vertical: 7),
                      child: Text('TK', style: TextStyle(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        color: product["discount_type"] == 'fixed' ? Colors.white : Colors.black,
                      )),
                    ),
                    'percent': Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
                      child: Text('%', style: TextStyle(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        color: product["discount_type"] == 'percent' ? Colors.white : Colors.black,
                      )),
                    ),
                  },
                  onValueChanged: (value) {
                    products[index]["discount_type"] = value;
                    updateTotal(index);
                  },
                  groupValue: product["discount_type"],
                  unselectedColor: Colors.grey[300],
                  selectedColor: AppColors.primaryColor,
                  borderColor: AppColors.primaryColor,
                ),
              ),
              ResponsiveCol(xs: 12, sm: 1, md: 1, lg: 1, xl: 1,
                child: TextFormField(
                  controller: controllers[index]?["discount"],
                  style: AppTextStyle.cardLevelText(context),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    fillColor: AppColors.whiteColor,
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    contentPadding: const EdgeInsets.only(top: 13.0, bottom: 13.0, left: 10),
                    isDense: true,
                    hintText: "Discount",
                  ),
                  onChanged: (value) {
                    products[index]["discount"] = double.tryParse(value) ?? 0.0;
                    updateTotal(index);
                  },
                ),
              ),
              ResponsiveCol(xs: 12, sm: 1.5, md: 1.5, lg: 1.5, xl: 1.5,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        int? currentQuantity = int.tryParse(controllers[index]?["quantity"]?.text ?? "0");
                        if (currentQuantity != null && currentQuantity > 1) {
                          controllers[index]!["quantity"]!.text = (currentQuantity - 1).toString();
                          products[index]["quantity"] = controllers[index]!["quantity"]!.text;
                          updateTotal(index);
                        }
                      },
                      padding: EdgeInsets.zero,
                    ),
                    Text(controllers[index]!["quantity"]!.text, style: AppTextStyle.cardTitle(context)),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int currentQuantity = int.tryParse(controllers[index]!["quantity"]!.text) ?? 0;
                        controllers[index]!["quantity"]!.text = (currentQuantity + 1).toString();
                        products[index]["quantity"] = controllers[index]!["quantity"]!.text;
                        updateTotal(index);
                      },
                    ),
                  ],
                ),
              ),
              ResponsiveCol(xs: 12, sm: 1, md: 1, lg: 1, xl: 1,
                child: TextFormField(
                  style: AppTextStyle.cardLevelText(context),
                  controller: controllers[index]?["ticket_total"],
                  readOnly: true,
                  decoration: InputDecoration(
                    label: Text("Net Total", style: AppTextStyle.cardLevelText(context)),
                    fillColor: AppColors.whiteColor,
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    contentPadding: const EdgeInsets.only(top: 13.0, bottom: 13.0, left: 12),
                    isDense: true,
                    hintText: "ticket total",
                  ),
                ),
              ),
              ResponsiveCol(xs: 12, sm: 1, md: 1, lg: 1, xl: 1,
                child: TextFormField(
                  style: AppTextStyle.cardLevelText(context),
                  controller: controllers[index]?["total"],
                  readOnly: true,
                  decoration: InputDecoration(
                    label: Text("Total Amount", style: AppTextStyle.cardLevelText(context)),
                    fillColor: AppColors.whiteColor,
                    filled: true,
                    hintStyle: AppTextStyle.cardLevelText(context),
                    isCollapsed: true,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    contentPadding: const EdgeInsets.only(top: 13.0, bottom: 13.0, left: 12),
                    isDense: true,
                    hintText: "total",
                  ),
                ),
              ),
              ResponsiveCol(xs: 12, sm: 1, md: 1, lg: 1, xl: 1,
                child: IconButton(
                  icon: Icon(
                    product == products[products.length - 1] ? Icons.add : Icons.remove,
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
      spacing: 20,
      runSpacing: 10,
      children: [
        _buildChargeField("Overall Discount", selectedOverallDiscountType, bloc.discountOverAllController, (value) {
          setState(() {
            selectedOverallDiscountType = value;
            bloc.selectedOverallDiscountType = value;
          });
          _updateChangeAmount();
        }),
        _buildChargeField("Overall Vat", selectedOverallVatType, bloc.vatOverAllController, (value) {
          setState(() {
            selectedOverallVatType = value;
            bloc.selectedOverallVatType = value;
          });
          _updateChangeAmount();
        }),
        _buildChargeField("Service Charge", selectedOverallServiceChargeType, bloc.serviceChargeOverAllController, (value) {
          setState(() {
            selectedOverallServiceChargeType = value;
            bloc.selectedOverallServiceChargeType = value;
          });
          _updateChangeAmount();
        }),
        _buildChargeField("Delivery Charge", selectedOverallDeliveryType, bloc.deliveryChargeOverAllController, (value) {
          setState(() {
            selectedOverallDeliveryType = value;
            bloc.selectedOverallDeliveryType = value;
          });
          _updateChangeAmount();
        }),
      ],
    );
  }

  Widget _buildChargeField(
      String label,
      String selectedType,
      TextEditingController controller,
      Function(String) onTypeChanged,
      ) {
    return ResponsiveCol(xs: 12, sm: 3, md: 3, lg: 3, xl: 3,
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
                    'fixed': Text('TK', style: TextStyle(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      color: selectedType == 'fixed' ? Colors.white : Colors.black,
                    )),
                    'percent': Text('%', style: TextStyle(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      color: selectedType == 'percent' ? Colors.white : Colors.black,
                    )),
                  },
                  onValueChanged: onTypeChanged,
                  groupValue: selectedType,
                  unselectedColor: Colors.grey[300],
                  selectedColor: AppColors.primaryColor,
                  borderColor: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomInputFieldPayRoll(
                  isRequiredLevle: false,
                  controller: controller,
                  hintText: label,
                  fillColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        ResponsiveCol(xs: 12, sm: 5, md: 5, lg: 5, xl: 5,
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
        ResponsiveCol(xs: 12, sm: 5, md: 5, lg: 5, xl: 5,
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
          title: Text("With Money Receipt", style: AppTextStyle.headerTitle(context)),
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
                  hint: bloc.selectedPaymentMethod.isEmpty ? "Select Payment Method" : bloc.selectedPaymentMethod,
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
                        return item.acType?.toLowerCase() == bloc.selectedPaymentMethod.toLowerCase();
                      }).toList()
                          : state.list;

                      final selectedAccount = bloc.accountModel ?? (filteredList.isNotEmpty ? filteredList.first : null);
                      bloc.accountModel = selectedAccount;

                      return AppDropdown<AccountActiveModel>(
                        context: context,
                        label: "Account",
                        hint: bloc.accountModel == null ? "Select Account" : bloc.accountModel!.acName.toString(),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty ? 'Please enter Payable Amount' : null,
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
          onChanged: (value) => setState(() {}), keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
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
          onPressed: () async {},
          color: const Color(0xff800000),
        ),
        const SizedBox(width: 10),
        AppButton(name: 'Submit', onPressed: _submitForm),
        const SizedBox(width: 5),
      ],
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
      bloc.dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(pickedDate);
      setState(() {});
    }
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      final bloc = context.read<CreatePosSaleBloc>();

      var transferProducts = products.map((product) => {
        "product_id": int.tryParse(product["product_id"].toString()),
        "quantity": int.tryParse(product["quantity"].toString()),
        "unit_price": double.tryParse(product["price"].toString()),
        "discount": double.tryParse(product["discount"].toString()),
        "discount_type": product["discount_type"].toString(),
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
        "paid_amount": double.tryParse(bloc.payableAmount.text.trim() ?? "0") ?? 0,
      };

      if (isWalkInCustomer) {
        body.remove('customer_id');
      } else {
        body['customer_id'] = selectedCustomer?.id.toString() ?? '';
      }

      if (_isChecked == true) {
        body['payment_method'] = bloc.selectedPaymentMethod;
        body['account_id'] = bloc.accountModel?.acId.toString() ?? '';

        // if (calculateAllFinalTotal() <= double.parse(bloc.payableAmount.text)) {
          bloc.add(AddPosSale(body: body));
        // } else {
        //   appSnackBar(context, "Payable amount must be greater than or equal to net total", color: Colors.redAccent);
        // }
      } else {
        bloc.add(AddPosSale(body: body));
      }

      log(body.toString());
    }
  }
}