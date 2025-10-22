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
  ExpenseHeadModel? selectedExpenseHead;
  String selectedAccount = "";
  String selectedAccountId = "";

  ExpenseBloc() : super(ExpenseInitial()) {
    on<FetchExpenseList>(_onFetchExpenseList);
    on<AddExpense>(_onCreateExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  void clearData() {
    amountTextController.clear();
    noteTextController.clear();
    filterTextController.clear();
    dateExpenseTextController.clear();
    selectedPayment = "";
    selectedExpenseHead = null;
    selectedAccount = "";
    selectedAccountId = "";
  }

  Future<void> _onFetchExpenseList(
      FetchExpenseList event, Emitter<ExpenseState> emit) async {
    emit(ExpenseListLoading());

    try {
      final res = await getResponse(url: AppUrls.expense, context: event.context);

      ApiResponse<List<ExpenseModel>> response = appParseJson<List<ExpenseModel>>(
        res,
            (data) => List<ExpenseModel>.from(data.map((x) => ExpenseModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(ExpenseListSuccess(
          list: [],
          totalPages: 0,
          currentPage: event.pageNumber,
        ));
        return;
      }

      // Store all expenses for filtering and pagination
      allWarehouses = data;

      // Apply filtering and pagination
      final filteredExpenses = _filterData(
          allWarehouses, event.filterText, event.startDate, event.endDate);
      final paginatedExpenses = _paginatePage(filteredExpenses, event.pageNumber);

      final totalPages = (filteredExpenses.length / _itemsPerPage).ceil();

      emit(ExpenseListSuccess(
        list: paginatedExpenses,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(ExpenseListFailed(title: "Error", content: error.toString()));
    }
  }

  List<ExpenseModel> _filterData(List<ExpenseModel> expenses,
      String filterText, DateTime? startDate, DateTime? endDate) {
    return expenses.where((expense) {
      // Check if the expense's expenseDate is not null and falls within the given date range
      final matchesDate = (startDate == null || endDate == null) ||
          (expense.expenseDate != null &&
              ((expense.expenseDate!.isAfter(startDate) &&
                  expense.expenseDate!.isBefore(endDate)) ||
                  expense.expenseDate!.isAtSameMomentAs(startDate) ||
                  expense.expenseDate!.isAtSameMomentAs(endDate)));

      // Check if the expense matches the filter text
      final matchesText = filterText.isEmpty ||
          (expense.headName?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
          (expense.description?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
          (expense.paymentMethod?.toLowerCase().contains(filterText.toLowerCase()) ?? false);

      // Return true only if both conditions match
      return matchesDate && matchesText;
    }).toList();
  }

  List<ExpenseModel> _paginatePage(List<ExpenseModel> expenses, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= expenses.length) return [];
    return expenses.sublist(
        start, end > expenses.length ? expenses.length : end);
  }

  Future<void> _onCreateExpense(
      AddExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseAddLoading());

    try {
      print('Creating expense with body: ${event.body}'); // Debug log

      final res = await postResponse(
          url: AppUrls.expense, payload: event.body);

      // FIX: Parse as single object, not list
      ApiResponse<ExpenseModel> response = appParseJson<ExpenseModel>(
        res,
            (data) => ExpenseModel.fromJson(data), // Single object, not list
      );

      if (response.success == false) {
        emit(ExpenseAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to create expense"
        ));
        return;
      }

      clearData();
      emit(ExpenseAddSuccess());
    } catch (error) {
      clearData();
      emit(ExpenseAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseAddLoading());

    try {
      final res = await patchResponse(
          url: '${AppUrls.expense}${event.id}/', // Add trailing slash
          payload: event.body!);

      // FIX: Parse as single object, not list
      ApiResponse<ExpenseModel> response = appParseJson<ExpenseModel>(
        res,
            (data) => ExpenseModel.fromJson(data), // Single object, not list
      );

      if (response.success == false) {
        emit(ExpenseAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to update expense"
        ));
        return;
      }

      emit(ExpenseAddSuccess());
    } catch (error) {
      emit(ExpenseAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseAddLoading());

    try {
      final res = await deleteResponse(
          url: '${AppUrls.expense}${event.id}/'); // Add trailing slash

      // FIX: For delete, we don't need to parse as ExpenseModel
      ApiResponse<dynamic> response = appParseJson<dynamic>(
        res,
            (data) => data, // Just return the data as-is
      );

      if (response.success == false) {
        emit(ExpenseAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to delete expense"
        ));
        return;
      }

      emit(ExpenseAddSuccess());
    } catch (error) {
      emit(ExpenseAddFailed(title: "Error", content: error.toString()));
    }
  }
}