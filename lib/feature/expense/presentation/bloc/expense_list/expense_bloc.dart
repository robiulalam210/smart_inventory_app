
import 'package:smart_inventory/feature/expense/data/model/expense.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/patch_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../expense_head/data/model/expense_head_model.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  List<ExpenseModel> allWarehouses = [];
  final int _itemsPerPage = 5;
  String selectedState = "";
  TextEditingController filterTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();
  TextEditingController noteTextController = TextEditingController();
  TextEditingController dateExpenseTextController = TextEditingController();

  List<String> paymentMethod = ["Bank", "Cash", "Mobile banking"];
  String selectedPayment = "";

  // String selectedWarehouseId = "";

  ExpenseHeadModel? selectedExpenseHead;

  // String selectedExpenseHeadId = "";

  String selectedAccount = "";
  String selectedAccountId = "";

  ExpenseBloc() : super(ExpenseInitial()) {
    on<FetchExpenseList>(_onFetchWarehouseList);
    on<AddExpense>(_onCreateWarehouseList);
    on<UpdateExpense>(_onUpdateExpenseList);
    on<DeleteExpense>(_onDeleteExpenseList);
  }

  clearData() {
    amountTextController.clear();
    noteTextController.clear();
    filterTextController.clear();
    dateExpenseTextController.clear();

    selectedPayment = "";

    selectedExpenseHead = null;

    selectedAccount = "";
    selectedAccountId = "";
  }

  Future<void> _onFetchWarehouseList(
      FetchExpenseList event, Emitter<ExpenseState> emit) async {
    emit(ExpenseListLoading());

    try {
      final res =
          await getResponse(url: AppUrls.expense, context: event.context); // Use the correct API URL

      ApiResponse<List<ExpenseModel>> response =
          appParseJson<List<ExpenseModel>>(
        res,
        (data) => List<ExpenseModel>.from(
            data.map((x) => ExpenseModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(ExpenseListFailed(title: "Error", content: "No Data"));

        return;
      }
      // Store all warehouses for filtering and pagination
      allWarehouses = data;

      // Apply filtering and pagination
      final filteredWarehouses = _filterData(
          allWarehouses, event.filterText, event.startDate, event.endDate);
      final paginatedWarehouses =
          __paginatePage(filteredWarehouses, event.pageNumber);

      final totalPages = (filteredWarehouses.length / _itemsPerPage).ceil();

      emit(ExpenseListSuccess(
        list: paginatedWarehouses,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(ExpenseListFailed(title: "Error", content: error.toString()));
    }
  }

  List<ExpenseModel> _filterData(List<ExpenseModel> warehouses,
      String filterText, DateTime? startDate, DateTime? endDate) {
    return warehouses.where((warehouse) {
      // Check if the warehouse's paymentDate is not null and falls within the given date range
      final matchesDate = (startDate == null || endDate == null) ||
          (warehouse.expenseDate != null &&
              ((warehouse.expenseDate!.isAfter(startDate) &&
                      warehouse.expenseDate!.isBefore(endDate)) ||
                  warehouse.expenseDate!.isAtSameMomentAs(startDate) ||
                  warehouse.expenseDate!.isAtSameMomentAs(endDate)));

      // Check if the warehouse's mrNo matches the given state (case-insensitive)
      final matchesState = filterText.isEmpty ||
          warehouse.head?.toString().toLowerCase() ==
              filterText.toLowerCase();

      // Return true only if both conditions match
      return matchesDate && matchesState;
    }).toList();
  }

  List<ExpenseModel> __paginatePage(
      List<ExpenseModel> warehouses, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= warehouses.length) return [];
    return warehouses.sublist(
        start, end > warehouses.length ? warehouses.length : end);
  }

  Future<void> _onCreateWarehouseList(
      AddExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseAddLoading());

    try {
      final res = await postResponse(
          url: AppUrls.expense, payload: event.body); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) => List<ExpenseModel>.from(
            data.map((x) => ExpenseModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(ExpenseAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(ExpenseAddSuccess());
    } catch (error) {
      clearData();
      emit(ExpenseAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateExpenseList(
      UpdateExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseAddLoading());

    try {
      final res = await patchResponse(
          url: AppUrls.expense + event.id.toString(),
          payload: event.body!); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) => List<ExpenseModel>.from(
            data.map((x) => ExpenseModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(ExpenseAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      // clearData();
      emit(ExpenseAddSuccess());
    } catch (error) {
      // clearData();
      emit(ExpenseAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteExpenseList(
      DeleteExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseAddLoading());

    try {
      final res = await deleteResponse(
          url:
              AppUrls.expense + event.id.toString()); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) => List<ExpenseModel>.from(
            data.map((x) => ExpenseModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(ExpenseAddFailed(title: 'Json', content: response.message ?? ""));
        return;
      }
      emit(ExpenseAddSuccess());
    } catch (error) {
      emit(ExpenseAddFailed(title: "Error", content: error.toString()));
    }
  }
}
