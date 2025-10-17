import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_inventory/feature/products/product/data/model/product_model.dart';
import 'dart:developer';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/app_snack_bar.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';

class CreatePosSalePage extends StatefulWidget {
  const CreatePosSalePage({super.key});

  @override
  _CreatePosSalePageState createState() => _CreatePosSalePageState();
}

class _CreatePosSalePageState extends State<CreatePosSalePage> {
// our stepper widget will start from first step
  int _activeCurrentStep = 0;

  @override
  void initState() {

    context.read<AccountBloc>().add(
          FetchAccountList(
            context,
          ),
        );

    // context.read<UserBloc>().add(
    //       FetchUserList(context, dropdownFilter: "?status=1"),
    //     );
    // context.read<CustomerBloc>().add(
    //       FetchCustomerList(context, dropdownFilter: "?status=1"),
    //     );
    super.initState();

    context.read<CreatePosSaleBloc>().dateEditingController.text =
        appWidgets.convertDateTimeDDMMYYYY(DateTime.now());

    context.read<CreatePosSaleBloc>().withdrawDateController.text =
        appWidgets.convertDateTimeDDMMYYYY(DateTime.now());
    addProduct(); // Initialize with one product row
  }

  TextEditingController changeAmountController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  String selectedOverallVatType = 'fixed';
  String selectedOverallDiscountType = 'fixed';
  String selectedOverallServiceChargeType = 'fixed';
  String selectedOverallDeliveryType = 'fixed';
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map<int, Map<String, TextEditingController>> controllers = {};

