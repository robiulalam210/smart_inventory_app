import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/expense_sub_head_model.dart';

part 'expense_sub_head_event.dart';
part 'expense_sub_head_state.dart';

class ExpenseSubHeadBloc extends Bloc<ExpenseSubHeadEvent, ExpenseSubHeadState> {

  List<ExpenseSubHeadModel> list = [];
  final int _itemsPerPage = 15;
  String selectedState = "";
  TextEditingController filterTextController = TextEditingController();
  TextEditingController name = TextEditingController();
  List<String> statesList = ["Active", "Inactive"];

  ExpenseSubHeadBloc() : super(ExpenseSubHeadInitial()) {
    on<FetchSubExpenseHeadList>(_onFetchExpenseHeadList);
    on<AddSubExpenseHead>(_onCreateExpenseHead);
    on<UpdateSubExpenseHead>(_onUpdateExpenseHead);
    on<DeleteSubExpenseHead>(_onDeleteExpenseHeadScreen);
  }

  Future<void> _onFetchExpenseHeadList(
      FetchSubExpenseHeadList event, Emitter<ExpenseSubHeadState> emit) async {
    emit(ExpenseSubHeadListLoading());

    try {
      final res = await getResponse(
          url: AppUrls.expenseSubHead, context: event.context);

      ApiResponse<List<ExpenseSubHeadModel>> response =
      appParseJson<List<ExpenseSubHeadModel>>(
        res,
            (data) => List<ExpenseSubHeadModel>.from(
            data.map((x) => ExpenseSubHeadModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(ExpenseSubHeadListSuccess(
          list: [],
          totalPages: 0,
          currentPage: event.pageNumber,
        ));
        return;
      }

      // Store all warehouses for filtering and pagination
      list = data;

      // Apply filtering and pagination
      final filteredWarehouses =
      _filterExpenseHead(list, event.filterText);
      final paginatedWarehouses =
      _paginatePage(filteredWarehouses, event.pageNumber);

      final totalPages = (filteredWarehouses.length / _itemsPerPage).ceil();

      emit(ExpenseSubHeadListSuccess(
        list: paginatedWarehouses,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(ExpenseSubHeadListFailed(title: "Error", content: error.toString()));
    }
  }

  List<ExpenseSubHeadModel> _filterExpenseHead(
      List<ExpenseSubHeadModel> list, String filterText) {
    return list.where((warehouse) {
      final matchesText = filterText.isEmpty ||
          warehouse.name!
              .toLowerCase()
              .contains(filterText.toLowerCase());
      return matchesText;
    }).toList();
  }

  List<ExpenseSubHeadModel> _paginatePage(
      List<ExpenseSubHeadModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(
        start, end > list.length ? list.length : end);
  }

  Future<void> _onCreateExpenseHead(
      AddSubExpenseHead event, Emitter<ExpenseSubHeadState> emit) async {
    emit(ExpenseSubHeadAddLoading());

    try {
      final res = await postResponse(
          url: AppUrls.expenseSubHead,
          payload: event.body
      );


      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => ExpenseSubHeadModel.fromJson(data),
      );


      if (response.success == false) {
        emit(ExpenseSubHeadAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to create expense sub head"
        ));
        return;
      }

      emit(ExpenseSubHeadAddSuccess());
    } catch (error) {
      emit(ExpenseSubHeadAddFailed(
          title: "Error",
          content: error.toString()
      ));
    }
  }

  Future<void> _onUpdateExpenseHead(
      UpdateSubExpenseHead event, Emitter<ExpenseSubHeadState> emit) async {
    emit(ExpenseSubHeadAddLoading());

    try {
      final res = await patchResponse(
          url: "${AppUrls.expenseSubHead + event.id.toString()}/",
          payload: event.body!
      );

      // FIX: Parse as single object instead of list
      ApiResponse<ExpenseSubHeadModel> response = appParseJson<ExpenseSubHeadModel>(
        res,
            (data) => ExpenseSubHeadModel.fromJson(data), // Single object, not list
      );

      if (response.success == false) {
        emit(ExpenseSubHeadAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to update expense sub head"
        ));
        return;
      }

      emit(ExpenseSubHeadAddSuccess());
    } catch (error) {
      emit(ExpenseSubHeadAddFailed(
          title: "Error",
          content: error.toString()
      ));
    }
  }

  Future<void> _onDeleteExpenseHeadScreen(
      DeleteSubExpenseHead event, Emitter<ExpenseSubHeadState> emit) async {
    emit(ExpenseSubHeadAddLoading());

    try {
      final res = await deleteResponse(
          url: "${AppUrls.expenseSubHead + event.id.toString()}/"
      );

      // FIX: For delete, we don't need to parse the response as ExpenseSubHeadModel
      // Just check if the operation was successful
      ApiResponse<dynamic> response = appParseJson<dynamic>(
        res,
            (data) => data, // Just return the data as-is
      );

      if (response.success == false) {
        emit(ExpenseSubHeadAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to delete expense sub head"
        ));
        return;
      }

      emit(ExpenseSubHeadAddSuccess());
    } catch (error) {
      emit(ExpenseSubHeadAddFailed(
          title: "Error",
          content: error.toString()
      ));
    }
  }

  // Helper method to clear form data
  void clearData() {
    name.clear();
    filterTextController.clear();
    selectedState = "";
  }
}