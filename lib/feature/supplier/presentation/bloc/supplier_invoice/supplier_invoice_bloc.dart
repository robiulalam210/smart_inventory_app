import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/supplier_active_model.dart';
import '../../../data/model/supplier_invoice_list_model.dart';

part 'supplier_invoice_event.dart';
part 'supplier_invoice_state.dart';

class SupplierInvoiceBloc
    extends Bloc<SupplierInvoiceEvent, SupplierInvoiceState> {
  List<SupplierInvoiceListModel> supplierListModel = [];
  List<SupplierActiveModel> supplierActiveList = [];
  String supplierInvoiceListModel = '';
  List<String> statesList = ["Paid", "Due", "Partially Paid"];

  TextEditingController filterTextController = TextEditingController();

  SupplierInvoiceBloc() : super(SupplierInvoiceInitial()) {
    on<FetchSupplierInvoiceList>(_onFetchSupplierInvoiceList);
    on<FetchSupplierActiveList>(_onFetchSupplierActiveList); // Fixed syntax error
  }

  Future<void> _onFetchSupplierInvoiceList(
      FetchSupplierInvoiceList event,
      Emitter<SupplierInvoiceState> emit,
      ) async {
    emit(SupplierInvoiceListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.supplierInvoiceList + event.dropdownFilter,
        context: event.context,
      );

      ApiResponse<List<SupplierInvoiceListModel>> response =
      appParseJson<List<SupplierInvoiceListModel>>(
        res,
            (data) => List<SupplierInvoiceListModel>.from(
          data.map((x) => SupplierInvoiceListModel.fromJson(x)),
        ),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(SupplierInvoiceListSuccess(
          list: [],
          totalPages: 1,
          currentPage: event.pageNumber,
        ));
        return;
      }

      // Store all warehouses for filtering and pagination
      supplierListModel = data;

      emit(SupplierInvoiceListSuccess(
        list: supplierListModel,
        totalPages: 1,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(SupplierInvoiceListFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }

  Future<void> _onFetchSupplierActiveList(
      FetchSupplierActiveList event, // Fixed parameter type
      Emitter<SupplierInvoiceState> emit,
      ) async {
    emit(SupplierActiveListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.supplierActiveList, // Use correct API URL for active suppliers
        context: event.context,
      );

      ApiResponse<List<SupplierActiveModel>> response =
      appParseJson<List<SupplierActiveModel>>(
        res,
            (data) => List<SupplierActiveModel>.from(
          data.map((x) => SupplierActiveModel.fromJson(x)),
        ),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(SupplierActiveListSuccess(list: []));
        return;
      }

      // Store all active suppliers
      supplierActiveList = data;

      emit(SupplierActiveListSuccess(list: supplierActiveList));
    } catch (error) {
      emit(SupplierActiveListFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }
}