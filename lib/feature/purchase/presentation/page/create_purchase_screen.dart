import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_inventory/feature/products/product/data/model/product_model.dart';
import 'package:smart_inventory/feature/products/product/presentation/bloc/products/products_bloc.dart';
import 'package:smart_inventory/feature/users_list/presentation/bloc/users/user_bloc.dart';
import 'dart:developer';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/app_snack_bar.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../supplier/data/model/supplier_list_model.dart';
import '../../../supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import '../bloc/create_purchase/create_purchase_bloc.dart';


class CreatePurchaseScreen extends StatefulWidget {
  const CreatePurchaseScreen({super.key});

  @override
  _CreatePurchaseScreenState createState() => _CreatePurchaseScreenState();
}

class _CreatePurchaseScreenState extends State<CreatePurchaseScreen> {

  @override
  void initState() {
    context.read<AccountBloc>().add(
      FetchAccountList(
        context,
      ),
    );

    context.read<SupplierListBloc>().add(
      FetchSupplierList(
        context,
      ),
    );
    super.initState();
    context.read<ProductsBloc>().add(
      FetchProductsList(context,
          filterApiURL: "&all_product=true"),
    );
    // context.read<ProductsBloc>().add(
    //   FetchProductsList(
    //     filterApiURL:
    //     "?status=1&location_id=${context.read<ProfileBloc>().profileModel.locationId?.toString()}",
    //   ),
    // );
    context.read<CreatePurchaseBloc>().dateEditingController.text =
    DateTime.now().toIso8601String().split('T')[0];
    addProduct(); // Initialize with one product row
  }

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
    double totalSum = 0.0;
    for (var product in products) {
      totalSum += product["total"];
    }
    return totalSum;
  }

  double overallTotal = 0.0;

  void updateTotal(int index) {
    final price =
        double.tryParse(controllers[index]?["price"]?.text ?? '') ?? 0.0;
    final quantity =
        double.tryParse(controllers[index]?["quantity"]?.text ?? '') ?? 0.0;
    final discount =
        double.tryParse(controllers[index]?["discount"]?.text ?? '') ?? 0.0;
    final discountType = products[index]["discount_type"] as String? ?? '';

    double total = price * quantity;

    if (discountType == 'fixed') {
      total -= discount;
    } else if (discountType == 'percentage') {
      total -= (total * (discount / 100));
    }

    total = total < 0 ? 0.0 : total;

    controllers[index]!["total"]!.text = total.toStringAsFixed(2);
    setState(() {
      products[index]["total"] = total;
      overallTotal = calculateFinalTotal(); // Now correctly updates final total
    });
  }

  double serviceCharge = 0.0;
  double deliveryCharge = 0.0;
  double discount = 0.0;
  double vat = 0;

  double ticketTotal = 0;
  double specificDiscount = 0;
  double calculateTotalTicketForAllProducts() {
    double totalSum = 0;
    for (var product in products) {
      totalSum += product["ticket_total"] ?? 0; // Ensures null safety
    }
    return totalSum;
  }

  double calculateDeliveryTotal() {
    double total = calculateTotalForAllProducts();

    // Retrieve values from the text controllers

    deliveryCharge = double.tryParse(context
        .read<CreatePurchaseBloc>()
        .deliveryChargeOverAllController
        .text) ??
        0.0;

    // Apply Discount
    if (selectedOverallDeliveryType == 'percentage') {
      deliveryCharge = (total * (deliveryCharge / 100));
    }
    // total -= deliveryCharge;

    return deliveryCharge;
  }
  double calculateDiscountTotal() {
    double total = calculateTotalForAllProducts();

    // Retrieve values from the text controllers

    discount = double.tryParse(context
        .read<CreatePurchaseBloc>()
        .discountOverAllController
        .text) ??
        0.0;

    // Apply Discount
    if (selectedOverallDiscountType == 'percentage') {
      discount = (total * (discount / 100));
    }
    // total -= discount;
    //
    return discount;
  }
  double calculateVatTotal() {
    double total = calculateTotalForAllProducts();

    // Retrieve values from the text controllers
    vat =
        double.tryParse(
          context.read<CreatePurchaseBloc>().vatOverAllController.text,
        ) ??
            0.0;

    // Apply VAT
    if (selectedOverallVatType == 'percentage') {
      vat = (total * (vat / 100));
    }
    total += vat;

    return total;
  }

  double calculateServiceChargeTotal() {
    double total = calculateTotalForAllProducts();

    double enteredServiceCharge = double.tryParse(context
        .read<CreatePurchaseBloc>()
        .serviceChargeOverAllController
        .text) ??
        0.0;

    serviceCharge = (selectedOverallServiceChargeType == 'percentage')
        ? (total * (enteredServiceCharge / 100))
        : enteredServiceCharge;

    return serviceCharge;
  }
  double calculateAllFinalTotal() {
    // Step 1: Calculate the total for all products
    double total = calculateTotalForAllProducts();

    // Step 2: Apply discount (check if percent or fixed)
    double discount =
        double.tryParse(
          context.read<CreatePurchaseBloc>().discountOverAllController.text,
        ) ??
            0.0;
    if (selectedOverallDiscountType == 'percentage') {
      discount = calculateTotalForAllProducts() * (discount / 100);
    } // Fixed discount does not change
    total -= discount;

    // Step 3: Apply VAT (check if percent or fixed)
    double vat =
        double.tryParse(
          context.read<CreatePurchaseBloc>().vatOverAllController.text,
        ) ??
            0.0;
    if (selectedOverallVatType == 'percentage') {
      vat = calculateTotalForAllProducts() * (vat / 100);
    }
    total += vat;

    // Step 4: Apply Delivery Charge (check if percent or fixed)
    double deliveryCharge =
        double.tryParse(
          context
              .read<CreatePurchaseBloc>()
              .deliveryChargeOverAllController
              .text,
        ) ??
            0.0;
    if (selectedOverallDeliveryType == 'percentage') {
      deliveryCharge = calculateTotalForAllProducts() * (deliveryCharge / 100);
    }
    total += deliveryCharge;

    // Step 5: Apply Service Charge (check if percent or fixed)
    double serviceCharge =
        double.tryParse(
          context.read<CreatePurchaseBloc>().serviceChargeOverAllController.text,
        ) ??
            0.0;
    if (selectedOverallServiceChargeType == 'percentage') {
      serviceCharge = calculateTotalForAllProducts() * (serviceCharge / 100);
    }
    total += serviceCharge;

    // Final calculated total
    return total;
  }

  double calculateFinalTotal() {
    double total = calculateTotalForAllProducts(); // Start with the product total

    total += calculateServiceChargeTotal();  // Add service charge
    total += calculateDeliveryTotal();       // Add delivery charge
    total -= calculateDiscountTotal(); // Directly subtract discount (already calculated)

    total = total < 0 ? 0.0 : total; // Prevent negative total

    setState(() {}); // Ensure UI updates when the total changes
    return total;
  }
  void _updateChangeAmount() {
    // final payableAmount =
    //     double.tryParse(context.read<CreatePurchaseBloc>().payableAmount.text) ??
    //         0.0;
    // final changeAmount = calculateAllFinalTotal() - payableAmount;

    setState(() {
      // changeAmountController.text = changeAmount.toStringAsFixed(2);
    });
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
        "price": 0.0,
        "stock": 0,
        "quantity": 1,
        "discount": 0.0,
        "total": 0.0,
      });

      controllers[newIndex] = {
        "quantity": TextEditingController(text: "1"),
        "price": TextEditingController(text: "0.0"),
        "discount": TextEditingController(text: "0.0"),
        "total": TextEditingController(text: "0.0"),
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
      // Update the selected product in the products list
      products[index]["product"] = newVal;
      products[index]["product_id"] = newVal.id; // Set the product_id
      // Update price based on the selected product
      // final productPrice = newVal.sellingPrice; //
      // controllers[index]!["price"]!.text = productPrice.toString();
      // products[index]["price"] = productPrice;

      // Reset the discount and total fields
      controllers[index]!["discount"]!.text = "0.0";
      products[index]["discount"] = 0.0;
      updateTotal(index); // Recalculate total based on new price and quantity
    });
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
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {

        },
        child: BlocConsumer<CreatePurchaseBloc, CreatePurchaseState>(
          listener: (context, state) {
            if (state is CreatePurchaseLoading) {
              appLoader(context, "Creating PosSale, please wait...");
            } else if (state is CreatePurchaseSuccess) {
              Navigator.pop(context); // Close loader dialog
              // AppRoutes.pushReplacement(context, const PosSaleScreen());
            } else if (state is CreatePurchaseFailed) {
              Navigator.pop(context); // Close loader dialog
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
            return Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(height: 10),
                  ResponsiveRow(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      ResponsiveCol(
                        xs: 12,
                        sm: 3,
                        md: 3,
                        lg: 3,
                        xl: 3,
                        child:  BlocBuilder<SupplierListBloc, SupplierListState>(
                          builder: (context, state) {
                            return AppDropdown<SupplierListModel>(
                              label: "Supplier",
                              context: context,
                              hint: "Select Supplier",
                              isLabel: false,
                              isRequired: true,
                              isNeedAll: false,
                              value:
                              context.read<CreatePurchaseBloc>().supplierListModel,
                              itemList:
                              context.read<SupplierListBloc>().supplierListModel,
                              onChanged: (newVal) {
                                // Update the selected warehouse in the bloc
                                context.read<CreatePurchaseBloc>().supplierListModel =
                                    newVal;
                              },
                              validator: (value) {
                                return value == null ? 'Please select Supplier' : null;
                              },
                              itemBuilder: (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.toString(),
                                  style: const TextStyle(
                                    color: AppColors.blackColor,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      ResponsiveCol(
                        xs: 12,
                        sm: 3,
                        md: 3,
                        lg: 3,
                        xl: 3,
                        child:  CustomInputField(
                          radius: 10,
                          isRequired: true,
                          readOnly: true,
                          controller:
                          context.read<CreatePurchaseBloc>().dateEditingController,
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
                      ),
                      ResponsiveCol(
                        xs: 12,
                        sm: 2,
                        md: 2,
                        lg: 2,
                        xl: 2,
                        child: SizedBox()
                      ),

                      ResponsiveCol(
                        xs: 12,
                        sm: 3,
                        md: 3,
                        lg: 3,
                        xl: 3,
                        child: SizedBox(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  ...products.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;

                    // Initialize controllers if not already initialized
                    if (!controllers.containsKey(index)) {
                      controllers[index] = {
                        "quantity": TextEditingController(
                          text: product["quantity"].toString(),
                        ),
                        "price": TextEditingController(
                          text: product["price"].toString(),
                        ),
                        "discount": TextEditingController(
                          text: product["discount"].toString(),
                        ),
                        "total": TextEditingController(
                          text: product["total"].toString(),
                        ),
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
                          ResponsiveCol(
                            xs: 12,
                            sm: 3,
                            md: 3,
                            lg: 3,
                            xl: 3,
                            child: BlocBuilder<ProductsBloc, ProductsState>(
                              builder: (context, state) {
                                return SizedBox(
                                  child: AppDropdown<ProductModel>(
                                    context: context,
                                    isRequired: false,
                                    isLabel: true,
                                    isSearch: true,
                                    label: "Product",
                                    hint: "Select Product",
                                    value: product["product"],
                                    itemList: context.read<ProductsBloc>().list,
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
                          ),
                          ResponsiveCol(
                            xs: 12,
                            sm: 1,
                            md: 1,
                            lg: 1,
                            xl: 1,
                            child: TextFormField(
                              style: AppTextStyle.cardLevelText(context),
                              controller: controllers[index]?["total"]
                                ?..text =
                                    products[index]["total"]?.toString() ?? "0",
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                label: Text(
                                  "Total Amount",
                                  style: AppTextStyle.cardLevelText(context),
                                ),
                                fillColor: AppColors.whiteColor,
                                filled: true,
                                hintStyle: AppTextStyle.cardLevelText(context),
                                isCollapsed: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
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
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  products[index]["total"] =
                                      double.tryParse(value) ?? 0.0;
                                  updateTotal(
                                    index,
                                  ); // Recalculate total when discount value changes
                                });
                              },
                            ),
                          ),

                          ResponsiveCol(
                            xs: 12,
                            sm: 1,
                            md: 1,
                            lg: 1,
                            xl: 1,
                            child: TextFormField(
                              style: AppTextStyle.cardLevelText(context),
                              controller: controllers[index]?["ticket_total"]
                                ?..text =
                                    products[index]["ticket_total"]
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
                                hintStyle: AppTextStyle.cardLevelText(context),
                                isCollapsed: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
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
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  products[index]["ticket_total"] =
                                      double.tryParse(value) ?? 0.0;
                                  updateTotal(
                                    index,
                                  ); // Recalculate total when discount value changes
                                });
                              },
                            ),
                          ),
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
                              decoration: InputDecoration(
                                label: Text(
                                  "Price ",
                                  style: AppTextStyle.cardLevelText(context),
                                ),
                                fillColor: AppColors.whiteColor,
                                filled: true,
                                hintStyle: AppTextStyle.cardLevelText(context),
                                isCollapsed: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
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
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
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
                                    index,
                                  ); // Update total after changing quantity
                                });
                              },
                            ),
                          ),
                          ResponsiveCol(
                            xs: 12,
                            sm: 2,
                            md: 2,
                            lg: 2,
                            xl: 2,
                            child: CupertinoSegmentedControl<String>(
                              padding: EdgeInsets.zero,
                              children: {
                                'fixed': Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: Text(
                                    'Fixed',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.playfairDisplay()
                                          .fontFamily,
                                      color:
                                          products[index]["discount_type"] ==
                                              'fixed'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                'percentage': Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: Text(
                                    ' Percent',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.playfairDisplay()
                                          .fontFamily,
                                      color:
                                          products[index]["discount_type"] ==
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
                                    index,
                                  ); // Recalculate total when discount type changes
                                });
                              },
                              groupValue: products[index]["discount_type"],
                              unselectedColor: Colors.grey[300],
                              selectedColor: AppColors.primaryColor,
                              borderColor: AppColors.primaryColor,
                            ),
                          ),

                          ResponsiveCol(
                            xs: 12,
                            sm: 1,
                            md: 1,
                            lg: 1,
                            xl: 1,
                            child: TextFormField(
                              controller: controllers[index]?["discount"],
                              style: AppTextStyle.cardLevelText(context),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                fillColor: AppColors.whiteColor,
                                filled: true,
                                hintStyle: AppTextStyle.cardLevelText(context),
                                isCollapsed: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    ),
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
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  products[index]["discount"] =
                                      double.tryParse(value) ?? 0.0;
                                  updateTotal(
                                    index,
                                  ); // Recalculate total when discount value changes
                                });
                              },
                            ),
                          ),
                          ResponsiveCol(
                            xs: 12,
                            sm: 1.5,
                            md: 1.5,
                            lg: 1.5,
                            xl: 1.5,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      // Use a condition that explicitly checks the parsed integer result.
                                      int? currentQuantity = int.tryParse(
                                        controllers[index]?["quantity"]?.text ??
                                            "0",
                                      );
                                      if (currentQuantity != null &&
                                          currentQuantity > 1) {
                                        controllers[index]!["quantity"]!.text =
                                            (currentQuantity - 1).toString();
                                        products[index]["quantity"] =
                                            controllers[index]!["quantity"]!
                                                .text;
                                        if (kDebugMode) {
                                          print(
                                            products[index]["quantity"] =
                                                controllers[index]!["quantity"]!
                                                    .text,
                                          );
                                        }
                                        updateTotal(
                                          index,
                                        ); // Update total if quantity changes
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
                                      int currentQuantity =
                                          int.tryParse(
                                            controllers[index]!["quantity"]!
                                                .text,
                                          ) ??
                                          0;
                                      controllers[index]!["quantity"]!.text =
                                          (currentQuantity + 1).toString();
                                      products[index]["quantity"] =
                                          controllers[index]!["quantity"]!.text;
                                      updateTotal(
                                        index,
                                      ); // Update total if quantity changes
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          ResponsiveCol(
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
                                  addProduct();
                                } else {
                                  removeProduct(product["id"]);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 10),
                  ResponsiveRow(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      ResponsiveCol(
                        xs: 12,
                        sm: 3,
                        md: 3,
                        lg: 3,
                        xl: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overall Discount",
                              style: AppTextStyle.cardLevelText(context),
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CupertinoSegmentedControl<String>(
                                    padding: EdgeInsets.zero,
                                    children: {
                                      'fixed': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                        child: Text(
                                          'TK',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallDiscountType ==
                                                    'fixed'
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      'percentage': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0,
                                        ),
                                        child: Text(
                                          ' %',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallDiscountType ==
                                                    'percentage'
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
                                        // _updateChangeAmount(); // R
                                        // Recalculate total when discount type changes
                                      });
                                    },
                                    groupValue: selectedOverallDiscountType,
                                    unselectedColor: Colors.grey[300],
                                    selectedColor: AppColors.primaryColor,
                                    borderColor: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomInputFieldPayRoll(
                                    isRequiredLevle: false,
                                    controller: context
                                        .read<CreatePurchaseBloc>()
                                        .discountOverAllController,
                                    hintText: 'Discount ',
                                    fillColor: Colors.white,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    // validator: (value) =>
                                    //     value!.isEmpty ? 'Please enter Vat ' : null,
                                    onChanged: (value) {
                                      calculateDiscountTotal();
                                      // _updateChangeAmount(); // R
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
                      ),
                      ResponsiveCol(
                        xs: 12,
                        sm: 3,
                        md: 3,
                        lg: 3,
                        xl: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overall Vat",
                              style: AppTextStyle.cardLevelText(context),
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CupertinoSegmentedControl<String>(
                                    padding: EdgeInsets.zero,
                                    children: {
                                      'fixed': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0,
                                        ),
                                        child: Text(
                                          'TK',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallVatType ==
                                                    'fixed'
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      'percentage': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0,
                                        ),
                                        child: Text(
                                          '%',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallVatType ==
                                                    'percentage'
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomInputFieldPayRoll(
                                    isRequiredLevle: false,
                                    controller: context
                                        .read<CreatePurchaseBloc>()
                                        .vatOverAllController,
                                    hintText: 'Vat ',
                                    fillColor: Colors.white,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (value) => value!.isEmpty
                                        ? 'Please enter Vat '
                                        : null,
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
                          ],
                        ),
                      ),
                      ResponsiveCol(
                        xs: 12,
                        sm: 2,
                        md: 2,
                        lg: 2,
                        xl: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Service Charge",
                              style: AppTextStyle.cardLevelText(context),
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CupertinoSegmentedControl<String>(
                                    padding: EdgeInsets.zero,
                                    children: {
                                      'fixed': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: Text(
                                          'TK',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallServiceChargeType ==
                                                    'fixed'
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      'percentage': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0,
                                        ),
                                        child: Text(
                                          '%',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallServiceChargeType ==
                                                    'percentage'
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    },
                                    onValueChanged: (value) {
                                      setState(() {
                                        selectedOverallServiceChargeType =
                                            value;
                                        calculateServiceChargeTotal();

                                        // Recalculate total when discount type changes
                                      });
                                    },
                                    groupValue:
                                        selectedOverallServiceChargeType,
                                    unselectedColor: Colors.grey[300],
                                    selectedColor: AppColors.primaryColor,
                                    borderColor: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomInputFieldPayRoll(
                                    isRequiredLevle: false,
                                    controller: context
                                        .read<CreatePurchaseBloc>()
                                        .serviceChargeOverAllController,
                                    hintText: 'Charge ',
                                    fillColor: Colors.white,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
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
                          ],
                        ),
                      ),

                      ResponsiveCol(
                        xs: 12,
                        sm: 3,
                        md: 3,
                        lg: 3,
                        xl: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Charge",
                              style: AppTextStyle.cardLevelText(context),
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CupertinoSegmentedControl<String>(
                                    padding: EdgeInsets.zero,
                                    children: {
                                      'fixed': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                        child: Text(
                                          'TK',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallDeliveryType ==
                                                    'fixed'
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      'percentage': Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                        child: Text(
                                          '%',
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.playfairDisplay()
                                                    .fontFamily,
                                            color:
                                                selectedOverallDeliveryType ==
                                                    'percentage'
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomInputFieldPayRoll(
                                    isRequiredLevle: false,
                                    controller: context
                                        .read<CreatePurchaseBloc>()
                                        .deliveryChargeOverAllController,
                                    hintText: 'Delivery ',
                                    fillColor: Colors.white,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ResponsiveRow(
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
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Ticket Total",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      calculateTotalTicketForAllProducts()
                                          .toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Specific Discount (-)",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      discount
                                          .toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Sub Total",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      calculateTotalForAllProducts()
                                          .toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Discount (-)",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      discount.toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Vat (+)",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      vat.toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Service Charge (+)	",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      serviceCharge.toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Delivery Charge (+)	",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      deliveryCharge.toStringAsFixed(2),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      "Net Total",
                                      style: AppTextStyle.cardLevelHead(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      calculateAllFinalTotal().toStringAsFixed(
                                        2,
                                      ),
                                      style: AppTextStyle.cardLevelText(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
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
                            const SizedBox(height: 10),
                            CheckboxListTile(
                              title: Text(
                                "Instant Pay",
                                style: AppTextStyle.cardTitle(context),
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
                                ? Row(
                              children: [
                                Expanded(
                                    child: AppDropdown(
                                      label: "Payment Method",
                                      context: context,
                                      hint: context
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
                                      value: context
                                          .read<CreatePurchaseBloc>()
                                          .selectedPaymentMethod
                                          .isEmpty
                                          ? null
                                          : context
                                          .read<CreatePurchaseBloc>()
                                          .selectedPaymentMethod,
                                      itemList: context.read<CreatePurchaseBloc>().paymentMethod,
                                      onChanged: (newVal) {
                                        // Update the selected payment method in the bloc
                                        context
                                            .read<CreatePurchaseBloc>()
                                            .selectedPaymentMethod = newVal.toString();

                                        setState(() {
                                          // Trigger a rebuild to update the filtered accounts
                                        });
                                      },
                                      validator: (value) {
                                        return value == null
                                            ? 'Please select a payment method'
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
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: BlocBuilder<AccountBloc, AccountState>(
                                    builder: (context, state) {
                                      if (state is AccountListLoading) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (state is AccountListSuccess) {
                                        // Filter the accounts list based on selected payment method (ac_type)
                                        final filteredList = context
                                            .read<CreatePurchaseBloc>()
                                            .selectedPaymentMethod
                                            .isNotEmpty
                                            ? state.list.where((item) {
                                          return item.acType?.toLowerCase() ==
                                              context
                                                  .read<CreatePurchaseBloc>()
                                                  .selectedPaymentMethod
                                                  .toLowerCase();
                                        }).toList()
                                            : state.list;

                                        // Debug: Check the size of the filtered list

                                        return AppDropdown(
                                          label: "Account",
                                          context: context,
                                          hint: "Select Account",
                                          isLabel: false,
                                          isRequired: true,
                                          isNeedAll: false,
                                          value: context
                                              .read<CreatePurchaseBloc>()
                                              .selectedAccount
                                              .isEmpty
                                              ? null
                                              : context
                                              .read<CreatePurchaseBloc>()
                                              .selectedAccount,
                                          itemList: filteredList,
                                          onChanged: (newVal) {
                                            // Update the selected account in the bloc
                                            context
                                                .read<CreatePurchaseBloc>()
                                                .selectedAccount = newVal.toString();

                                            var matchingAccount =
                                            filteredList.firstWhere(
                                                  (acc) =>
                                              acc.acName.toString() ==
                                                  newVal.toString().split("[").first,
                                            );

                                            context
                                                .read<CreatePurchaseBloc>()
                                                .selectedAccountId =
                                                matchingAccount.acId.toString();
                                          },
                                          validator: (value) {
                                            return value == null
                                                ? 'Please select an account'
                                                : null;
                                          },
                                          itemBuilder: (item) => DropdownMenuItem(
                                            value: item.toString(),
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
                                      } else if (state is AccountListFailed) {
                                        return Center(
                                            child: Text(
                                                'Failed to load accounts: ${state.content}'));
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                )
                              ],
                            )
                                : Container(),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                  gapH20,
                  FutureBuilder<Widget>(
                    future: buildActionButtons(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return snapshot.data!;
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
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
            appWidgets.convertDateTimeDDMMYYYY(pickedDate);
      });
    }
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      var transferProducts = products
          .map(
            (product) => {
              "product_id": product["product_id"].toString(),
              "qty": double.tryParse(product["quantity"].toString()),
              "price": double.tryParse(product["price"].toString()),
              "discount": double.tryParse(product["discount"].toString()),
              "discount_type": product["discount_type"].toString(),
              "product_total":
              (double.tryParse(product["price"].toString()) ?? 0) *
                  (double.tryParse(product["quantity"].toString()) ?? 0),
            },
          )
          .toList();
      Map<String, dynamic> body = {
        "instant_pay": _isChecked ? true : false,

        "date": appWidgets.convertDateTime(
          DateFormat("dd-MM-yyyy").parse(
            context.read<CreatePurchaseBloc>().dateEditingController.text.trim(),
            true,
          ),
          "yyyy-MM-dd",
        ),



        "vat":
            context
                .read<CreatePurchaseBloc>()
                .discountOverAllController
                .text
                .isEmpty
            ? 0
            : double.tryParse(
                context
                    .read<CreatePurchaseBloc>()
                    .discountOverAllController
                    .text,
              ),
        "service_charge":
            context
                .read<CreatePurchaseBloc>()
                .serviceChargeOverAllController
                .text
                .isEmpty
            ? 0
            : double.tryParse(
                context
                    .read<CreatePurchaseBloc>()
                    .serviceChargeOverAllController
                    .text,
              ),
        "delivery_charge":
            context
                .read<CreatePurchaseBloc>()
                .deliveryChargeOverAllController
                .text
                .isEmpty
            ? 0
            : double.tryParse(
                context
                    .read<CreatePurchaseBloc>()
                    .deliveryChargeOverAllController
                    .text,
              ),

        "purchase_items": transferProducts,
        "sub_total": calculateTotalForAllProducts().toStringAsFixed(2),
        "supplier":
        context.read<CreatePurchaseBloc>().supplierListModel?.id.toString(),


        // Convert list to JSON string
        "overall_discount":
            context
                .read<CreatePurchaseBloc>()
                .discountOverAllController
                .text
                .isEmpty
            ? 0.0
            : double.tryParse(
                context
                    .read<CreatePurchaseBloc>()
                    .discountOverAllController
                    .text,
              ),

        "overall_discount_type": selectedOverallDiscountType.toLowerCase(),
      };


      if (_isChecked == true) {
        body['payment_method'] =
            context.read<CreatePurchaseBloc>().selectedPaymentMethod.toString();
        body['account_id'] =
            context.read<CreatePurchaseBloc>().selectedAccountId.toString();
      }
      log(body.toString());
      context.read<CreatePurchaseBloc>().add(AddPurchase(body: body));

    }
  }

  Future<Widget> buildActionButtons() async {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
      ],
    );
  }
}