  @override
  void dispose() {
    for (var controllers in controllers.values) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  double calculateTotalForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      totalSum += product["total"];
    }
    return totalSum;
  }

  double overallTotal = 0;
  double discount = 0;
  double vat = 0;
  double serviceCharge = 0;
  double deliveryCharge = 0;
  double ticketTotal = 0;
  double specificDiscount = 0;

  void updateTotal(int index) {
    if (controllers[index] == null || products[index].isEmpty) {
      return; // Prevent errors if index is out of bounds
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
    ticketTotal = total;
    specificDiscount = discount;

    if (discountType == 'fixed') {
      total -= discount;
    } else if (discountType == 'percentage') {
      final discountAmount = (total * (discount / 100));
      total -= discountAmount;
    }

    total = total < 0 ? 0.0 : total;

    controllers[index]?["total"]?.text = total.toStringAsFixed(2);

    setState(() {
      products[index]["total"] = total;
      overallTotal = calculateTotalForAllProducts();
    });
  }

  double calculateDiscountTotal() {
    double total = calculateTotalForAllProducts();

    // Retrieve values from the text controllers

    discount = double.tryParse(
            context.read<CreatePosSaleBloc>().discountOverAllController.text) ??
        0.0;

    // Apply Discount
    if (selectedOverallDiscountType == 'percentage') {
      discount = (total * (discount / 100));
    }
    total -= discount;

    return total;
  }

  void _updateChangeAmount() {
    // final payableAmount = double.tryParse(
    //         context.read<PosSaleInstantBloc>().payableAmount.text) ??
    //     0.0;
    // final changeAmount = calculateAllFinalTotal() - payableAmount;
    //
    // setState(() {
    //   changeAmountController.text = changeAmount.toStringAsFixed(2);
    // });
  }

  double calculateVatTotal() {
    double total = calculateTotalForAllProducts();

    // Retrieve values from the text controllers
    vat = double.tryParse(
            context.read<CreatePosSaleBloc>().vatOverAllController.text) ??
        0.0;

    // Apply VAT
    if (selectedOverallVatType == 'percentage') {
      vat = (total * (vat / 100));
    }
    total += vat;

    return total;
  }

  double calculateDeliveryTotal() {
    double total = calculateTotalForAllProducts();

    // Retrieve values from the text controllers

    deliveryCharge = double.tryParse(context
            .read<CreatePosSaleBloc>()
            .deliveryChargeOverAllController
            .text) ??
        0.0;

    // Apply Delivery Charge
    if (selectedOverallDeliveryType == 'percentage') {
      deliveryCharge = (total * (deliveryCharge / 100));
    }
    total += deliveryCharge;

    return total;
  }

  double calculateServiceChargeTotal() {
    double total = calculateTotalForAllProducts();

    serviceCharge = double.tryParse(context
            .read<CreatePosSaleBloc>()
            .serviceChargeOverAllController
            .text) ??
        0.0;

    if (selectedOverallServiceChargeType == 'percentage') {
      serviceCharge = (total * (serviceCharge / 100));
    }
    total += serviceCharge;
    return total;
  }

  double calculateAllFinalTotal() {
    // Step 1: Calculate the total for all products
    double total = calculateTotalForAllProducts();

    // Step 2: Apply discount (check if percent or fixed)
    double discount = double.tryParse(
            context.read<CreatePosSaleBloc>().discountOverAllController.text) ??
        0.0;
    if (selectedOverallDiscountType == 'percentage') {
      discount = calculateTotalForAllProducts() * (discount / 100);
    } // Fixed discount does not change
    total -= discount;

    // Step 3: Apply VAT (check if percent or fixed)
    double vat = double.tryParse(
            context.read<CreatePosSaleBloc>().vatOverAllController.text) ??
        0.0;
    if (selectedOverallVatType == 'percentage') {
      vat = calculateTotalForAllProducts() * (vat / 100);
    }
    total += vat;

    // Step 4: Apply Delivery Charge (check if percent or fixed)
    double deliveryCharge = double.tryParse(context
            .read<CreatePosSaleBloc>()
            .deliveryChargeOverAllController
            .text) ??
        0.0;
    if (selectedOverallDeliveryType == 'percentage') {
      deliveryCharge = calculateTotalForAllProducts() * (deliveryCharge / 100);
    }
    total += deliveryCharge;

    // Step 5: Apply Service Charge (check if percent or fixed)
    double serviceCharge = double.tryParse(context
            .read<CreatePosSaleBloc>()
            .serviceChargeOverAllController
            .text) ??
        0.0;
    if (selectedOverallServiceChargeType == 'percentage') {
      serviceCharge = calculateTotalForAllProducts() * (serviceCharge / 100);
    }
    total += serviceCharge;

    // Final calculated total
    return total;
  }

  void addProduct() {
    setState(() {
      final newIndex = products.length;
      products.add({
        "id": newIndex,
        "product": null,
        "product_id": null,
        "discount_type": 'fixed', // Default discount type for new product
        "product_name": "",
        "price": 0,
        "stock": 0,
        "quantity": 1,
        "discount": 0,
        "ticket_total": 0,
        "total": 0,
      });

      controllers[newIndex] = {
        "quantity": TextEditingController(text: "1"),
        "price": TextEditingController(text: "0"),
        "discount": TextEditingController(text: "0"),
        "ticket_total": TextEditingController(text: "0"),
        "total": TextEditingController(text: "0"),
      };
    });
  }

  void removeProduct(int index) {
    setState(() {
      // Check if the index exists in the controllers map
      if (controllers.containsKey(index)) {
        // Dispose of the controller at the given index
        for (var controller in controllers[index]!.values) {
          controller.dispose();
        }
        controllers.remove(index);
      }

      // Remove the product from the list
      products.removeAt(index);

      // Create a temporary map to handle the re-indexing
      Map<int, Map<String, TextEditingController>> newControllers = {};
      controllers.forEach((key, value) {
        if (key > index) {
          newControllers[key - 1] = value;
        } else {
          newControllers[key] = value;
        }
      });

      // Update the controllers with the new map
      controllers.clear();
      controllers.addAll(newControllers);
    });
  }

  bool _isChecked = false;

  void onProductChanged(int index, ProductModel? newVal) {
    if (newVal == null) return;

    setState(() {
      final totalStock = newVal.stockQty ?? 0; // Treat null as 0

      if (totalStock > 0) {
        // Valid product, update the list
        products[index]["product"] = newVal;
        products[index]["product_id"] = newVal.id; // Set the product_id

        // Update price based on the selected product
        final productPrice = newVal.sellingPrice;
        controllers[index]!["price"]!.text = productPrice.toString();
        products[index]["price"] = productPrice;

        // Reset the discount and total fields
        controllers[index]!["discount"]!.text = "0";
        products[index]["discount"] = 0;

        // Recalculate the total based on new price and quantity
        updateTotal(index);
      } else {
        // Product stock not available, clear the selection
        products[index]["product"] = null; // Clear product selection
        appSnackBar(context, "Product stock not available");
      }
    });
  }

  double calculateTotalTicketForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      totalSum += product["ticket_total"] ?? 0; // Ensures null safety
    }
    return totalSum;
  }

  double calculateSpecificDiscountTotal() {
    double discountSum = 0;
    for (var product in products) {
      double productDiscount = (product["discount"] ?? 0).toDouble();
      double ticketTotal = (product["ticket_total"] ?? 0).toDouble();

      if (product["discount_type"] == 'percentage') {
        productDiscount = ticketTotal * (productDiscount / 100);
      }

      discountSum += productDiscount;
    }
    return discountSum;
  }




    @override
    Widget build(BuildContext context) {
      final isBigScreen =
          Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
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
        xs: 0,
        sm: 1,
        md: 1,
        lg: 2,
        xl: 2,
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: const Sidebar(),
        ),
      );
    }

    Widget _buildContentArea(bool isBigScreen) {
      return ResponsiveCol(
        xs: 12,
        sm: 12,
        md: 12,
        lg: 10,
        xl: 10,
        child:RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            context.read<AccountBloc>().add(
              FetchAccountList(
                context,
              ),
            );

            // context.read<StaffListBloc>().add(
            //       FetchStaffList(context,dropdownFilter: "?status=1"),
            //     );
            context.read<CustomerBloc>().add(
              FetchCustomerList(context, dropdownFilter: "?status=1"),
            );
          },
          child: BlocConsumer<CreatePosSaleBloc, CreatePosSaleState>(
            listener: (context, state) {
              if (state is CreatePosSaleLoading) {
                appLoader(context, "Creating PosSale, please wait...");
              } else if (state is CreatePosSaleSuccess) {
                Navigator.pop(context); // Close loader dialog
                // AppRoutes.pushReplacement(context, const PosSaleScreen());
              } else if (state is CreatePosSaleFailed) {
                Navigator.pop(context); // Close loader dialog
                appAlertDialog(context, state.content,
                    title: state.title,
                    actions: [
                      TextButton(
                          onPressed: () => AppRoutes.pop(context),
                          child: const Text("Dismiss"))
                    ]);
              }
            },
            builder: (context, state) {
              return Column(children: [

                if (context.read<CreatePosSaleBloc>().customType.toString() ==
                    "Saved Customer") ...[
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      return AppDropdown(
                        context: context,
                        label: "Customer",
                        hint: "Select Customer",
                        isSearch: true,
                        isNeedAll: false,
                        isRequired: true,
                        value:
                        context.read<CreatePosSaleBloc>().selectClintModel,
                        itemList: context.read<CustomerBloc>().list,
                        onChanged: (newVal) {
                          context.read<CreatePosSaleBloc>().selectClintModel =
                              newVal;

                          context.read<ProductsBloc>().add(
                            FetchProductsList(context,
                                filterApiURL:
                                "?filter=&due=true&customer_id=${newVal?.id.toString()}"),
                          );
                        },
                        validator: (value) {
                          return value == null
                              ? 'Please select Customer '
                              : null;
                        },
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
                ] else ...[
                  CustomInputField(
                    isRequiredLable: true,
                    controller: context
                        .read<CreatePosSaleBloc>()
                        .customerPhoneController,
                    hintText: 'Client Phone',
                    fillColor: Colors.white,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter Client Phone' : null,
                    onChanged: (value) {
                      setState(() {});
                    },
                    autofillHints: '',
                  ),
                ],
                // BlocBuilder<UserBloc, UserState>(
                //   builder: (context, state) {
                //     final userBloc = context.read<UserBloc>();
                //     final createPosSaleBloc = context.read<CreatePosSaleBloc>();
                //     if (createPosSaleBloc.selectSalesModel == null &&
                //         userBloc.list.isNotEmpty) {
                //       createPosSaleBloc.selectSalesModel = userBloc.list.last;
                //     }
                //
                //     return AppDropdown(
                //       label: "Sales By",
                //       context: context,
                //       hint: createPosSaleBloc.selectSalesModel == null
                //           ? "Select Sales By"
                //           : createPosSaleBloc.selectSalesModel!.userName
                //               .toString(),
                //       isSearch: true,
                //       isLabel: false,
                //       isRequired: true,
                //       isNeedAll: false,
                //       value: createPosSaleBloc.selectSalesModel,
                //       itemList: userBloc.list,
                //       onChanged: (newVal) {
                //         // Update the selected value in the bloc
                //         createPosSaleBloc.selectSalesModel = newVal;
                //       },
                //       validator: (value) {
                //         return value == null ? 'Please select Sales By' : null;
                //       },
                //       itemBuilder: (item) => DropdownMenuItem(
                //         value: item,
                //         child: Text(
                //           item.toString(),
                //           style: const TextStyle(
                //             color: AppColors.blackColor,
                //             fontFamily: 'Quicksand',
                //             fontWeight: FontWeight.w300,
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                CustomInputField(
                  radius: 10,
                  isRequired: true,
                  readOnly: true,
                  controller:
                  context.read<CreatePosSaleBloc>().dateEditingController,
                  hintText: 'Purchase Date',
                  keyboardType: TextInputType.datetime,
                  autofillHints: AutofillHints.name,
                  bottom: 15.0,
                  fillColor: AppColors.whiteColor,
                  validator: (value) {
                    return value!.isEmpty ? 'Please enter date' : null;
                  },
                  onTap: _selectDate,
                ),
                const SizedBox(height: 10),
                Form(
                  key: formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...products.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;

                        // Initialize controllers if not already initialized
                        if (!controllers.containsKey(index)) {
                          controllers[index] = {
                            "quantity": TextEditingController(
                                text: product["quantity"].toString()),
                            "price": TextEditingController(
                                text: product["price"].toString()),
                            "discount": TextEditingController(
                                text: product["discount"].toString()),
                            "total": TextEditingController(
                                text: product["total"].toString()),
                            "ticket_total": TextEditingController(
                                text: product["ticket_total"].toString()),
                          };
                        }

                        return Container(
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  BlocBuilder<ProductsBloc, ProductsState>(
                                    builder: (context, state) {
                                      return Expanded(
                                        flex: 6,
                                        child: AppDropdown<ProductModel>(
                                          context: context,
                                          isRequired: false,
                                          isLabel: true,
                                          isSearch: true,
                                          label: "Product",
                                          hint: "Select Product",
                                          value: product["product"],
                                          itemList:
                                          context.read<ProductsBloc>().list,
                                          onChanged: (newVal) =>
                                              onProductChanged(index, newVal),
                                          validator: (value) => value == null
                                              ? 'Please select Product'
                                              : null,
                                          itemBuilder: (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item.toString()),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 1,
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
                                        if (product ==
                                            products[products.length - 1]) {
                                          addProduct();
                                        } else {
                                          removeProduct(product["id"]);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      style: AppTextStyle.cardLevelText(context),
                                      controller: controllers[index]?["total"]
                                        ?..text =
                                            products[index]["total"]?.toString() ??
                                                "0",
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        label: Text(
                                          "Total Amount",
                                          style: AppTextStyle.cardLevelText(context),
                                        ),
                                        fillColor: AppColors.whiteColor,
                                        filled: true,
                                        hintStyle:
                                        AppTextStyle.cardLevelText(context),
                                        isCollapsed: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            top: 10.0, bottom: 10.0, left: 12),
                                        isDense: true,
                                        hintText: "total",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          products[index]["total"] =
                                              double.tryParse(value) ?? 0.0;
                                          updateTotal(
                                              index); // Recalculate total when discount value changes
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      style: AppTextStyle.cardLevelText(context),
                                      controller: controllers[index]?["ticket_total"]
                                        ?..text = products[index]["ticket_total"]
                                            ?.toString() ??
                                            "0",
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        label: Text(
                                          "Ticket Total",
                                          style: AppTextStyle.cardLevelText(context),
                                        ),
                                        fillColor: AppColors.whiteColor,
                                        filled: true,
                                        hintStyle:
                                        AppTextStyle.cardLevelText(context),
                                        isCollapsed: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            top: 10.0, bottom: 10.0, left: 12),
                                        isDense: true,
                                        hintText: "ticket total",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          products[index]["ticket_total"] =
                                              double.tryParse(value) ?? 0.0;
                                          updateTotal(
                                              index); // Recalculate total when discount value changes
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      style: AppTextStyle.cardLevelText(context),
                                      controller: controllers[index]?["price"],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        label: Text(
                                          "Price ",
                                          style: AppTextStyle.cardLevelText(context),
                                        ),
                                        fillColor: AppColors.whiteColor,
                                        filled: true,
                                        hintStyle:
                                        AppTextStyle.cardLevelText(context),
                                        isCollapsed: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            top: 10.0, bottom: 10.0, left: 12),
                                        isDense: true,
                                        hintText: "price",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter price';
                                        }

                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          final parsedValue =
                                              double.tryParse(value) ?? 1;
                                          products[index]["price"] = parsedValue;
                                          updateTotal(
                                              index); // Update total after changing quantity
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: CupertinoSegmentedControl<String>(
                                      padding: EdgeInsets.zero,
                                      children: {
                                        'fixed': Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 2.0),
                                          child: Text(
                                            'Fixed',
                                            style: TextStyle(
                                              fontFamily:
                                              GoogleFonts.playfairDisplay()
                                                  .fontFamily,
                                              color: products[index]
                                              ["discount_type"] ==
                                                  'fixed'
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        'percentage': Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7.0, horizontal: 2.0),
                                          child: Text(
                                            ' Percent',
                                            style: TextStyle(
                                              fontFamily:
                                              GoogleFonts.playfairDisplay()
                                                  .fontFamily,
                                              color: products[index]
                                              ["discount_type"] ==
                                                  'percentage'
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      },
                                      onValueChanged: (value) {
                                        setState(() {
                                          products[index]["discount_type"] = value;
                                          updateTotal(
                                              index); // Recalculate total when discount type changes
                                        });
                                      },
                                      groupValue: products[index]["discount_type"],
                                      unselectedColor: Colors.grey[300],
                                      selectedColor: AppColors.primaryColor,
                                      borderColor: AppColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: controllers[index]?["discount"],
                                      style: AppTextStyle.cardLevelText(context),
                                      keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                      decoration: InputDecoration(
                                        fillColor: AppColors.whiteColor,
                                        filled: true,
                                        hintStyle:
                                        AppTextStyle.cardLevelText(context),
                                        isCollapsed: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            top: 10.0, bottom: 10.0, left: 10),
                                        isDense: true,
                                        hintText: "Discount",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          products[index]["discount"] =
                                              double.tryParse(value) ?? 0.0;
                                          updateTotal(
                                              index); // Recalculate total when discount value changes
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              // Use a condition that explicitly checks the parsed integer result.
                                              int? currentQuantity = int.tryParse(
                                                  controllers[index]?["quantity"]
                                                      ?.text ??
                                                      "0");
                                              if (currentQuantity != null &&
                                                  currentQuantity > 1) {
                                                controllers[index]!["quantity"]!
                                                    .text =
                                                    (currentQuantity - 1).toString();
                                                products[index]["quantity"] =
                                                    controllers[index]!["quantity"]!
                                                        .text;
                                                if (kDebugMode) {
                                                  print(products[index]["quantity"] =
                                                      controllers[index]!["quantity"]!
                                                          .text);
                                                }
                                                updateTotal(
                                                    index); // Update total if quantity changes
                                              }
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                        ),
                                        Text(
                                          controllers[index]!["quantity"]!.text,
                                          // Display the current quantity
                                          style: AppTextStyle.cardTitle(context),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              int currentQuantity = int.tryParse(
                                                  controllers[index]!["quantity"]!
                                                      .text) ??
                                                  0;
                                              controllers[index]!["quantity"]!.text =
                                                  (currentQuantity + 1).toString();
                                              products[index]["quantity"] =
                                                  controllers[index]!["quantity"]!
                                                      .text;
                                              updateTotal(
                                                  index); // Update total if quantity changes
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Form(
                  key: formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vat, Service Charge, Delivery and Discount Information",
                        style: AppTextStyle.cardLevelText(context),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Ticket Total",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      calculateTotalTicketForAllProducts()
                                          .toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(context),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Specific Discount (-)",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      calculateSpecificDiscountTotal()
                                          .toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(context),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Sub Total",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      calculateTotalForAllProducts()
                                          .toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(context),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Discount (-)",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      discount.toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(context),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Vat (+)",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    vat.toStringAsFixed(2),
                                    style: AppTextStyle.cardLevelText(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Service Charge (+)	",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      serviceCharge.toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(context),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Delivery Charge (+)	",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      deliveryCharge.toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(context),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Net Total",
                                      style: AppTextStyle.cardLevelHead(context),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      calculateAllFinalTotal().toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(context),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: CupertinoSegmentedControl<String>(
                              padding: EdgeInsets.zero,
                              children: {
                                'fixed': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 2.0),
                                  child: Text(
                                    'Discount Fixed',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color: selectedOverallDiscountType == 'fixed'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                'percentage': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0.0),
                                  child: Text(
                                    ' Percent',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color:
                                      selectedOverallDiscountType == 'percentage'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              },
                              onValueChanged: (value) {
                                setState(() {
                                  selectedOverallDiscountType = value;
                                  calculateDiscountTotal();
                                  _updateChangeAmount(); // R
                                  // Recalculate total when discount type changes
                                });
                              },
                              groupValue: selectedOverallDiscountType,
                              unselectedColor: Colors.grey[300],
                              selectedColor: AppColors.primaryColor,
                              borderColor: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 2,
                            child: CustomInputFieldPayRoll(
                              isRequiredLevle: false,
                              controller: context
                                  .read<CreatePosSaleBloc>()
                                  .discountOverAllController,
                              hintText: 'Discount ',
                              fillColor: Colors.white,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              // validator: (value) =>
                              //     value!.isEmpty ? 'Please enter Vat ' : null,
                              onChanged: (value) {
                                calculateDiscountTotal();
                                _updateChangeAmount(); // R
                                setState(() {});
                              },
                              autofillHints: '',
                              levelText: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: CupertinoSegmentedControl<String>(
                              padding: EdgeInsets.zero,
                              children: {
                                'fixed': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 7.0, horizontal: 0.0),
                                  child: Text(
                                    'Vat Fixed',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color: selectedOverallVatType == 'fixed'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                'percentage': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 7.0, horizontal: 0.0),
                                  child: Text(
                                    ' Vat Percent',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color: selectedOverallVatType == 'percentage'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              },
                              onValueChanged: (value) {
                                setState(() {
                                  selectedOverallVatType = value;
                                  calculateVatTotal();
                                  _updateChangeAmount(); // R
                                  // Recalculate total when discount type changes
                                });
                              },
                              groupValue: selectedOverallVatType,
                              unselectedColor: Colors.grey[300],
                              selectedColor: AppColors.primaryColor,
                              borderColor: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 2,
                            child: CustomInputFieldPayRoll(
                              isRequiredLevle: false,
                              controller: context
                                  .read<CreatePosSaleBloc>()
                                  .vatOverAllController,
                              hintText: 'Vat ',
                              fillColor: Colors.white,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) =>
                              value!.isEmpty ? 'Please enter Vat ' : null,
                              onChanged: (value) {
                                calculateVatTotal();
                                setState(() {});
                              },
                              autofillHints: '',
                              levelText: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: CupertinoSegmentedControl<String>(
                              padding: EdgeInsets.zero,
                              children: {
                                'fixed': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  child: Text(
                                    'Service Fixed',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color:
                                      selectedOverallServiceChargeType == 'fixed'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                'percentage': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 0.0),
                                  child: Text(
                                    '  Percent',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color: selectedOverallServiceChargeType ==
                                          'percentage'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              },
                              onValueChanged: (value) {
                                setState(() {
                                  selectedOverallServiceChargeType = value;
                                  calculateServiceChargeTotal();
                                  _updateChangeAmount(); // R
                                  // Recalculate total when discount type changes
                                });
                              },
                              groupValue: selectedOverallServiceChargeType,
                              unselectedColor: Colors.grey[300],
                              selectedColor: AppColors.primaryColor,
                              borderColor: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 2,
                            child: CustomInputFieldPayRoll(
                              isRequiredLevle: false,
                              controller: context
                                  .read<CreatePosSaleBloc>()
                                  .serviceChargeOverAllController,
                              hintText: 'Service  Charge ',
                              fillColor: Colors.white,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              // validator: (value) => value!.isEmpty
                              //     ? 'Please enter Service  Charge '
                              //     : null,
                              onChanged: (value) {
                                calculateServiceChargeTotal();
                                setState(() {});
                              },
                              autofillHints: '',
                              levelText: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: CupertinoSegmentedControl<String>(
                              padding: EdgeInsets.zero,
                              children: {
                                'fixed': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 2.0),
                                  child: Text(
                                    'Delivery Fixed',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color: selectedOverallDeliveryType == 'fixed'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                'percentage': Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 2.0),
                                  child: Text(
                                    ' Percent',
                                    style: TextStyle(
                                      fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                      color:
                                      selectedOverallDeliveryType == 'percentage'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              },
                              onValueChanged: (value) {
                                setState(() {
                                  selectedOverallDeliveryType = value;
                                  calculateDeliveryTotal();
                                  // Recalculate total when discount type changes
                                });
                              },
                              groupValue: selectedOverallDeliveryType,
                              unselectedColor: Colors.grey[300],
                              selectedColor: AppColors.primaryColor,
                              borderColor: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 2,
                            child: CustomInputFieldPayRoll(
                              isRequiredLevle: false,
                              controller: context
                                  .read<CreatePosSaleBloc>()
                                  .deliveryChargeOverAllController,
                              hintText: 'Delivery ',
                              fillColor: Colors.white,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              // validator: (value) =>
                              //     value!.isEmpty ? 'Please enter Delivery ' : null,
                              onChanged: (value) {
                                calculateDeliveryTotal();
                                setState(() {});
                              },
                              autofillHints: '',
                              levelText: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "With Money Receipt",
                          style: AppTextStyle.headerTitle(context),
                        ),
                        value: _isChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isChecked = newValue ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Adjusts the position of the checkbox
                      ),
                      _isChecked
                          ? Column(
                        children: [
                          // Row(
                          //   children: [
                          //     Expanded(
                          //         child: AppDropdown(
                          //       context: context,
                          //       label: "Payment Method",
                          //       hint: context
                          //               .read<MoneyReceiptBloc>()
                          //               .selectedPaymentMethod
                          //               .isEmpty
                          //           ? "Select Payment Method"
                          //           : context
                          //               .read<MoneyReceiptBloc>()
                          //               .selectedPaymentMethod,
                          //       isLabel: false,
                          //       isRequired: true,
                          //       isNeedAll: false,
                          //       value: context
                          //               .read<MoneyReceiptBloc>()
                          //               .selectedPaymentMethod
                          //               .isEmpty
                          //           ? null
                          //           : context
                          //               .read<MoneyReceiptBloc>()
                          //               .selectedPaymentMethod,
                          //       itemList: ["Cheque"] +
                          //           context.read<ExpenseBloc>().paymentMethod,
                          //       onChanged: (newVal) {
                          //         // Update the selected payment method in the bloc
                          //         context
                          //                 .read<MoneyReceiptBloc>()
                          //                 .selectedPaymentMethod =
                          //             newVal.toString();
                          //
                          //         setState(() {
                          //           // Trigger a rebuild to update the filtered accounts
                          //         });
                          //       },
                          //       validator: (value) {
                          //         return value == null
                          //             ? 'Please select a payment method'
                          //             : null;
                          //       },
                          //       itemBuilder: (item) => DropdownMenuItem(
                          //         value: item,
                          //         child: Text(
                          //           item.toString(),
                          //           style: const TextStyle(
                          //             color: AppColors.blackColor,
                          //             fontFamily: 'Quicksand',
                          //             fontWeight: FontWeight.w300,
                          //           ),
                          //         ),
                          //       ),
                          //     )),
                          //     const SizedBox(
                          //       width: 5,
                          //     ),
                          //     context
                          //                 .read<MoneyReceiptBloc>()
                          //                 .selectedPaymentMethod
                          //                 .toString() !=
                          //             "Cheque"
                          //         ? Expanded(
                          //             child: BlocBuilder<AccountBloc,
                          //                 AccountState>(
                          //               builder: (context, state) {
                          //                 if (state is AccountListLoading) {
                          //                   return const Center(
                          //                       child:
                          //                           CircularProgressIndicator());
                          //                 } else if (state
                          //                     is AccountListSuccess) {
                          //                   final filteredList = context
                          //                           .read<MoneyReceiptBloc>()
                          //                           .selectedPaymentMethod
                          //                           .isNotEmpty
                          //                       ? state.list.where((item) {
                          //                           return item.acType
                          //                                   ?.toLowerCase() ==
                          //                               context
                          //                                   .read<
                          //                                       MoneyReceiptBloc>()
                          //                                   .selectedPaymentMethod
                          //                                   .toLowerCase();
                          //                         }).toList()
                          //                       : state.list;
                          //
                          //                   // Ensure the first item is selected if no selection exists
                          //                   final selectedAccount = context
                          //                           .read<CreatePosSaleBloc>()
                          //                           .accountModel ??
                          //                       (filteredList.isNotEmpty
                          //                           ? filteredList.first
                          //                           : null);
                          //                   context
                          //                       .read<CreatePosSaleBloc>()
                          //                       .accountModel = selectedAccount;
                          //
                          //                   return AppDropdown<AccountModel>(
                          //                     context: context,
                          //                     label: "Account",
                          //                     hint: context
                          //                                 .read<
                          //                                     CreatePosSaleBloc>()
                          //                                 .accountModel ==
                          //                             null
                          //                         ? "Select Account"
                          //                         : context
                          //                             .read<CreatePosSaleBloc>()
                          //                             .accountModel!
                          //                             .acName
                          //                             .toString(),
                          //                     isLabel: false,
                          //                     isRequired: true,
                          //                     isNeedAll: false,
                          //                     value: selectedAccount,
                          //                     itemList: filteredList,
                          //                     onChanged: (newVal) {
                          //                       context
                          //                           .read<CreatePosSaleBloc>()
                          //                           .accountModel = newVal;
                          //                     },
                          //                     validator: (value) {
                          //                       return value == null
                          //                           ? 'Please select an account'
                          //                           : null;
                          //                     },
                          //                     itemBuilder: (item) =>
                          //                         DropdownMenuItem(
                          //                       value: item,
                          //                       child: Text(
                          //                         item.toString(),
                          //                         style: const TextStyle(
                          //                           color: AppColors.blackColor,
                          //                           fontFamily: 'Quicksand',
                          //                           fontWeight: FontWeight.w300,
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   );
                          //                 } else if (state
                          //                     is AccountListFailed) {
                          //                   return Center(
                          //                       child: Text(
                          //                           'Failed to load accounts: ${state.content}'));
                          //                 } else {
                          //                   return Container();
                          //                 }
                          //               },
                          //             ),
                          //           )
                          //         : Container()
                          //   ],
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomInputField(
                                  isRequiredLable: false,
                                  controller: changeAmountController,
                                  hintText: 'Change Amount',
                                  fillColor: Colors.white,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                  readOnly: true,
                                  onChanged: (value) {
                                    setState(() {});
                                    calculateAllFinalTotal();
                                    _updateChangeAmount(); // R
                                  },
                                  autofillHints: '',
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                flex: 2,
                                child: CustomInputField(
                                  isRequiredLable: false,
                                  // controller: context
                                  //     .read<PosSaleInstantBloc>()
                                  //     .payableAmount,
                                  hintText: 'Payable Amount',
                                  fillColor: Colors.white,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter Payable Amount'
                                      : null,
                                  onChanged: (value) {
                                    setState(
                                            () {}); // Trigger rebuild to update Change Amount
                                    _updateChangeAmount(); // Recalculate the change amount
                                  },
                                  autofillHints: '',
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : Container(),
                      // context
                      //             .read<MoneyReceiptBloc>()
                      //             .selectedPaymentMethod
                      //             .toString() !=
                      //         "Cheque"
                      //     ? Container()
                      //     : Column(
                      //         children: [
                      //           CustomInputField(
                      //             isRequiredLable: true,
                      //             isRequired: true,
                      //             controller: context
                      //                 .read<CreatePosSaleBloc>()
                      //                 .bankNameController,
                      //             hintText: 'Bank Name',
                      //             fillColor: const Color.fromARGB(255, 255, 255, 255),
                      //             keyboardType: TextInputType.text,
                      //             autofillHints: AutofillHints.telephoneNumber,
                      //             validator: (value) {
                      //               return value!.isEmpty
                      //                   ? 'Please enter bank name '
                      //                   : null;
                      //             },
                      //             onChanged: (value) {
                      //               return null;
                      //             },
                      //           ),
                      //           CustomInputField(
                      //             isRequiredLable: true,
                      //             isRequired: true,
                      //             controller: context
                      //                 .read<CreatePosSaleBloc>()
                      //                 .chequeNumberController,
                      //             hintText: 'Cheque Number',
                      //             fillColor: const Color.fromARGB(255, 255, 255, 255),
                      //             keyboardType: TextInputType.number,
                      //             autofillHints: AutofillHints.telephoneNumber,
                      //             validator: (value) {
                      //               return value!.isEmpty
                      //                   ? 'Please enter cheque number '
                      //                   : null;
                      //             },
                      //             onChanged: (value) {
                      //               return null;
                      //             },
                      //           ),
                      //           CustomInputField(
                      //             isRequiredLable: true,
                      //             isRequired: true,
                      //             controller: context
                      //                 .read<CreatePosSaleBloc>()
                      //                 .withdrawDateController,
                      //             hintText: 'Withdraw Date',
                      //             fillColor: const Color.fromARGB(255, 255, 255, 255),
                      //             readOnly: true,
                      //             keyboardType: TextInputType.text,
                      //             autofillHints: AutofillHints.telephoneNumber,
                      //             validator: (value) {
                      //               return value!.isEmpty
                      //                   ? 'Please enter Withdraw Date '
                      //                   : null;
                      //             },
                      //             onTap: () async {
                      //               FocusScope.of(context).requestFocus(
                      //                   FocusNode()); // Close the keyboard
                      //               DateTime? pickedDate = await showDatePicker(
                      //                 context: context,
                      //                 initialDate: DateTime.now(),
                      //                 firstDate: DateTime(1900),
                      //                 lastDate: DateTime.now(),
                      //               );
                      //               if (pickedDate != null) {
                      //                 context
                      //                         .read<CreatePosSaleBloc>()
                      //                         .withdrawDateController
                      //                         .text =
                      //                     appWidgets
                      //                         .convertDateTimeDDMMYYYY(pickedDate);
                      //                 // Format the date
                      //               }
                      //             },
                      //             onChanged: (value) {
                      //               return null;
                      //             },
                      //           ),
                      //         ],
                      //       ),
                      CustomInputField(
                        isRequiredLable: true,
                        controller:
                        context.read<CreatePosSaleBloc>().remarkController,
                        hintText: 'Remark ',
                        fillColor: Colors.white,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter Service  Charge ' : null,
                        onChanged: (value) {
                          setState(() {});
                        },
                        autofillHints: '',
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],);
            },
          ),
        )
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
        context.read<CreatePosSaleBloc>().dateEditingController.text =
            appWidgets.convertDateTimeDDMMYYYY(pickedDate);
      });
    }
  }

  void _submitForm() {
    if (formKey1.currentState!.validate()) {
      var transferProducts = products
          .map((product) => {
                "product_id": int.tryParse(product["product_id"].toString()),
                "quantity": int.tryParse(product["quantity"].toString()),
                "unit_price": double.tryParse(product["price"].toString()),
                "discount": double.tryParse(product["discount"].toString()),
                "discount_type": product["discount_type"].toString(),
              })
          .toList();
      Map<String, dynamic> body = {
        "type": "normal_sale",


        "sale_date": appWidgets.convertDateTime(
            DateFormat("dd-MM-yyyy").parse(
                context
                    .read<CreatePosSaleBloc>()
                    .dateEditingController
                    .text
                    .trim(),
                true),
            "yyyy-MM-dd"),

        // "sale_by":
        //     context.read<CreatePosSaleBloc>().selectSalesModel?.id.toString() ??
        //         '',
        "vat": context
                .read<CreatePosSaleBloc>()
                .discountOverAllController
                .text
                .isEmpty
            ? 0
            : double.tryParse(context
                .read<CreatePosSaleBloc>()
                .discountOverAllController
                .text),
        "service_charge": context
                .read<CreatePosSaleBloc>()
                .serviceChargeOverAllController
                .text
                .isEmpty
            ? 0
            : double.tryParse(context
                .read<CreatePosSaleBloc>()
                .serviceChargeOverAllController
                .text),
        "delivery_charge": context
                .read<CreatePosSaleBloc>()
                .deliveryChargeOverAllController
                .text
                .isEmpty
            ? 0
            : double.tryParse(context
                .read<CreatePosSaleBloc>()
                .deliveryChargeOverAllController
                .text),
        "change_amount": changeAmountController.text,

        "remark": context.read<CreatePosSaleBloc>().remarkController.text,
        "invoice_item": transferProducts,
        // Convert list to JSON string
        "overall_discount": context
                .read<CreatePosSaleBloc>()
                .discountOverAllController
                .text
                .isEmpty
            ? 0.0
            : double.tryParse(context
                .read<CreatePosSaleBloc>()
                .discountOverAllController
                .text),
        "customer_type": context
            .read<CreatePosSaleBloc>()
            .customType
            .toString()
            .toLowerCase()
            .split(" ")
            .join("_"),
        "overall_discount_type": selectedOverallDiscountType.toLowerCase(),
        "with_money_receipt": _isChecked ? "Yes" : "No",
      };

      if (context
              .read<CreatePosSaleBloc>()
              .customType
              .toString()
              .toLowerCase()
              .split(" ")
              .join("_") ==
          "walking_customer") {
        body['phone_number'] =
            context.read<CreatePosSaleBloc>().customerPhoneController.text;
      } else {
        body['customer_id'] =
            context.read<CreatePosSaleBloc>().selectClintModel?.id.toString() ??
                '';
      }

      // if (_isChecked == true) {
      //   body['payment_method'] =
      //       context.read<MoneyReceiptBloc>().selectedPaymentMethod.toString();
      //   // body['account'] =
      //   //     context.read<CreatePosSaleBloc>().accountModel!.acId.toString();
      //
      //   if (context.read<MoneyReceiptBloc>().selectedPaymentMethod.toString() !=
      //       "Cheque") {
      //     body["account"] =
      //         context.read<CreatePosSaleBloc>().accountModel?.acId.toString();
      //   } else {
      //     body["withdraw_date"] = appWidgets.convertDateTime(
      //         DateFormat("dd-MM-yyyy").parse(
      //             context
      //                 .read<CreatePosSaleBloc>()
      //                 .withdrawDateController
      //                 .text
      //                 .trim(),
      //             true),
      //         "yyyy-MM-dd");
      //     context.read<CreatePosSaleBloc>().withdrawDateController.text.trim();
      //     body["cheque_number"] = context
      //         .read<CreatePosSaleBloc>()
      //         .chequeNumberController
      //         .text
      //         .trim();
      //     body["bank_name"] =
      //         context.read<CreatePosSaleBloc>().bankNameController.text.trim();
      //   }
      // }
      log(body.toString());
      // if (calculateAllFinalTotal() <=
      //     double.parse(context.read<PosSaleInstantBloc>().payableAmount.text)) {
      //   context.read<CreatePosSaleBloc>().add(AddPosSale(body: body));
      // } else {
      //   appSnackBar(context, "Payable Gross amount", color: Colors.redAccent);
      // }
    }
  }
}
