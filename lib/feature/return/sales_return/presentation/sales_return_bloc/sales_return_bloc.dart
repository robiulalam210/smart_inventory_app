import 'package:meherin_mart/feature/accounts/data/model/account_active_model.dart';
import 'package:meherin_mart/feature/return/sales_return/data/model/sales_invoice_model.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../data/model/sales_return_model.dart';
import '../../data/sales_return_create_model.dart';

part 'sales_return_event.dart';
part 'sales_return_state.dart';

class SalesReturnBloc extends Bloc<SalesReturnEvent, SalesReturnState> {
  List<SalesReturnModel> list = [];
  List<SalesInvoiceModel> invoiceList = [];
  SalesInvoiceModel? selectedInvoice;
  AccountActiveModel? selectedAccount;
  final int _itemsPerPage = 20;

  TextEditingController filterTextController = TextEditingController();
  TextEditingController customerTextController = TextEditingController();
  TextEditingController returnDateTextController = TextEditingController();
  TextEditingController remarkController = TextEditingController(text: "Thank you for choosing us.");

  SalesReturnBloc() : super(SalesReturnInitial()) {
    on<FetchSalesReturn>(_onFetchSalesReturnList);
    on<SalesReturnCreate>(_onCreateSalesReturn);
    on<ViewSalesReturnDetails>(_onFetchSalesReturnDetails);
    on<DeleteSalesReturn>(_onDeleteSalesReturn);
    on<FetchInvoiceList>(_onFetchSaleInvoiceList);
  }

  void clearData() {
    selectedInvoice = null;
    customerTextController.clear();
    returnDateTextController.clear();
    remarkController.clear();
  }

  // Create Sales Return
  Future<void> _onCreateSalesReturn(
      SalesReturnCreate event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnCreateLoading());

