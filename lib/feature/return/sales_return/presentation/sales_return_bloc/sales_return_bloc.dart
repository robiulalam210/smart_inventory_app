import '/feature/accounts/data/model/account_active_model.dart';
import '/feature/return/sales_return/data/model/sales_invoice_model.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../data/model/sales_return_create_model.dart';
import '../../data/model/sales_return_model.dart';

part 'sales_return_event.dart';
part 'sales_return_state.dart';

// class SalesReturnBloc extends Bloc<SalesReturnEvent, SalesReturnState> {
//   List<SalesReturnModel> list = [];
//   List<SalesInvoiceModel> invoiceList = [];
//   SalesInvoiceModel? selectedInvoice;
//   AccountActiveModel? selectedAccount;
//   final int _itemsPerPage = 20;
//
//   TextEditingController filterTextController = TextEditingController();
//   TextEditingController customerTextController = TextEditingController();
//   TextEditingController returnDateTextController = TextEditingController();
//   TextEditingController remarkController = TextEditingController(text: "Thank you for choosing us.");
//
//   SalesReturnBloc() : super(SalesReturnInitial()) {
//     on<FetchSalesReturn>(_onFetchSalesReturnList);
//     on<SalesReturnCreate>(_onCreateSalesReturn);
//     on<ViewSalesReturnDetails>(_onFetchSalesReturnDetails);
//     on<DeleteSalesReturn>(_onDeleteSalesReturn);
//     on<FetchInvoiceList>(_onFetchSaleInvoiceList);
//   }
//
//   void clearData() {
//     selectedInvoice = null;
//     customerTextController.clear();
//     returnDateTextController.clear();
//     remarkController.clear();
//   }
//
//   // Create Sales Return
//   Future<void> _onCreateSalesReturn(
//       SalesReturnCreate event, Emitter<SalesReturnState> emit) async {
//     emit(SalesReturnCreateLoading());
//
//     try {
//       final res = await postResponse(
//           url: AppUrls.saleReturn,
//           payload: event.body,
//       );
//
//
//       if (res['status'] == true) {
//         final salesReturnData = SalesReturnCreatedModel.fromJson(res['data']);
//         clearData();
//         emit(SalesReturnCreateSuccess(
//             message: res['message'] ?? "Sales return created successfully",
//             salesReturn: salesReturnData
//         ));
//       } else {
//         emit(SalesReturnError(
//             title: "Error",
//             content: res['message'] ?? "Failed to create sales return"
//         ));
//       }
//     } catch (error) {
//       emit(SalesReturnError(
//           title: "Error",
//           content: "Failed to create sales return: ${error.toString()}"
//       ));
//     }
//   }
//
//   /// Fetch Sales Return List
//   Future<void> _onFetchSalesReturnList(
//       FetchSalesReturn event, Emitter<SalesReturnState> emit) async {
//     emit(SalesReturnLoading());
//
//     try {
//       // Build query parameters
//       final Map<String, String> queryParams = {
//         'page_size': _itemsPerPage.toString(),
//       };
//
//       if (event.startDate != null) {
//         queryParams['start_date'] = event.startDate!.toIso8601String().split('T').first;
//       }
//       if (event.endDate != null) {
//         queryParams['end_date'] = event.endDate!.toIso8601String().split('T').first;
//       }
//       if (event.filterText.isNotEmpty) {
//         queryParams['search'] = event.filterText;
//       }
//       if (event.customerId != null) {
//         queryParams['customer_id'] = event.customerId.toString();
//       }
//       if (event.pageNumber >= 0) {
//         queryParams['page'] = (event.pageNumber + 1).toString();
//       }
//
//       // Build URL
//       String url = AppUrls.saleReturn;
//       if (queryParams.isNotEmpty) {
//         url += '?${Uri(queryParameters: queryParams).query}';
//       }
//
//       final responseString = await getResponse(url: url, context: event.context);
//       final Map<String, dynamic> res = jsonDecode(responseString);
//
//       if (res['status'] == true) {
//         final data = res['data'];
//
//         // Handle paginated response
//         if (data['results'] != null) {
//           List<SalesReturnModel> salesReturnList = List<SalesReturnModel>.from(
//               data['results'].map((item) => SalesReturnModel.fromJson(item))
//           );
//
//           final totalPages = data['total_pages'] ?? 1;
//           final currentPage = (data['current_page'] ?? 1) - 1; // Convert to 0-based index
//           final totalCount = data['count'] ?? salesReturnList.length;
//           final pageSize = data['page_size'] ?? _itemsPerPage;
//
//           // Calculate from and to values for pagination display
//           final from = (currentPage * pageSize) + 1;
//           final to = from + salesReturnList.length - 1;
//
//           list = salesReturnList;
//
//           emit(SalesReturnSuccess(
//             list: salesReturnList,
//             count: totalCount,
//             totalPages: totalPages,
//             currentPage: currentPage,
//             pageSize: pageSize,
//             from: from,
//             to: to,
//           ));
//         } else {
//           // Handle non-paginated response (fallback)
//           List<SalesReturnModel> salesReturnList = List<SalesReturnModel>.from(
//               data.map((item) => SalesReturnModel.fromJson(item))
//           );
//
//           list = salesReturnList;
//
//           // Apply manual filtering and pagination as fallback
//           final filteredList = await _filterSalesReturn(salesReturnList, event.filterText);
//           final paginatedList = _paginateSalesReturn(filteredList, event.pageNumber);
//           final totalPages = (filteredList.length / _itemsPerPage).ceil();
//           final from = (event.pageNumber * _itemsPerPage) + 1;
//           final to = from + paginatedList.length - 1;
//
//           emit(SalesReturnSuccess(
//             list: paginatedList,
//             count: filteredList.length,
//             totalPages: totalPages,
//             currentPage: event.pageNumber,
//             pageSize: _itemsPerPage,
//             from: from,
//             to: to,
//           ));
//         }
//       } else {
//         emit(SalesReturnError(
//           title: "Error",
//           content: res['message'] ?? "Failed to load sales returns",
//         ));
//       }
//     } catch (error) {
//       emit(SalesReturnError(
//           title: "Error",
//           content: "Failed to load sales returns: ${error.toString()}"
//       ));
//     }
//   }
//
//   // View Sales Return Details
//   Future<void> _onFetchSalesReturnDetails(
//       ViewSalesReturnDetails event, Emitter<SalesReturnState> emit) async {
//     emit(SalesReturnDetailsLoading());
//
//     try {
//       final responseString = await getResponse(
//           url: "${AppUrls.saleReturn}/${event.id}",
//           context: event.context
//       );
//       final Map<String, dynamic> res = jsonDecode(responseString);
//
//       if (res['status'] == true) {
//         final salesReturnData = SalesReturnModel.fromJson(res['data']);
//         emit(SalesReturnDetailsLoaded(salesReturnData));
//       } else {
//         emit(SalesReturnError(
//           title: "Error",
//           content: res['message'] ?? "Failed to load sales return details",
//         ));
//       }
//     } catch (error) {
//       emit(SalesReturnError(
//         title: "Error",
//         content: "Failed to load sales return details: ${error.toString()}",
//       ));
//     }
//   }
//
//   // Delete Sales Return
//   Future<void> _onDeleteSalesReturn(
//       DeleteSalesReturn event, Emitter<SalesReturnState> emit) async {
//     emit(SalesReturnDeleteLoading());
//
//     try {
//       final res = await deleteResponse(
//           url: "${AppUrls.saleReturn}/${event.id}",
//       );
//
//       if (res['status'] == true) {
//         emit(SalesReturnDeleteSuccess(
//             message: res['message'] ?? "Sales return deleted successfully"
//         ));
//       } else {
//         emit(SalesReturnError(
//           title: "Error",
//           content: res['message'] ?? "Failed to delete sales return",
//         ));
//       }
//     } catch (error) {
//       emit(SalesReturnError(
//         title: "Error",
//         content: "Failed to delete sales return: ${error.toString()}",
//       ));
//     }
//   }
//
//   Future<void> _onFetchSaleInvoiceList(
//       FetchInvoiceList event, Emitter<SalesReturnState> emit) async {
//     emit(InvoiceListLoading());
//
//     try {
//
//       final responseString = await getResponse(
//           url: AppUrls.posSaleInvoice,
//           context: event.context
//       );
//
//
//       final Map<String, dynamic> res = jsonDecode(responseString);
//
//       if (res['status'] == true) {
//
//         // Check if data exists and is a List
//         if (res['data'] != null) {
//
//           // Handle different data structures
//           List<dynamic> dataList = [];
//
//           if (res['data'] is List) {
//             dataList = res['data'];
//           } else if (res['data'] is Map) {
//             // If data is a Map, check for results key (common in paginated responses)
//             if (res['data']['results'] != null && res['data']['results'] is List) {
//               dataList = res['data']['results'];
//             } else {
//             }
//           }
//
//           if (dataList.isNotEmpty) {
//
//             List<SalesInvoiceModel> invoiceData = [];
//             for (int i = 0; i < dataList.length; i++) {
//               try {
//                 final item = dataList[i];
//
//                 final invoice = SalesInvoiceModel.fromJson(item);
//                 invoiceData.add(invoice);
//               } catch (e) {
//                 debugPrint(e.toString());
//
//               }
//             }
//
//             invoiceList = invoiceData;
//
//             emit(InvoiceListSuccess(list: invoiceData));
//           } else {
//             emit(InvoiceListSuccess(list: []));
//           }
//         } else {
//           emit(InvoiceError(
//             title: "Error",
//             content: "No data found in response",
//           ));
//         }
//       } else {
//         emit(InvoiceError(
//           title: "Error",
//           content: res['message'] ?? "Failed to load invoice list",
//         ));
//       }
//     } catch (error) {
//
//       emit(InvoiceError(
//         title: "Error",
//         content: "Failed to load invoice list: ${error.toString()}",
//       ));
//     }
//   }
//   // Select Invoice
//
//   // Helper methods for filtering and pagination
//   Future<List<SalesReturnModel>> _filterSalesReturn(
//       List<SalesReturnModel> salesReturns, String filterText) async {
//     await Future.delayed(const Duration(milliseconds: 100));
//
//     if (filterText.isEmpty) return salesReturns;
//
//     return salesReturns.where((salesReturn) {
//       return salesReturn.receiptNo?.toLowerCase().contains(filterText.toLowerCase()) ?? false ||
//           (salesReturn.reason?.toLowerCase().contains(filterText.toLowerCase()) ?? false);
//     }).toList();
//   }
//
//   List<SalesReturnModel> _paginateSalesReturn(
//       List<SalesReturnModel> salesReturns, int pageNumber) {
//     final start = pageNumber * _itemsPerPage;
//     final end = start + _itemsPerPage;
//
//     if (start >= salesReturns.length) return [];
//     return salesReturns.sublist(
//         start,
//         end > salesReturns.length ? salesReturns.length : end
//     );
//   }
// }


