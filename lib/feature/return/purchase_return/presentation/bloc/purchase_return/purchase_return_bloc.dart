import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:smart_inventory/core/configs/configs.dart';
import 'package:smart_inventory/core/repositories/delete_response.dart';
import 'package:smart_inventory/core/repositories/get_response.dart';
import 'package:smart_inventory/core/repositories/post_response.dart';
import 'package:smart_inventory/feature/accounts/data/model/account_active_model.dart';
import 'package:smart_inventory/feature/return/purchase_return/data/model/purchase_return_model.dart';

import '../../../../../supplier/data/model/supplier_active_model.dart';
import '../../../data/model/purchase_invoice_model.dart';
import '../../../data/model/purchase_return_create.dart';

part 'purchase_return_event.dart';
part 'purchase_return_state.dart';

class PurchaseReturnBloc extends Bloc<PurchaseReturnEvent, PurchaseReturnState> {
  List<PurchaseReturnModel> list = [];
  List<PurchaseInvoiceModel> invoiceList = [];
  String supplierInvoiceListModel = '';
  SupplierActiveModel? supplierActiveModel;
  AccountActiveModel? selectedAccount;
  final int _itemsPerPage = 20;

  TextEditingController filterTextController = TextEditingController();
  TextEditingController supplierTextController = TextEditingController();
  TextEditingController returnDateTextController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController(text: "Purchase return processed.");

  PurchaseReturnBloc() : super(PurchaseReturnInitial()) {
    on<FetchPurchaseReturn>(_onFetchPurchaseReturnList);
    on<CreatePurchaseReturn>(_onCreatePurchaseReturn);
    on<ViewPurchaseReturnDetails>(_onFetchPurchaseReturnDetails);
    on<DeletePurchaseReturn>(_onDeletePurchaseReturn);
    on<FetchPurchaseInvoiceList>(_onFetchPurchaseInvoiceList);
  }

  void clearData() {
    supplierTextController.clear();
    returnDateTextController.clear();
    remarkController.clear();
  }

