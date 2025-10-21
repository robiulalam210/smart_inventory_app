

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../sales/data/models/pos_sale_model.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../data/model/supplier_list_model.dart';
import '../../../data/model/supplier_payment/suppler_payment_model.dart';
import '../../../data/model/supplier_payment/supplier_payment_details.dart';

part 'supplier_payment_event.dart';
part 'supplier_payment_state.dart';

class SupplierPaymentBloc extends Bloc<SupplierPaymentEvent, SupplierPaymentState> {
  List<SupplierPaymentModel> allWarehouses = [];
  final int _itemsPerPage = 30;

  List paymentTo = ["Over All", "Specific"];
  TextEditingController filterTextController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  SupplierListModel? selectCustomerModel;
  UsersListModel? selectUserModel;
  PosSaleModel? selectPosSaleModel;
  String selectedPaymentToState = "Over All";
  String selectedAccount = "";
  String selectedAccountId = "";
  List paymentMethod = ["Bank", "Cash", "Mobile Banking"];
  String selectedPaymentMethod = "";
  late SupplierPaymentDetailsModel data;  // Changed to InventoryProductDetailsModel

  clearData(){
    filterTextController.clear();
    dateController.clear();
    amountController.clear();
    remarkController.clear();
    selectCustomerModel=null;
    selectUserModel=null;
    selectedAccountId='';
    selectedAccount='';
    selectedPaymentMethod='';
    selectedPaymentToState = "Over All";

  }
  SupplierPaymentBloc() : super(SupplierPaymentInitial()) {
   on<FetchSupplierPaymentList>(_onFetchMoneyReceiptList);
   on<AddSupplierPayment>(_onCreateWarehouseList);
   on<SupplierPaymentDetailsList>(_onFetchAccountDetails);
   on<SupplierPaymentDelete>(_onDeleteSupplierPayment);
  }



  Future<void> _onDeleteSupplierPayment(
      SupplierPaymentDelete event, Emitter<SupplierPaymentState> emit) async {

    emit(SupplierPaymentDeleteLoading());

    try {
      final res  = await deleteResponse(url: "${AppUrls.supplierPayment}/${event.id.toString()}"); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<SupplierPaymentModel>.from(data.map((x) => SupplierPaymentModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(SupplierPaymentDeleteFailed(title: 'Alert', content: response.message??""));
        return;
      }

      emit(SupplierPaymentDeleteSuccess(

      ));
    } catch (error) {

      emit(SupplierPaymentDeleteFailed(title: "Error",content: error.toString()));

    }
  }


  Future<void> _onFetchMoneyReceiptList(
      FetchSupplierPaymentList event, Emitter<SupplierPaymentState> emit) async {
    emit(SupplierPaymentListLoading());

    try {
      final res = await getResponse(
          url: AppUrls.supplierPayment, context: event.context); // Use the correct API URL

      // final response=warehouseBranchModelFromJson(res);

      ApiResponse<List<SupplierPaymentModel>> response =
      appParseJson<List<SupplierPaymentModel>>(
        res,
            (data) => List<SupplierPaymentModel>.from(
            data.map((x) => SupplierPaymentModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(SupplierPaymentListFailed(title: "Error", content: "No Data"));

        return;
      }
      // Store all warehouses for filtering and pagination
      allWarehouses = data;



      // Apply filtering and pagination
      final filteredWarehouses = _filterData(
          allWarehouses, event.filterText, event.startDate, event.endDate);
      final paginatedWarehouses =
      __paginatePage(filteredWarehouses, event.pageNumber);

      final totalPages = (filteredWarehouses.length / _itemsPerPage).ceil();

      emit(SupplierPaymentListSuccess(
        list: paginatedWarehouses,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(SupplierPaymentListFailed(title: "Error", content: error.toString()));
    }
  }
  List<SupplierPaymentModel> _filterData(
      List<SupplierPaymentModel> warehouses,
      String filterText,
      DateTime? startDate,
      DateTime? endDate) {
    return warehouses.where((warehouse) {
      // Check if the warehouse's paymentDate is not null and falls within the given date range
      final matchesDate = (startDate == null || endDate == null) ||
          (warehouse.paymentDate != null &&
              ((warehouse.paymentDate!.isAfter(startDate) &&
                  warehouse.paymentDate!.isBefore(endDate)) ||
                  warehouse.paymentDate!.isAtSameMomentAs(startDate) ||
                  warehouse.paymentDate!.isAtSameMomentAs(endDate)));

      // Check if the warehouse's supplierName or supplierPhone matches the filterText (case-insensitive)
      final matchesText = filterText.isEmpty ||
          (warehouse.supplierName?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
          (warehouse.supplierPhone?.toLowerCase().contains(filterText.toLowerCase()) ?? false);

      // Return true only if both conditions match
      return matchesDate && matchesText;
    }).toList();
  }


  List<SupplierPaymentModel> __paginatePage(
      List<SupplierPaymentModel> warehouses, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= warehouses.length) return [];
    return warehouses.sublist(
        start, end > warehouses.length ? warehouses.length : end);
  }



  Future<void> _onCreateWarehouseList(
      AddSupplierPayment event, Emitter<SupplierPaymentState> emit) async {

    emit(SupplierPaymentAddLoading());

    try {
      final res  = await postResponse(url: AppUrls.supplierPayment,payload: event.body); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<SupplierPaymentModel>.from(data.map((x) => SupplierPaymentModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(SupplierPaymentAddFailed(title: '', content: response.message??""));
        return;
      }
      clearData();
      emit(SupplierPaymentAddSuccess(

      ));
    } catch (error) {
      clearData();
      emit(SupplierPaymentAddFailed(title: "Error",content: error.toString()));

    }
  }


  Future<void> _onFetchAccountDetails(
      SupplierPaymentDetailsList event, Emitter<SupplierPaymentState> emit) async {

    emit(SupplierPaymentDetailsLoading());

    try {
      // Fetch the warehouse product details
      final warehouseRes = await getResponse(url:"${ AppUrls.supplierPayment}/${event.id.toString()}", context: event.context);
      ApiResponse<SupplierPaymentDetailsModel> warehouseResponse = appParseJson<SupplierPaymentDetailsModel>(
        warehouseRes,
            (data) => SupplierPaymentDetailsModel.fromJson(data),
      );

      final warehouseData = warehouseResponse.data;

      if (warehouseData == null) {
        emit(SupplierPaymentDetailsFailed(title: "Error", content: "No Data"));
        return;
      }

      data = warehouseData;

      emit(SupplierPaymentDetailsSuccess(details: warehouseData));
    } catch (error) {
      emit(SupplierPaymentDetailsFailed(title: "Error", content: error.toString()));
    }
  }
}

