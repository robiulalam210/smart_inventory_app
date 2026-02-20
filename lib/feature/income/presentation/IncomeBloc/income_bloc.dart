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
      print("RAW API RESPONSE: $res");

      // Use dynamic to support both Map and List response types!
      final ApiResponse<dynamic> response = appParseJson<dynamic>(
        res,
            (data) => data,
      );

      print("DECODED RESPONSE STATUS: ${response.success}");
      print("DECODED RESPONSE MESSAGE: ${response.message}");
      print("DECODED RESPONSE DATA: ${response.data}");

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
      print("PARSED RESULTS: $results");
      print("PARSED PAGINATION: $pagination");

      // Parse out page stuff safely if available
      int count = _safeParseInt(pagination['count'], 0);
      int currentPage = _safeParseInt(pagination['current_page'], event.pageNumber);
      int pageSize = _safeParseInt(pagination['page_size'], event.pageSize);
      int totalPages = _safeParseInt(pagination['total_pages'], (count / (pageSize != 0 ? pageSize : 1)).ceil());
      final from = ((currentPage - 1) * pageSize) + 1;
      final to = from + (results.isNotEmpty ? results.length - 1 : 0);

      List<IncomeModel> incomes = [];
      if (results is List) {
        incomes = results.where((x) => x is Map)
            .map((x) => IncomeModel.fromJson(Map<String, dynamic>.from(x)))
            .toList();
      }

      emit(IncomeListSuccess(
        list: incomes,
        totalPages: totalPages,
        currentPage: currentPage,
        count: count,
        pageSize: pageSize,
        from: from,
        to: to.toInt(),
      ));
    } catch (error) {
      emit(IncomeListFailed(title: "Error", content: error.toString()));
    }
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