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
  List<ExpenseModel> allExpenses = [];
  final int _defaultPageSize = 10;
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
      // Build query parameters
      Map<String, String> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      // Add filters
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.startDate != null && event.endDate != null) {
        queryParams['start_date'] = event.startDate!.toIso8601String().split('T')[0];
        queryParams['end_date'] = event.endDate!.toIso8601String().split('T')[0];
      }

      final res = await getResponse(
        url: AppUrls.expense,
        context: event.context,
        queryParams: queryParams,
      );

      // Parse the response
      ApiResponse<Map<String, dynamic>> response = appParseJson<Map<String, dynamic>>(
        res,
            (data) => data,
      );

      if (response.success == false) {
        emit(ExpenseListFailed(
            title: "Error",
            content: response.message ?? "Failed to fetch expenses"
        ));
        return;
      }

      final responseData = response.data;


      if (responseData == null) {
        emit(ExpenseListSuccess(
          list: [],
          totalPages: 0,
          currentPage: event.pageNumber,
          count: 0,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }
      print('Full response data1: ${responseData}');

      // Extract data from the nested structure
      final data = responseData['results'];
      print('Full response data2: $data');

      if (data == null) {
        emit(ExpenseListSuccess(
          list: [],
          totalPages: 0,
          currentPage: event.pageNumber,
          count: 0,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }

      // Debug: Print the actual response structure
      print('Full response data: $data');

      // Extract with safe parsing
      final results = data ?? [];
      final count = _safeParseInt(responseData['count'], 0);
      final currentPage = _safeParseInt(responseData['current_page'], event.pageNumber);
      final pageSize = _safeParseInt(responseData['page_size'], event.pageSize);
      final totalPages = _safeParseInt(responseData['total_pages'], (count / pageSize).ceil());

      // Calculate from and to
      final from = ((currentPage - 1) * pageSize) + 1;
      final to = from + (results.isNotEmpty ? results.length - 1 : 0);

      // Parse expense list
      List<ExpenseModel> expenses = [];
      if (results is List) {
        expenses = List<ExpenseModel>.from(
            results.map((x) => ExpenseModel.fromJson(x))
        );
      }

      // Debug: Print what we're emitting
      print('Emitting ExpenseListSuccess with:');
      print('  - count: $count');
      print('  - currentPage: $currentPage');
      print('  - pageSize: $pageSize');
      print('  - totalPages: $totalPages');
      print('  - from: $from');
      print('  - to: $to');
      print('  - expenses count: ${expenses.length}');

      emit(ExpenseListSuccess(
        list: expenses,
        totalPages: totalPages,
        currentPage: currentPage,
        count: count,
        pageSize: pageSize,
        from: from,
        to: to.toInt(),
      ));
    } catch (error,st) {
      print('Error in _onFetchExpenseList: $st');
      emit(ExpenseListFailed(title: "Error", content: error.toString()));
    }
  }

// Safe parsing helper
  int _safeParseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
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