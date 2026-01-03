import '/feature/supplier/data/model/supplier_active_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/create_purchase_model.dart';

part 'create_purchase_event.dart';

part 'create_purchase_state.dart';

class CreatePurchaseBloc
    extends Bloc<CreatePurchaseEvent, CreatePurchaseState> {
  SupplierActiveModel? supplierListModel;
  AccountActiveModel? accountActiveModel;
  String selectedAccount = "";

  String selectedAccountId = "";
  List<String> paymentMethod = ["Bank", "Cash", "Mobile Banking"];
  String selectedPaymentMethod = "Cash";
  TextEditingController dateEditingController = TextEditingController();
  TextEditingController serviceChargeOverAllController =
      TextEditingController();
  TextEditingController deliveryChargeOverAllController =
      TextEditingController();

  // TextEditingController customerPhoneController=TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();
  TextEditingController itemDiscountController = TextEditingController();
  TextEditingController itemToalController = TextEditingController();

  TextEditingController discountOverAllController = TextEditingController();

  CreatePurchaseBloc() : super(CreatePurchaseInitial()) {
    on<AddPurchase>(_onCreatePurchase);
  }

  Future<void> _onCreatePurchase(
    AddPurchase event,
    Emitter<CreatePurchaseState> emit,
  ) async {
    emit(CreatePurchaseLoading());

    try {
      final res = await postResponse(
        url: AppUrls.purchase,
        payload: event.body,
      ); // Use the correct API URL

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
        (data) => CreatePurchaseModel.fromJson(data),
      );

      if (response.success == false) {
        emit(CreatePurchaseFailed(title: '', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(CreatePurchaseSuccess());
    } catch (error) {
      clearData();
      emit(CreatePurchaseFailed(title: "Error", content: error.toString()));
    }
  }

  void clearData() {
    // Reset controllers
    dateEditingController.clear();
    serviceChargeOverAllController.clear();
    deliveryChargeOverAllController.clear();
    itemPriceController.clear();
    itemQuantityController.clear();
    itemDiscountController.clear();
    itemToalController.clear();
    discountOverAllController.clear();

    // Reset selection variables
    selectedAccount = "";
    selectedAccountId = "";
    selectedPaymentMethod = "Cash"; // Reset to default

    // Clear models (optional)
    supplierListModel = null;
    accountActiveModel = null;

    // If you have other variables to clear, add them here
    // For example, if you have a list of purchase items, clear it:
    // purchaseItems.clear();

    // If you have VAT or other fields, clear them:
    // vatController.clear();
  }
}
