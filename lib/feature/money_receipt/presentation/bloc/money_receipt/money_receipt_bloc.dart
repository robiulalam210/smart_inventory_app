
import 'package:smart_inventory/feature/accounts/data/model/account_active_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../data/model/money_receipt_model/create_money_recipt_model.dart';
import '../../../data/model/money_receipt_model/money_receipt_invoice_model.dart';
import '../../../data/model/money_receipt_model/money_receipt_model.dart';
import 'money_receipt_state.dart';

part 'money_receipt_event.dart';

class MoneyReceiptBloc extends Bloc<MoneyReceiptEvent, MoneyReceiptState> {
  List<MoneyreceiptModel> moneyReceiptModel = [];

  List<String> paymentTo = ["Over All", "Specific"];
  List<String> paymentMethod = ["Bank", "Cash", "Mobile banking"];
  String selectedPayment = "";
  String? selectedPaymentToState;
  // TextEditingController filterTextController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();


  TextEditingController bankNameController = TextEditingController();
  TextEditingController chequeNumberController = TextEditingController();
  TextEditingController withdrawDateController = TextEditingController();

  CustomerActiveModel? selectCustomerModel;
  AccountActiveModel? accountModel;
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

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString, // Now passing String instead of Map
            (data) => data, // Just return data as-is for delete operations
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
      // Build query parameters with pagination
      Map<String, dynamic> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      // Add filters if provided
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.customer.isNotEmpty) {
        queryParams['customer'] = event.customer;
      }
      if (event.seller.isNotEmpty) {
        queryParams['seller'] = event.seller;
      }
      if (event.paymentMethod.isNotEmpty) {
        queryParams['payment_method'] = event.paymentMethod;
      }
      if (event.startDate != null) {
        queryParams['start_date'] = event.startDate!.toIso8601String().split('T')[0];
      }
      if (event.endDate != null) {
        queryParams['end_date'] = event.endDate!.toIso8601String().split('T')[0];
      }

      final res = await getResponse(
        url: AppUrls.moneyReceipt,
        queryParams: queryParams,
        context: event.context,
      );

      // Parse the response
      ApiResponse<Map<String, dynamic>> response = appParseJson<Map<String, dynamic>>(
        res,
            (data) => data,
      );

      final data = response.data;

      if (data == null) {
        emit(MoneyReceiptListSuccess(
          list: [],
          count: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }

      // Extract pagination info from response
      final pagination = data['pagination'] ?? {};
      final results = data['results'] ?? [];

      // Parse the money receipt list
      List<MoneyreceiptModel> moneyReceiptList = [];
      if (results is List) {
        moneyReceiptList = List<MoneyreceiptModel>.from(
          results.map((x) => MoneyreceiptModel.fromJson(x)),
        );
      }

      // Calculate pagination values
      int count = pagination['count'] ?? moneyReceiptList.length;
      int totalPages = pagination['total_pages'] ?? 1;
      int currentPage = pagination['current_page'] ?? event.pageNumber;
      int pageSize = pagination['page_size'] ?? event.pageSize;
      int from = ((currentPage - 1) * pageSize) + 1;
      int to = from + moneyReceiptList.length - 1;

      emit(MoneyReceiptListSuccess(
        list: moneyReceiptList,
        count: count,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
        from: from,
        to: to,
      ));
    } catch (error) {
      emit(MoneyReceiptListFailed(title: "Error", content: error.toString()));
    }
  }
  //
  // List<MoneyreceiptModel> _filterData(
  //     List<MoneyreceiptModel> warehouses,
  //     String filterTextMrNo,
  //     String customerName,
  //     String sellerName,
  //     String paymentType,
  //     DateTime? startDate,
  //     DateTime? endDate,
  //     ) {
  //
  //
  //   return warehouses.where((warehouse) {
  //     final matchesDate = (startDate == null || endDate == null) ||
  //         (warehouse.paymentDate != null &&
  //             ((warehouse.paymentDate!.isAfter(startDate) &&
  //                 warehouse.paymentDate!.isBefore(endDate)) ||
  //                 warehouse.paymentDate!.isAtSameMomentAs(startDate) ||
  //                 warehouse.paymentDate!.isAtSameMomentAs(endDate)));
  //
  //     final matchesMrNo = filterTextMrNo.isEmpty ||
  //         (warehouse.mrNo?.toLowerCase() ?? '').contains(filterTextMrNo.toLowerCase());
  //
  //     final matchesCustomer = customerName.isEmpty ||
  //         (warehouse.customerName?.toLowerCase() ?? '').contains(customerName.toLowerCase());
  //
  //     final matchesSeller = sellerName.isEmpty ||
  //         (warehouse.sellerName?.toLowerCase() ?? '').contains(sellerName.toLowerCase());
  //
  //     final matchesPaymentType = paymentType.isEmpty ||
  //         (warehouse.paymentMethod?.toLowerCase() ?? '').contains(paymentType.toLowerCase());
  //
  //     debugPrint(
  //         'Checking: MR:${warehouse.mrNo}, Customer:${warehouse.customerName}, Seller:${warehouse.sellerName}, '
  //             'PaymentType:${warehouse.paymentMethod}, Date:${warehouse.paymentDate} => '
  //             '[Date:$matchesDate | MR:$matchesMrNo | Custom:$matchesCustomer | Seller:$matchesSeller | Pay:$matchesPaymentType]'
  //     );
  //
  //     return matchesDate &&
  //         matchesMrNo &&
  //         matchesCustomer &&
  //         matchesSeller &&
  //         matchesPaymentType;
  //   }).toList();
  // }
  //

  Future<void> _onCreateMoneyReceiptList(
      AddMoneyReceipt event, Emitter<MoneyReceiptState> emit) async {
    emit(MoneyReceiptAddLoading());

    try {
      final res = await postResponse(
          url: AppUrls.moneyReceipt,
          payload: event.body); // Use the correct API URL


      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
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
