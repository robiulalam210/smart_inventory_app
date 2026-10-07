import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/repositories/delete_response.dart';
import '../../../../core/repositories/get_response.dart';
import '../../../../core/repositories/patch_response.dart';
import '../../../../core/repositories/post_response.dart';
import '../../../common/data/models/api_response_mod.dart';
import '../../../common/data/models/app_parse_json.dart';
import '../../data/model/income_model.dart';

part 'income_event.dart';
part 'income_state.dart';




class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  List<IncomeModel> allIncomes = [];
  TextEditingController filterTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();
  TextEditingController noteTextController = TextEditingController();
  TextEditingController dateIncomeTextController = TextEditingController();

  IncomeBloc() : super(IncomeInitial()) {
    on<FetchIncomeList>(_onFetchIncomeList);
    on<AddIncome>(_onAddIncome);
    on<UpdateIncome>(_onUpdateIncome);
    on<DeleteIncome>(_onDeleteIncome);
  }

  void clearData() {
    amountTextController.clear();
    noteTextController.clear();
    filterTextController.clear();
    dateIncomeTextController.clear();
  }

  Future<void> _onFetchIncomeList(FetchIncomeList event, Emitter<IncomeState> emit) async {
    emit(IncomeListLoading());
    try {
      // Query params
      Map<String, String> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };
      if (event.filterText.isNotEmpty) queryParams['search'] = event.filterText;
      if (event.startDate != null) queryParams['start_date'] = event.startDate!.toIso8601String().split('T')[0];
      if (event.endDate != null) queryParams['end_date'] = event.endDate!.toIso8601String().split('T')[0];
      if (event.headId != null && event.headId!.isNotEmpty) queryParams['head_id'] = event.headId!;
      if (event.accountId != null && event.accountId!.isNotEmpty) queryParams['account_id'] = event.accountId!;

      final res = await getResponse(
        url: AppUrls.income,
        context: event.context,
        queryParams: queryParams,
      );

      // Use dynamic to support both Map and List response types!
      final ApiResponse<dynamic> response = appParseJson<dynamic>(
        res,
            (data) => data,
      );


      if (response.success == false || response.data == null) {
        emit(IncomeListFailed(
            title: "Error",
            content: response.message ?? "Failed to fetch incomes"
        ));
        return;
      }

      dynamic responseData = response.data;
      // Robustly handle cases where `data` is a list or a map.
      List results = [];
      Map pagination = {};
      if (responseData is List) {
        // The top-level `data` is a list.
        results = responseData;
      } else if (responseData is Map) {
        // The top-level `data` may itself be a dict with results or just the actual data.
        dynamic data = responseData['data'] ?? responseData;
        if (data is Map && data.containsKey('results')) {
          results = data['results'] ?? [];
          pagination = data['pagination'] ?? {};
        } else if (data is List) {
          results = data;
        } else if (data is Map && data.containsKey('data')) {
          results = data['data'] ?? [];
        }
      }
      // Defensive printouts

      List<IncomeModel> incomes = results
          .whereType<Map>()
          .map((x) => IncomeModel.fromJson(Map<String, dynamic>.from(x)))
          .toList();

      int pageSize = event.pageSize <= 0 ? 10 : event.pageSize;
      int count;
      int currentPage;
      int totalPages;

      if (pagination.isNotEmpty) {
        // সার্ভার নিজেই pagination করেছে
        count = _safeParseInt(
            pagination['count'] ?? pagination['total'] ?? pagination['total_items'],
            incomes.length);
        currentPage = _safeParseInt(pagination['current_page'], event.pageNumber);
        pageSize = _safeParseInt(pagination['page_size'], pageSize);
        if (pageSize <= 0) pageSize = event.pageSize <= 0 ? 10 : event.pageSize;
        totalPages =
            _safeParseInt(pagination['total_pages'], (count / pageSize).ceil());
      } else {
        // সার্ভার pagination/filter ছাড়া পুরো list দিলে এখানে filter + pagination করা হয়
        // (আগে count=0 হয়ে "Showing 1 to 7 of 0" দেখাত এবং date filter কাজ করত না)
        incomes = _applyLocalFilters(incomes, event);
        count = incomes.length;
        totalPages = count == 0 ? 1 : (count / pageSize).ceil();
        currentPage = event.pageNumber.clamp(1, totalPages).toInt();
        incomes =
            incomes.skip((currentPage - 1) * pageSize).take(pageSize).toList();
      }
      if (totalPages < 1) totalPages = 1;
      final from = incomes.isEmpty ? 0 : ((currentPage - 1) * pageSize) + 1;
      final to = incomes.isEmpty ? 0 : from + incomes.length - 1;

      emit(IncomeListSuccess(
        list: incomes,
        totalPages: totalPages,
        currentPage: currentPage,
        count: count,
        pageSize: pageSize,
        from: from,
        to: to,
      ));
    } catch (error) {
      emit(IncomeListFailed(title: "Error", content: error.toString()));
    }
  }

  List<IncomeModel> _applyLocalFilters(
      List<IncomeModel> list, FetchIncomeList e) {
    DateTime? day(DateTime? d) =>
        d == null ? null : DateTime(d.year, d.month, d.day);
    final start = day(e.startDate);
    final end = day(e.endDate);
    final q = e.filterText.trim().toLowerCase();
    return list.where((i) {
      if (start != null || end != null) {
        final d = day(DateTime.tryParse(i.incomeDate ?? ''));
        if (d == null) return false;
        if (start != null && d.isBefore(start)) return false;
        if (end != null && d.isAfter(end)) return false;
      }
      if (e.headId != null && e.headId!.isNotEmpty && i.head?.toString() != e.headId) {
        return false;
      }
      if (e.accountId != null &&
          e.accountId!.isNotEmpty &&
          i.account?.toString() != e.accountId) {
        return false;
      }
      if (q.isNotEmpty) {
        final hay = [i.invoiceNumber, i.headName, i.accountName, i.note, i.amount]
            .whereType<String>()
            .join(' ')
            .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

// Helper for int parsing as in your original code
  int _safeParseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }


  String extractValidationMessage(dynamic response) {
    if (response is! Map) return 'Unknown error';

    String errorMessage =
        response['message']?.toString() ?? 'Validation Error';

    dynamic data = response['data'];
    if (data is Map && data.containsKey('data')) {
      data = data['data'];
    }

    if (data is Map) {
      for (final entry in data.entries) {
        final value = entry.value;

        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String) {
          return value;
        }
      }
    }
    return errorMessage;
  }

  Future<void> _onAddIncome(AddIncome event, Emitter<IncomeState> emit) async {
    emit(IncomeAddLoading());
    try {
      final res = await postResponse(
        url: AppUrls.income,
        payload: event.body,
      );
      final Map jsonMap = res as Map;

      if (jsonMap['status'] == false) {
        final errorMessage = extractValidationMessage(jsonMap);
        emit(
          IncomeAddFailed(
            title: 'Error',
            content: errorMessage,
          ),
        );
        return;
      }

      final ApiResponse<IncomeModel> _ = appParseJson(
        jsonEncode(jsonMap),
            (data) => IncomeModel.fromJson(data),
      );
      clearData();
      emit(IncomeAddSuccess());
    } catch (e, s) {
      clearData();
      debugPrintStack(stackTrace: s);
      emit(
        IncomeAddFailed(
          title: 'Error',
          content: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateIncome(UpdateIncome event, Emitter<IncomeState> emit) async {
    emit(IncomeAddLoading());
    try {
      final res = await patchResponse(
          url: '${AppUrls.income}${event.id}/',
          payload: event.body!);
      final jsonString = jsonEncode(res);

      ApiResponse<IncomeModel> response = appParseJson<IncomeModel>(
        jsonString,
            (data) => IncomeModel.fromJson(data),
      );

      if (response.success == false) {
        emit(IncomeAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to update income"
        ));
        return;
      }
      emit(IncomeAddSuccess());
    } catch (error) {
      emit(IncomeAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteIncome(DeleteIncome event, Emitter<IncomeState> emit) async {
    emit(IncomeDeleteLoading());
    try {
      final res = await deleteResponse(
          url: '${AppUrls.income}${event.id}/');
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );

      if (response.success == false) {
        emit(IncomeDeleteFailed(
            title: 'Error',
            content: response.message ?? "Failed to delete income"
        ));
        return;
      }

      emit(IncomeDeleteSuccess());
    } catch (error) {
      emit(IncomeDeleteFailed(title: "Error", content: error.toString()));
    }
  }
}