// transactions/presentation/bloc/transaction/transaction_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../../../core/configs/app_urls.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/transactions_model.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<FetchTransactionList>(_onFetchTransactionList);

  }

  Future<void> _onFetchTransactionList(
      FetchTransactionList event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionListLoading());

    try {
      // Build URL with parameters
      final Map<String, String> queryParams = {
        if (event.noPagination) 'no_pagination': 'true',
        if (event.pageNumber > 1) 'page': event.pageNumber.toString(),
        if (event.pageSize != 10) 'page_size': event.pageSize.toString(),
        if (event.filterText.isNotEmpty) 'search': event.filterText,
        if (event.accountId != null) 'account_id': event.accountId!,
        if (event.transactionType != null) 'transaction_type': event.transactionType!,
        if (event.status != null) 'status': event.status!,
        if (event.startDate != null) 'start_date': _formatDate(event.startDate!),
        if (event.endDate != null) 'end_date': _formatDate(event.endDate!),
      };

      final Uri uri = Uri.parse(AppUrls.transactions).replace(
        queryParameters: queryParams,
      );

      final response = await getResponse(
        url: uri.toString(),
        context: event.context,
      );

      final ApiResponse<Map<String, dynamic>> apiResponse =
      appParseJson<Map<String, dynamic>>(response, (data) => data);

      if (apiResponse.data == null) {
        emit( TransactionListSuccess(
          list: [],
          count: 0,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
          from: 0,
          to: 0,
        ));
        return;
      }

      // Handle both paginated and non-paginated responses
      final responseData = apiResponse.data!['data'] ?? apiResponse.data!;
      final results = responseData['results'] ?? responseData;

      List<TransactionsModel> transactionList = [];
      if (results is List) {
        transactionList = List<TransactionsModel>.from(
          results.map((x) => TransactionsModel.fromJson(x)),
        );
      }

      // Extract pagination data
      int totalCount = responseData['count'] ?? transactionList.length;
      int totalPages = responseData['total_pages'] ?? 1;
      int currentPage = responseData['current_page'] ?? 1;
      int pageSize = responseData['page_size'] ?? event.pageSize;
      int from = responseData['from'] ?? (transactionList.isNotEmpty ? 1 : 0);
      int to = responseData['to'] ?? transactionList.length;

      emit(TransactionListSuccess(
        list: transactionList,
        count: totalCount,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
        from: from,
        to: to,
      ));
    } catch (error) {
      emit(TransactionListFailed(
        title: "Error",
        content: error.toString(),
      ));
    }
  }




  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}