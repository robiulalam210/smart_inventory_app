
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../customer/data/model/customer_model.dart';
import '../../../../sales/data/models/pos_sale_model.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../data/model/money_receipt_model/create_money_recipt_model.dart';
import '../../../data/model/money_receipt_model/money_receipt_invoice_model.dart';
import '../../../data/model/money_receipt_model/money_receipt_model.dart';
import 'money_receipt_state.dart';

part 'money_receipt_event.dart';

class MoneyReceiptBloc extends Bloc<MoneyReceiptEvent, MoneyReceiptState> {
  List<MoneyreceiptModel> moneyReceiptModel = [];

  List paymentTo = ["Over All", "Specific"];
  List<String> paymentMethod = ["Bank", "Cash", "Mobile banking"];
  String selectedPayment = "";
  String? selectedPaymentToState;
  // TextEditingController filterTextController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  // ValueNotifier<String> selectedPaymentToState = ValueNotifier<String>('Over All');
  // ValueNotifier<PosSaleModel?> selectPosSaleModel = ValueNotifier<PosSaleModel?>(null);
  // ValueNotifier<String?> selectedPaymentToNotifier = ValueNotifier(null);
  // ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier(null);
  // ValueNotifier<String?> selectedAccountNotifier = ValueNotifier(null);
  TextEditingController bankNameController = TextEditingController();
  TextEditingController chequeNumberController = TextEditingController();
  TextEditingController withdrawDateController = TextEditingController();

  CustomerModel? selectCustomerModel;
  UsersListModel? selectUserModel;

  // PosSaleModel? selectPosSaleModel;
  // String selectedPaymentToState = "Over All";
  String selectedAccount = "";
  String selectedAccountId = "";
  String selectedPaymentMethod = "Cash";
  late MoneyReceiptInvoiceModel data; // Changed to InventoryProductDetailsModel

  MoneyReceiptBloc() : super(MoneyReceiptInitial()) {
    on<FetchMoneyReceiptList>(_onFetchMoneyReceiptList);
    on<AddMoneyReceipt>(_onCreateMoneyReceiptList);
    // on<UpdatePaymentMoneyReceipt>(_onPaymentList);
    on<MoneyReceiptDetailsList>(_onFetchMoneyReceiptDetails);
    on<DeleteMoneyReceipt>(_onDeleteMoneyReceipt);
  }

  clearData() {
    dateController.clear();
    amountController.clear();
    remarkController.clear();
    bankNameController.clear();
    chequeNumberController.clear();
    withdrawDateController.clear();
    selectCustomerModel = null;
    selectUserModel = null;
    selectedAccount = "";
    selectedAccountId = "";
    // selectPosSaleModel.dispose();
    // selectedPaymentToNotifier.dispose();
    // selectedPaymentMethodNotifier.dispose();
    // selectedAccountNotifier.dispose();
  }