// sales_return_bloc/sales_return_bloc.dart - Update handler methods
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
    on<SalesReturnApprove>(_onApproveSalesReturn);
    on<SalesReturnReject>(_onRejectSalesReturn);
    on<SalesReturnComplete>(_onCompleteSalesReturn);
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
      SalesReturnCreate event,
      Emitter<SalesReturnState> emit,
      ) async {
    emit(SalesReturnCreateLoading());

    try {
      final res = await postResponse(
        url: AppUrls.saleReturn,
        payload: event.body.toJson(),
      );

      // 🔒 Top-level success check
      if (res['status'] == true && res['data'] != null) {
        final innerData = res['data'];

        // 🔒 Inner success check
        if (innerData['status'] == true && innerData['data'] != null) {
          final salesReturnJson = innerData['data'];

          final salesReturn =
          SalesReturnModel.fromJson(salesReturnJson);

          clearData();

          emit(
            SalesReturnCreateSuccess(
              message: innerData['message']?.toString()
                  ?? res['message']?.toString()
                  ?? "Sales return created successfully",
              salesReturn: salesReturn,
            ),
          );
        } else {
          emit(
            SalesReturnError(
              title: "Error",
              content: innerData['message']?.toString()
                  ?? "Failed to create sales return",
            ),
          );
        }
      } else {
        emit(
          SalesReturnError(
            title: "Error",
            content: res['message']?.toString()
                ?? "Failed to create sales return",
          ),
        );
      }
    } catch (error) {
      emit(
        SalesReturnError(
          title: "Error",
          content: "Failed to create sales return: ${error.toString()}",
        ),
      );
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
          final currentPage = (data['current_page'] ?? 1) - 1;
          final totalCount = data['count'] ?? salesReturnList.length;
          final pageSize = data['page_size'] ?? _itemsPerPage;

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
          // Handle non-paginated response
          List<SalesReturnModel> salesReturnList = List<SalesReturnModel>.from(
              data.map((item) => SalesReturnModel.fromJson(item))
          );

          list = salesReturnList;
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

  // Approve Sales Return
  Future<void> _onApproveSalesReturn(
      SalesReturnApprove event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnApproveLoading());

    try {
      final res = await postResponse(
        url: "${AppUrls.saleReturn}${event.id}/approve/",
        payload: {},
      );

      if (res['status'] == true) {
        final salesReturnData = SalesReturnModel.fromJson(res['data']);

        // Update the local list
        final index = list.indexWhere((item) => item.id == event.id);
        if (index != -1) {
          list[index] = salesReturnData;
        }

        emit(SalesReturnApproveSuccess(
          message: res['message'] ?? "Sales return approved successfully",
          salesReturn: salesReturnData,
        ));
      } else {
        // Handle backend error
        String errorMessage = res['message'] ?? "Failed to approve sales return";

        // Check for specific error messages
        if (errorMessage.contains("Cannot approve") ||
            errorMessage.contains("already") ||
            errorMessage.contains("Invalid status")) {
          // Status-related error
          emit(SalesReturnError(
            title: "Cannot Approve",
            content: errorMessage,
          ));
        } else if (errorMessage.contains("stock") ||
            errorMessage.contains("Stock") ||
            errorMessage.contains("product")) {
          // Stock-related error
          emit(SalesReturnError(
            title: "Stock Update Failed",
            content: "Unable to update product stock. Please check product availability.",
          ));
        } else {
          // General error
          emit(SalesReturnError(
            title: "Error",
            content: errorMessage,
          ));
        }
      }
    } catch (error) {
      emit(SalesReturnError(
        title: "Network Error",
        content: "Failed to approve sales return. Please check your connection.",
      ));
    }
  }
  // Reject Sales Return
  Future<void> _onRejectSalesReturn(
      SalesReturnReject event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnRejectLoading());

    try {
      final res = await postResponse(
        url: "${AppUrls.saleReturn}${event.id}/reject/",
        payload: {},
      );

      if (res['status'] == true) {
        final salesReturnData = SalesReturnModel.fromJson(res['data']);
        emit(SalesReturnRejectSuccess(
          message: res['message'] ?? "Sales return rejected successfully",
          salesReturn: salesReturnData,
        ));
      } else {
        emit(SalesReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to reject sales return",
        ));
      }
    } catch (error) {
      emit(SalesReturnError(
        title: "Error",
        content: "Failed to reject sales return: ${error.toString()}",
      ));
    }
  }

  // Complete Sales Return
  Future<void> _onCompleteSalesReturn(
      SalesReturnComplete event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnCompleteLoading());

    try {
      final res = await postResponse(
        url: "${AppUrls.saleReturn}${event.id}/complete/",
        payload: {},
      );

      if (res['status'] == true) {
        final salesReturnData = SalesReturnModel.fromJson(res['data']);
        emit(SalesReturnCompleteSuccess(
          message: res['message'] ?? "Sales return completed successfully",
          salesReturn: salesReturnData,
        ));
      } else {
        emit(SalesReturnError(
          title: "Error",
          content: res['message'] ?? "Failed to complete sales return",
        ));
      }
    } catch (error) {
      emit(SalesReturnError(
        title: "Error",
        content: "Failed to complete sales return: ${error.toString()}",
      ));
    }
  }

  // View Sales Return Details
  Future<void> _onFetchSalesReturnDetails(
      ViewSalesReturnDetails event, Emitter<SalesReturnState> emit) async {
    emit(SalesReturnDetailsLoading());

    try {
      final responseString = await getResponse(
          url: "${AppUrls.saleReturn}${event.id}",
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
        url: "${AppUrls.saleReturn}${event.id}/",
      );

      if (res['status'] == true) {
        // Remove from local list
        list.removeWhere((item) => item.id == event.id);

        emit(SalesReturnDeleteSuccess(
          message: res['message'] ?? "Sales return deleted successfully",
        ));
      } else {
        String errorMessage = res['message'] ?? "Failed to delete sales return";

        // Check if it's a status-related error
        if (errorMessage.contains("Cannot delete") ||
            errorMessage.contains("already approved") ||
            errorMessage.contains("completed")) {
          emit(SalesReturnError(
            title: "Cannot Delete",
            content: "Only pending or rejected returns can be deleted.",
          ));
        } else {
          emit(SalesReturnError(
            title: "Error",
            content: errorMessage,
          ));
        }
      }
    } catch (error) {
      // Handle specific HTTP errors
      if (error.toString().contains("500")) {
        emit(SalesReturnError(
          title: "Server Error",
          content: "Server error occurred while deleting. Please try again.",
        ));
      } else {
        emit(SalesReturnError(
          title: "Error",
          content: "Failed to delete sales return: ${error.toString()}",
        ));
      }
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
        if (res['data'] != null) {
          List<dynamic> dataList = [];

          if (res['data'] is List) {
            dataList = res['data'];
          } else if (res['data'] is Map) {
            if (res['data']['results'] != null && res['data']['results'] is List) {
              dataList = res['data']['results'];
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

  // Helper methods
  Future<List<SalesReturnModel>> _filterSalesReturn(
      List<SalesReturnModel> salesReturns, String filterText) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (filterText.isEmpty) return salesReturns;

    return salesReturns.where((salesReturn) {
      return salesReturn.receiptNo?.toLowerCase().contains(filterText.toLowerCase()) ?? false ||
          (salesReturn.customerName?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
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