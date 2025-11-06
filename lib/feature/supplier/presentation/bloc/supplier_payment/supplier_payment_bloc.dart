import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
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
  late SupplierPaymentDetailsModel data;

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
    on<FetchSupplierPaymentList>(_onFetchSupplierPaymentList);
    on<AddSupplierPayment>(_onCreateWarehouseList);
    on<SupplierPaymentDetailsList>(_onFetchAccountDetails);
    on<SupplierPaymentDelete>(_onDeleteSupplierPayment);
  }

  Future<void> _onDeleteSupplierPayment(
      SupplierPaymentDelete event, Emitter<SupplierPaymentState> emit) async {

    emit(SupplierPaymentDeleteLoading());

    try {
      final res  = await deleteResponse(url: "${AppUrls.supplierPayment}/${event.id.toString()}");

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );
      if (response.success == false) {
        emit(SupplierPaymentDeleteFailed(title: 'Alert', content: response.message??""));
        return;
      }

      emit(SupplierPaymentDeleteSuccess());
    } catch (error) {
      emit(SupplierPaymentDeleteFailed(title: "Error",content: error.toString()));
    }
  }

  Future<void> _onFetchSupplierPaymentList(
      FetchSupplierPaymentList event,
      Emitter<SupplierPaymentState> emit,
      ) async {
    emit(SupplierPaymentListLoading());

    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {
        'page': (event.pageNumber + 1).toString(), // Django uses 1-based pagination
        'page_size': event.pageSize.toString(),
      };

      // Add search parameter
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }

      // Add date filters
      if (event.startDate != null) {
        queryParams['start_date'] = _formatDate(event.startDate!);
      }
      if (event.endDate != null) {
        queryParams['end_date'] = _formatDate(event.endDate!);
      }

      final res = await getResponse(
        url: AppUrls.supplierPayment,
        queryParams: queryParams,
        context: event.context,
      );

      // Parse response
      final Map<String, dynamic> payload = jsonDecode(res) as Map<String, dynamic>;
      final bool ok = (payload['status'] == true) || (payload['success'] == true);

      if (ok) {
        final data = payload['data'] ?? {};
        final List<dynamic> results = (data['results'] is List)
            ? List<dynamic>.from(data['results'])
            : [];

        // Parse supplier payment list
        final list = results.map((x) => SupplierPaymentModel.fromJson(Map<String, dynamic>.from(x))).toList();

        // Extract pagination info from API response
        final Map<String, dynamic> pagination = Map<String, dynamic>.from(data['pagination'] ?? {});

        final int totalPages = (pagination['total_pages'] is int)
            ? pagination['total_pages'] as int
            : 1;

        final int currentPage = (pagination['current_page'] is int)
            ? pagination['current_page'] as int
            : (event.pageNumber + 1);

        final int count = (pagination['count'] is int)
            ? pagination['count'] as int
            : list.length;

        final int pageSize = (pagination['page_size'] is int)
            ? pagination['page_size'] as int
            : event.pageSize;

        // Calculate from and to values
        final int from = (pagination['from'] is int)
            ? pagination['from'] as int
            : ((currentPage - 1) * pageSize + 1);

        final int to = (pagination['to'] is int)
            ? pagination['to'] as int
            : (from + list.length - 1);

        emit(
          SupplierPaymentListSuccess(
            list: list,
            totalPages: totalPages,
            currentPage: currentPage - 1, // Convert to 0-based for Flutter
            count: count,
            pageSize: pageSize,
            from: from,
            to: to,
          ),
        );
      } else {
        final message = payload['message'] ?? payload['error'] ?? 'Unknown error occurred';
        emit(SupplierPaymentListFailed(title: "Error", content: message));
      }
    } catch (error, st) {
      debugPrint('Supplier Payment List Error: $error');
      debugPrint(st.toString());
      emit(SupplierPaymentListFailed(title: "Error", content: error.toString()));
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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

  List<SupplierPaymentModel> _paginateData(
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
      final res  = await postResponse(url: AppUrls.supplierPayment,payload: event.body);

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => SupplierPaymentModel.fromJson(data),
      );

      if (response.success == false) {
        emit(SupplierPaymentAddFailed(title: '', content: response.message??""));
        return;
      }
      clearData();
      emit(SupplierPaymentAddSuccess());
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