  // Create Purchase Return
  Future<void> _onCreatePurchaseReturn(
      CreatePurchaseReturn event, Emitter<PurchaseReturnState> emit) async {
    emit(PurchaseReturnCreateLoading());

    try {
      final res = await postResponse(
        url: AppUrls.purchaseReturn,
        payload: event.body,
      );

      if (res['status'] == true) {
        final purchaseReturnData = PurchaseReturnCreatedModel.fromJson(res['data']);
        clearData();
        emit(PurchaseReturnCreateSuccess(
          message: res['message'] ?? "Purchase return created successfully",
          purchaseReturn: purchaseReturnData,
        ));
      } else {
        emit(PurchaseReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to create purchase return",
        ));
      }
    } catch (error) {
      emit(PurchaseReturnError(
        title: "Error",
        content: "Failed to create purchase return: ${error.toString()}",
      ));
    }
  }

  /// Fetch Purchase Return List
  Future<void> _onFetchPurchaseReturnList(
      FetchPurchaseReturn event, Emitter<PurchaseReturnState> emit) async {
    emit(PurchaseReturnLoading());

    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page_size': _itemsPerPage.toString(),
      };

      if (event.startDate != null) {
        queryParams['start_date'] = event.startDate!.toIso8601String().split('T').first;
      }
      if (event.endDate != null) {
        queryParams['end_date'] = event.endDate!.toIso8601String().split('T').first;
      }
      if (event.filterText?.isNotEmpty == true) {
        queryParams['search'] = event.filterText!;
      }
      if (event.supplierId != null) {
        queryParams['supplier_id'] = event.supplierId.toString();
      }
      if (event.pageNumber >= 0) {
        queryParams['page'] = (event.pageNumber + 1).toString();
      }

      // Build URL
      String url = AppUrls.purchaseReturn;
      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final responseString = await getResponse(url: url, context: event.context);
      final Map<String, dynamic> res = jsonDecode(responseString);

      if (res['status'] == true) {
        final data = res['data'];

        // Handle paginated response
        if (data['results'] != null) {
          List<PurchaseReturnModel> purchaseReturnList = List<PurchaseReturnModel>.from(
              data['results'].map((item) => PurchaseReturnModel.fromJson(item))
          );

          final totalPages = data['total_pages'] ?? 1;
          final currentPage = (data['current_page'] ?? 1) - 1; // Convert to 0-based index
          final totalCount = data['count'] ?? purchaseReturnList.length;
          final pageSize = data['page_size'] ?? _itemsPerPage;

          // Calculate from and to values for pagination display
          final from = (currentPage * pageSize) + 1;
          final to = from + purchaseReturnList.length - 1;

          list = purchaseReturnList;

          emit(PurchaseReturnSuccess(
            list: purchaseReturnList,
            count: totalCount,
            totalPages: totalPages,
            currentPage: currentPage,
            pageSize: pageSize,
            from: from,
            to: to,
          ));
        } else {
          // Handle non-paginated response (fallback)
          List<PurchaseReturnModel> purchaseReturnList = List<PurchaseReturnModel>.from(
              data.map((item) => PurchaseReturnModel.fromJson(item))
          );

          list = purchaseReturnList;

          // Apply manual filtering and pagination as fallback
          final filteredList = await _filterPurchaseReturn(purchaseReturnList, event.filterText ?? '');
          final paginatedList = _paginatePurchaseReturn(filteredList, event.pageNumber);
          final totalPages = (filteredList.length / _itemsPerPage).ceil();
          final from = (event.pageNumber * _itemsPerPage) + 1;
          final to = from + paginatedList.length - 1;

          emit(PurchaseReturnSuccess(
            list: paginatedList,
            count: filteredList.length,
            totalPages: totalPages,
            currentPage: event.pageNumber,
            pageSize: _itemsPerPage,
            from: from,
            to: to,
          ));
        }
      } else {
        emit(PurchaseReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to load purchase returns",
        ));
      }
    } catch (error) {
      emit(PurchaseReturnError(
        title: "Error",
        content: "Failed to load purchase returns: ${error.toString()}",
      ));
    }
  }

  // View Purchase Return Details
  Future<void> _onFetchPurchaseReturnDetails(
      ViewPurchaseReturnDetails event, Emitter<PurchaseReturnState> emit) async {
    emit(PurchaseReturnDetailsLoading());

    try {
      final responseString = await getResponse(
          url: "${AppUrls.purchaseReturn}/${event.id}",
          context: event.context
      );
      final Map<String, dynamic> res = jsonDecode(responseString);

      if (res['status'] == true) {
        final purchaseReturnData = PurchaseReturnModel.fromJson(res['data']);
        emit(PurchaseReturnDetailsLoaded(purchaseReturnData));
      } else {
        emit(PurchaseReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to load purchase return details",
        ));
      }
    } catch (error) {
      emit(PurchaseReturnError(
        title: "Error",
        content: "Failed to load purchase return details: ${error.toString()}",
      ));
    }
  }

  // Delete Purchase Return
  Future<void> _onDeletePurchaseReturn(
      DeletePurchaseReturn event, Emitter<PurchaseReturnState> emit) async {
    emit(PurchaseReturnDeleteLoading());

    try {
      final res = await deleteResponse(
        url: "${AppUrls.purchaseReturn}/${event.id}",
      );

      if (res['status'] == true) {
        emit(PurchaseReturnDeleteSuccess(
            message: res['message'] ?? "Purchase return deleted successfully"
        ));
      } else {
        emit(PurchaseReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to delete purchase return",
        ));
      }
    } catch (error) {
      emit(PurchaseReturnError(
        title: "Error",
        content: "Failed to delete purchase return: ${error.toString()}",
      ));
    }
  }

  Future<void> _onFetchPurchaseInvoiceList(
      FetchPurchaseInvoiceList event, Emitter<PurchaseReturnState> emit) async {
    emit(PurchaseInvoiceListLoading());

    try {

      final responseString = await getResponse(
          url: AppUrls.purchaseInvoice+event.id,
          context: event.context
      );


      final Map<String, dynamic> res = jsonDecode(responseString);

      if (res['status'] == true) {

        // Check if data exists and is a List
        if (res['data'] != null) {

          // Handle different data structures
          List<dynamic> dataList = [];

          if (res['data'] is List) {
            dataList = res['data'];
          } else if (res['data'] is Map) {
            // If data is a Map, check for results key (common in paginated responses)
            if (res['data']['results'] != null && res['data']['results'] is List) {
              dataList = res['data']['results'];
            } else {
            }
          }

          if (dataList.isNotEmpty) {

            List<PurchaseInvoiceModel> invoiceData = [];
            for (int i = 0; i < dataList.length; i++) {
              try {
                final item = dataList[i];

                final invoice = PurchaseInvoiceModel.fromJson(item);
                invoiceData.add(invoice);
              } catch (e) {
              }
            }

            invoiceList = invoiceData;

            emit(PurchaseInvoiceListSuccess(list: invoiceData));
          } else {
            emit(PurchaseInvoiceListSuccess(list: []));
          }
        } else {
          emit(PurchaseInvoiceError(
            title: "Error",
            content: "No data found in response",
          ));
        }
      } else {
        emit(PurchaseInvoiceError(
          title: "Error",
          content: res['message'] ?? "Failed to load purchase invoice list",
        ));
      }
    } catch (error) {

      emit(PurchaseInvoiceError(
        title: "Error",
        content: "Failed to load purchase invoice list: ${error.toString()}",
      ));
    }
  }

  // Helper methods for filtering and pagination
  Future<List<PurchaseReturnModel>> _filterPurchaseReturn(
      List<PurchaseReturnModel> purchaseReturns, String filterText) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (filterText.isEmpty) return purchaseReturns;

    return purchaseReturns.where((purchaseReturn) {
      return purchaseReturn.invoiceNo?.toLowerCase().contains(filterText.toLowerCase()) ?? false ||
          (purchaseReturn.reason?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
          (purchaseReturn.supplier?.name?.toLowerCase().contains(filterText.toLowerCase()) ?? false);
    }).toList();
  }

  List<PurchaseReturnModel> _paginatePurchaseReturn(
      List<PurchaseReturnModel> purchaseReturns, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (start >= purchaseReturns.length) return [];
    return purchaseReturns.sublist(
        start,
        end > purchaseReturns.length ? purchaseReturns.length : end
    );
  }
}