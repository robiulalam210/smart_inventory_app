import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/repositories/get_response.dart';
import '../data/model/bad_stock_return/bad_stock_return_model.dart';

part 'bad_stock_list_event.dart';
part 'bad_stock_list_state.dart';

class BadStockListBloc extends Bloc<BadStockListEvent, BadStockListState> {
  List<BadStockReturnModel> badStockReturnList = [];
  final int _itemsPerPage = 15;

  BadStockListBloc() : super(BadStockListInitial()) {
    on<FetchBadStockList>(_onFetchBadStockList);
  }

  /// Fetch Bad Stock List
  Future<void> _onFetchBadStockList(
      FetchBadStockList event, Emitter<BadStockListState> emit) async {
    emit(BadStockListLoading());

    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page_size': _itemsPerPage.toString(),
      };

      if (event.from != null) {
        queryParams['from'] = event.from!.toIso8601String().split('T').first;
      }
      if (event.to != null) {
        queryParams['to'] = event.to!.toIso8601String().split('T').first;
      }
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.location != null) {
        queryParams['location_id'] = event.location.toString();
      }
      if (event.pageNumber >= 0) {
        queryParams['page'] = (event.pageNumber + 1).toString();
      }

      // Build URL
      String url = AppUrls.badStock;
      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final responseString = await getResponse(
          url: url,
          context: event.context
      );
      final Map<String, dynamic> res = jsonDecode(responseString);

      if (res['status'] == true) {
        final data = res['data'];

        // Handle paginated response
        if (data['results'] != null) {
          List<BadStockReturnModel> badStockList = List<BadStockReturnModel>.from(
              data['results'].map((item) => BadStockReturnModel.fromJson(item))
          );

          final totalPages = data['total_pages'] ?? 1;
          final currentPage = (data['current_page'] ?? 1) - 1; // Convert to 0-based index
          final totalCount = data['count'] ?? badStockList.length;
          final pageSize = data['page_size'] ?? _itemsPerPage;

          // Calculate from and to values for pagination display
          final from = (currentPage * pageSize) + 1;
          final to = from + badStockList.length - 1;

          badStockReturnList = badStockList;

          emit(BadStockListSuccess(
            list: badStockList,
            count: totalCount,
            totalPages: totalPages,
            currentPage: currentPage,
            pageSize: pageSize,
            from: from,
            to: to,
          ));
        } else {
          // Handle non-paginated response (fallback)
          List<BadStockReturnModel> badStockList = List<BadStockReturnModel>.from(
              data.map((item) => BadStockReturnModel.fromJson(item))
          );

          badStockReturnList = badStockList;

          // Apply manual filtering as fallback
          final filteredList = _filterBadStocks(badStockList, event.filterText);
          final totalPages = (filteredList.length / _itemsPerPage).ceil();
          final from = (event.pageNumber * _itemsPerPage) + 1;
          final to = from + filteredList.length - 1;

          emit(BadStockListSuccess(
            list: filteredList,
            count: filteredList.length,
            totalPages: totalPages,
            currentPage: event.pageNumber,
            pageSize: _itemsPerPage,
            from: from,
            to: to,
          ));
        }
      } else {
        emit(BadStockListFailed(
          title: "Error",
          content: res['message'] ?? "Failed to load bad stock returns",
        ));
      }
    } catch (error) {
      emit(BadStockListFailed(
        title: "Error",
        content: "Failed to load bad stock returns: ${error.toString()}",
      ));
    }
  }

  // Local filtering method for fallback
  List<BadStockReturnModel> _filterBadStocks(
      List<BadStockReturnModel> allStocks,
      String filterText,
      ) {
    if (filterText.isEmpty) return allStocks;

    return allStocks.where((stock) {
      return stock.productName?.toLowerCase().contains(filterText.toLowerCase()) == true ||
          stock.reason?.toLowerCase().contains(filterText.toLowerCase()) == true ||
          stock.referenceType?.toLowerCase().contains(filterText.toLowerCase()) == true;
    }).toList();
  }

// Removed _paginateList method as requested
}