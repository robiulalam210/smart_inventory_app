import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../accounts/data/model/account_active_model.dart';
import '../../../../../accounts/data/model/account_model.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../../../customer/data/model/customer_active_model.dart';
import '../../../../../users_list/data/model/user_model.dart';
import '../../../../data/models/create_pos_sale_model.dart';

part 'create_pos_sale_event.dart';
part 'create_pos_sale_state.dart';

class CreatePosSaleBloc extends Bloc<CreatePosSaleEvent, CreatePosSaleState> {
  var customType = "Saved Customer";
  List customTypeList = ["Saved Customer", "Walk In Customer"];
  CustomerActiveModel? selectClintModel;
  UsersListModel? selectSalesModel;
  AccountActiveModel? accountModel;
  String selectedAccount = "";
  String selectedAccountId = "";
  List paymentMethod = ["Bank", "Cash", "Mobile Banking"];
  String selectedPaymentMethod = "Cash";
  TextEditingController dateEditingController = TextEditingController();
  TextEditingController customerPhoneController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();
  TextEditingController itemDiscountController = TextEditingController();
  TextEditingController itemTotalController = TextEditingController();

  TextEditingController remarkController =
  TextEditingController(text: "Thank you for choosing us.");
  TextEditingController clientPhoneController = TextEditingController();
  TextEditingController vatOverAllController = TextEditingController();
  TextEditingController discountOverAllController = TextEditingController();
  TextEditingController payableAmount = TextEditingController();
  TextEditingController serviceChargeOverAllController =
  TextEditingController();
  TextEditingController deliveryChargeOverAllController =
  TextEditingController();

  TextEditingController bankNameController = TextEditingController();
  TextEditingController chequeNumberController = TextEditingController();
  TextEditingController withdrawDateController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  Map<int, Map<String, TextEditingController>> controllers = {}; // Add this missing variable

  String selectedOverallVatType = 'fixed';
  String selectedOverallDiscountType = 'fixed';
  String selectedOverallServiceChargeType = 'fixed';
  String selectedOverallDeliveryType = 'fixed';
  bool isChecked = false;

  void clearData() {
    // Clear customer and sales selection
    selectClintModel = null;
    selectSalesModel = null;
    accountModel = null;
    selectedAccount = "";
    selectedAccountId = "";
    customType = "Saved Customer";
    selectedPaymentMethod = "Cash";

    // Clear date
    dateEditingController.text = appWidgets.convertDateTimeDDMMYYYY(DateTime.now());

    // Clear text controllers
    customerPhoneController.clear();
    itemPriceController.clear();
    itemQuantityController.clear();
    itemDiscountController.clear();
    itemTotalController.clear();
    clientPhoneController.clear();
    vatOverAllController.clear();
    discountOverAllController.clear();
    serviceChargeOverAllController.clear();
    deliveryChargeOverAllController.clear();
    payableAmount.clear();
    remarkController.text = "Thank you for choosing us."; // Reset to default
    bankNameController.clear();
    chequeNumberController.clear();
    withdrawDateController.text = appWidgets.convertDateTimeDDMMYYYY(DateTime.now());

    // Clear products list and controllers
    _clearProductsAndControllers();

    // Clear UI state variables
    selectedOverallVatType = 'fixed';
    selectedOverallDiscountType = 'fixed';
    selectedOverallServiceChargeType = 'fixed';
    selectedOverallDeliveryType = 'fixed';
    isChecked = false;
  }

  void _clearProductsAndControllers() {
    // Dispose all controllers
    for (var controllerMap in controllers.values) {
      for (var controller in controllerMap.values) {
        controller.dispose();
      }
    }
    controllers.clear();

    // Clear products list
    products.clear();

    // Reinitialize with one empty product
    _addInitialProduct();
  }

  void _addInitialProduct() {
    final newIndex = products.length;
    products.add({
      "id": newIndex,
      "product": null,
      "product_id": null,
      "discount_type": 'fixed',
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
  }

  // Method to add product from UI (without setState)
  void addProduct() {
    final newIndex = products.length;
    products.add({
      "id": newIndex,
      "product": null,
      "product_id": null,
      "discount_type": 'fixed',
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
  }

  // Method to remove product from UI (without setState)
  void removeProduct(int index) {
    // Dispose controllers for the removed product
    if (controllers.containsKey(index)) {
      for (var controller in controllers[index]!.values) {
        controller.dispose();
      }
      controllers.remove(index);
    }

    // Remove the product
    products.removeAt(index);

    // Reindex remaining controllers
    final newControllers = <int, Map<String, TextEditingController>>{};
    controllers.forEach((key, value) {
      if (key > index) {
        newControllers[key - 1] = value;
      } else {
        newControllers[key] = value;
      }
    });
    controllers.clear();
    controllers.addAll(newControllers);

    // Reindex products
    for (int i = 0; i < products.length; i++) {
      products[i]["id"] = i;
    }
  }

  CreatePosSaleBloc() : super(CreatePosSaleInitial()) {
    // Initialize with one product
    _addInitialProduct();

    on<AddPosSale>(_onCreatePosSale);
  }

  @override
  Future<void> close() {
    // Dispose all controllers when bloc is closed
    for (var controllerMap in controllers.values) {
      for (var controller in controllerMap.values) {
        controller.dispose();
      }
    }
    controllers.clear();

    // Dispose other controllers
    dateEditingController.dispose();
    customerPhoneController.dispose();
    itemPriceController.dispose();
    itemQuantityController.dispose();
    itemDiscountController.dispose();
    itemTotalController.dispose();
    remarkController.dispose();
    clientPhoneController.dispose();
    vatOverAllController.dispose();
    discountOverAllController.dispose();
    payableAmount.dispose();
    serviceChargeOverAllController.dispose();
    deliveryChargeOverAllController.dispose();
    bankNameController.dispose();
    chequeNumberController.dispose();
    withdrawDateController.dispose();

    return super.close();
  }

  Future<void> _onCreatePosSale(
      AddPosSale event, Emitter<CreatePosSaleState> emit) async {
    emit(CreatePosSaleLoading());

    try {
      final res = await postResponse(url: AppUrls.posSale, payload: event.body);

      // Convert the Map to JSON string for appParseJson
      final jsonString = jsonEncode(res);
      print('📦 Response JSON: $jsonString');

      ApiResponse response = appParseJson(
        jsonString,
            (data) => CreatePosSaleModel.fromJson(data),
      );

      print('✅ Parsed response success: ${response.success}');

      if (response.success == false) {
        emit(CreatePosSaleFailed(
            title: response.title ?? 'Error',
            content: response.message ?? "Operation failed"
        ));
        return;
      }

      // Clear data and emit success
      clearData();
      emit(CreatePosSaleSuccess());

    } catch (error) {
      print('❌ Error in _onCreatePosSale: $error');
      emit(CreatePosSaleFailed(title: "Error", content: error.toString()));
    }
  }
}