    try {
      final res = await postResponse(
          url: AppUrls.saleReturn,
          payload: event.body,
      );


      if (res['status'] == true) {
        final salesReturnData = SalesReturnCreatedModel.fromJson(res['data']);
        clearData();
        emit(SalesReturnCreateSuccess(
            message: res['message'] ?? "Sales return created successfully",
            salesReturn: salesReturnData
        ));
      } else {
        emit(SalesReturnError(
            title: "Error",
            content: res['message'] ?? "Failed to create sales return"
        ));
      }
    } catch (error) {
      emit(SalesReturnError(
          title: "Error",
          content: "Failed to create sales return: ${error.toString()}"
      ));
    }
  }

  /// Fetch Sales Return List
  Future<void> _onFetchSalesReturnList(
      FetchSalesReturn event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnLoading());

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
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.customerId != null) {
        queryParams['customer_id'] = event.customerId.toString();
      }
      if (event.pageNumber >= 0) {
        queryParams['page'] = (event.pageNumber + 1).toString();
      }

      // Build URL
      String url = AppUrls.saleReturn;
      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final responseString = await getResponse(url: url, context: event.context);
      final Map<String, dynamic> res = jsonDecode(responseString);

      if (res['status'] == true) {
        final data = res['data'];

        // Handle paginated response
        if (data['results'] != null) {
          List<SalesReturnModel> salesReturnList = List<SalesReturnModel>.from(
              data['results'].map((item) => SalesReturnModel.fromJson(item))
          );

          final totalPages = data['total_pages'] ?? 1;
          final currentPage = (data['current_page'] ?? 1) - 1; // Convert to 0-based index
          final totalCount = data['count'] ?? salesReturnList.length;
          final pageSize = data['page_size'] ?? _itemsPerPage;

          // Calculate from and to values for pagination display
          final from = (currentPage * pageSize) + 1;
          final to = from + salesReturnList.length - 1;

          list = salesReturnList;

          emit(SalesReturnSuccess(
            list: salesReturnList,
            count: totalCount,
            totalPages: totalPages,
            currentPage: currentPage,
            pageSize: pageSize,
            from: from,
            to: to,
          ));
        } else {
          // Handle non-paginated response (fallback)
          List<SalesReturnModel> salesReturnList = List<SalesReturnModel>.from(
              data.map((item) => SalesReturnModel.fromJson(item))
          );

          list = salesReturnList;

          // Apply manual filtering and pagination as fallback
          final filteredList = await _filterSalesReturn(salesReturnList, event.filterText);
          final paginatedList = _paginateSalesReturn(filteredList, event.pageNumber);
          final totalPages = (filteredList.length / _itemsPerPage).ceil();
          final from = (event.pageNumber * _itemsPerPage) + 1;
          final to = from + paginatedList.length - 1;

          emit(SalesReturnSuccess(
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
        emit(SalesReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to load sales returns",
        ));
      }
    } catch (error) {
      emit(SalesReturnError(
          title: "Error",
          content: "Failed to load sales returns: ${error.toString()}"
      ));
    }
  }

  // View Sales Return Details
  Future<void> _onFetchSalesReturnDetails(
      ViewSalesReturnDetails event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnDetailsLoading());

    try {
      final responseString = await getResponse(
          url: "${AppUrls.saleReturn}/${event.id}",
          context: event.context
      );
      final Map<String, dynamic> res = jsonDecode(responseString);

      if (res['status'] == true) {
        final salesReturnData = SalesReturnModel.fromJson(res['data']);
        emit(SalesReturnDetailsLoaded(salesReturnData));
      } else {
        emit(SalesReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to load sales return details",
        ));
      }
    } catch (error) {
      emit(SalesReturnError(
        title: "Error",
        content: "Failed to load sales return details: ${error.toString()}",
      ));
    }
  }

  // Delete Sales Return
  Future<void> _onDeleteSalesReturn(
      DeleteSalesReturn event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnDeleteLoading());

    try {
      final res = await deleteResponse(
          url: "${AppUrls.saleReturn}/${event.id}",
      );

      if (res['status'] == true) {
        emit(SalesReturnDeleteSuccess(
            message: res['message'] ?? "Sales return deleted successfully"
        ));
      } else {
        emit(SalesReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to delete sales return",
        ));
      }
    } catch (error) {
      emit(SalesReturnError(
        title: "Error",
        content: "Failed to delete sales return: ${error.toString()}",
      ));
    }
  }

  Future<void> _onFetchSaleInvoiceList(
      FetchInvoiceList event, Emitter<SalesReturnState> emit) async {
    emit(InvoiceListLoading());

    try {

      final responseString = await getResponse(
          url: AppUrls.posSaleInvoice,
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

            List<SalesInvoiceModel> invoiceData = [];
            for (int i = 0; i < dataList.length; i++) {
              try {
                final item = dataList[i];

                final invoice = SalesInvoiceModel.fromJson(item);
                invoiceData.add(invoice);
              } catch (e) {
                debugPrint(e.toString());

              }
            }

            invoiceList = invoiceData;

            emit(InvoiceListSuccess(list: invoiceData));
          } else {
            emit(InvoiceListSuccess(list: []));
          }
        } else {
          emit(InvoiceError(
            title: "Error",
            content: "No data found in response",
          ));
        }
      } else {
        emit(InvoiceError(
          title: "Error",
          content: res['message'] ?? "Failed to load invoice list",
        ));
      }
    } catch (error) {

      emit(InvoiceError(
        title: "Error",
        content: "Failed to load invoice list: ${error.toString()}",
      ));
    }
  }
  // Select Invoice

  // Helper methods for filtering and pagination
  Future<List<SalesReturnModel>> _filterSalesReturn(
      List<SalesReturnModel> salesReturns, String filterText) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (filterText.isEmpty) return salesReturns;

    return salesReturns.where((salesReturn) {
      return salesReturn.receiptNo?.toLowerCase().contains(filterText.toLowerCase()) ?? false ||
          (salesReturn.reason?.toLowerCase().contains(filterText.toLowerCase()) ?? false);
    }).toList();
  }

  List<SalesReturnModel> _paginateSalesReturn(
      List<SalesReturnModel> salesReturns, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (start >= salesReturns.length) return [];
    return salesReturns.sublist(
        start,
        end > salesReturns.length ? salesReturns.length : end
    );
  }
}