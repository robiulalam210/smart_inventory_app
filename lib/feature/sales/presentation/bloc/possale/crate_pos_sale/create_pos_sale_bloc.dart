


import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../accounts/data/model/account_model.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../../../customer/data/model/customer_model.dart';
import '../../../../../users_list/data/model/user_model.dart';
import '../../../../data/models/create_pos_sale_model.dart';

part 'create_pos_sale_event.dart';

part 'create_pos_sale_state.dart';

class CreatePosSaleBloc extends Bloc<CreatePosSaleEvent, CreatePosSaleState> {
  var customType = "Saved Customer";
  List customTypeList = ["Saved Customer", "Walk In Customer"];
  CustomerModel? selectClintModel;
  UsersListModel? selectSalesModel;
  AccountModel? accountModel;
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
  clearData(){

    dateEditingController.clear();
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
  }

  CreatePosSaleBloc() : super(CreatePosSaleInitial()) {
    on<AddPosSale>(_onCreatePosSale);
  }

  Future<void> _onCreatePosSale(
      AddPosSale event, Emitter<CreatePosSaleState> emit) async {
    emit(CreatePosSaleLoading());

    try {
      final res =
          await postResponse(url: AppUrls.posSale, payload: event.body);

      ApiResponse response = appParseJson(
        res,
        (data) => CreatePosSaleModel.fromJson(data),
      );

      if (response.success == false) {
        emit(CreatePosSaleFailed(title: '', content: response.message ?? ""));
        return;
      }


      clearData();
      emit(CreatePosSaleSuccess());
    } catch (error) {
      emit(CreatePosSaleFailed(title: "Error", content: error.toString()));
    }
  }
}