  Future<void> _onDeleteMoneyReceipt(
      DeleteMoneyReceipt event, Emitter<MoneyReceiptState> emit) async {
    emit(MoneyReceiptDeleteLoading());

    try {
      final res = await deleteResponse(
          url:
              "${AppUrls.moneyReceipt}/${event.id.toString()}"); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) =>
            List<PosSaleModel>.from(data.map((x) => PosSaleModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(MoneyReceiptDeleteFailed(
            title: 'Alert', content: response.message ?? ""));
        return;
      }

      emit(MoneyReceiptDeleteSuccess());
    } catch (error) {
      emit(MoneyReceiptDeleteFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onFetchMoneyReceiptList(
      FetchMoneyReceiptList event, Emitter<MoneyReceiptState> emit) async {
    emit(MoneyReceiptListLoading());

    try {
      final res = await getResponse(
          url: AppUrls.moneyReceipt,

          context: event.context); // Use the correct API URL

      // final response=warehouseBranchModelFromJson(res);

      ApiResponse<List<MoneyreceiptModel>> response =
          appParseJson<List<MoneyreceiptModel>>(
        res,
        (data) => List<MoneyreceiptModel>.from(
            data.map((x) => MoneyreceiptModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(MoneyReceiptListSuccess(
          list: [],

        ));

        return;
      }
      // Store all warehouses for filtering and pagination
      moneyReceiptModel = data;

      // Apply filtering and pagination
      final filteredWarehouses = _filterData(
          moneyReceiptModel, event.filterText,event.customer,event.seller,event.paymentMethod, event.startDate, event.endDate);



      emit(MoneyReceiptListSuccess(
        list: filteredWarehouses,

      ));
    } catch (error) {
      emit(MoneyReceiptListFailed(title: "Error", content: error.toString()));
    }
  }

  List<MoneyreceiptModel> _filterData(
      List<MoneyreceiptModel> warehouses,
      String filterTextMrNo,
      String customerName,
      String sellerName,
      String paymentType,
      DateTime? startDate,
      DateTime? endDate,
      ) {


    return warehouses.where((warehouse) {
      final matchesDate = (startDate == null || endDate == null) ||
          (warehouse.paymentDate != null &&
              ((warehouse.paymentDate!.isAfter(startDate) &&
                  warehouse.paymentDate!.isBefore(endDate)) ||
                  warehouse.paymentDate!.isAtSameMomentAs(startDate) ||
                  warehouse.paymentDate!.isAtSameMomentAs(endDate)));

      final matchesMrNo = filterTextMrNo.isEmpty ||
          (warehouse.mrNo?.toLowerCase() ?? '').contains(filterTextMrNo.toLowerCase());

      final matchesCustomer = customerName.isEmpty ||
          (warehouse.customerName?.toLowerCase() ?? '').contains(customerName.toLowerCase());

      final matchesSeller = sellerName.isEmpty ||
          (warehouse.sellerName?.toLowerCase() ?? '').contains(sellerName.toLowerCase());

      final matchesPaymentType = paymentType.isEmpty ||
          (warehouse.paymentMethod?.toLowerCase() ?? '').contains(paymentType.toLowerCase());

      debugPrint(
          'Checking: MR:${warehouse.mrNo}, Customer:${warehouse.customerName}, Seller:${warehouse.sellerName}, '
              'PaymentType:${warehouse.paymentMethod}, Date:${warehouse.paymentDate} => '
              '[Date:$matchesDate | MR:$matchesMrNo | Custom:$matchesCustomer | Seller:$matchesSeller | Pay:$matchesPaymentType]'
      );

      return matchesDate &&
          matchesMrNo &&
          matchesCustomer &&
          matchesSeller &&
          matchesPaymentType;
    }).toList();
  }


  Future<void> _onCreateMoneyReceiptList(
      AddMoneyReceipt event, Emitter<MoneyReceiptState> emit) async {
    emit(MoneyReceiptAddLoading());

    try {
      final res = await postResponse(
          url: AppUrls.moneyReceipt,
          payload: event.body); // Use the correct API URL
      ApiResponse response = appParseJson(
        res,
            (data) => CreateMoneyReciptModel.fromJson(data),
      );

      if (response.success == false) {
        emit(MoneyReceiptAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(MoneyReceiptAddSuccess());
    } catch (error) {
      clearData();
      emit(MoneyReceiptAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onFetchMoneyReceiptDetails(
      MoneyReceiptDetailsList event, Emitter<MoneyReceiptState> emit) async {
    emit(MoneyReceiptDetailsLoading());

    try {
      // Fetch the warehouse product details
      final warehouseRes = await getResponse(
          url: "${AppUrls.moneyReceipt}/${event.id.toString()}",
          context: event.context);
      ApiResponse<MoneyReceiptInvoiceModel> warehouseResponse =
          appParseJson<MoneyReceiptInvoiceModel>(
        warehouseRes,
        (data) => MoneyReceiptInvoiceModel.fromJson(data),
      );

      final warehouseData = warehouseResponse.data;

      if (warehouseData == null) {
        emit(MoneyReceiptDetailsSuccess(details: MoneyReceiptInvoiceModel()));
        return;
      }

      data = warehouseData;

      emit(MoneyReceiptDetailsSuccess(details: warehouseData));
    } catch (error) {
      emit(
          MoneyReceiptDetailsFailed(title: "Error", content: error.toString()));
    }
  }
}
