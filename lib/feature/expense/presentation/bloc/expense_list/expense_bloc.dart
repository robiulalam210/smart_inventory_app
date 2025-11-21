import 'package:meherin_mart/feature/expense/data/model/expense.dart';
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
      if (event.startDate != null) {
        queryParams['start_date'] = event.startDate!.toIso8601String().split('T')[0];
      }
      if (event.endDate != null) {
        queryParams['end_date'] = event.endDate!.toIso8601String().split('T')[0];
      }
      // Add head and subhead filters
      if (event.headId != null && event.headId!.isNotEmpty) {
        queryParams['head_id'] = event.headId!;
      }
      if (event.subHeadId != null && event.subHeadId!.isNotEmpty) {
        queryParams['subhead_id'] = event.subHeadId!;
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

      if (response.success == false || response.data == null) {
        emit(ExpenseListFailed(
            title: "Error",
            content: response.message ?? "Failed to fetch expenses"
        ));
        return;
      }

      final responseData = response.data!;

      // Debug: Print the full response structure

      // Extract data from response - handle different response structures
      final data = responseData['data'] ?? responseData;
      final pagination = data['pagination'] ?? {};
      final results = data['results'] ?? data['data'] ?? [];

      // Extract with safe parsing
      final count = _safeParseInt(pagination['count'] ?? data['count'], 0);
      final currentPage = _safeParseInt(pagination['current_page'] ?? data['current_page'], event.pageNumber);
      final pageSize = _safeParseInt(pagination['page_size'] ?? data['page_size'], event.pageSize);
      final totalPages = _safeParseInt(pagination['total_pages'] ?? data['total_pages'], (count / pageSize).ceil());

      // Calculate from and to
      final from = ((currentPage - 1) * pageSize) + 1;
      final to = from + (results.isNotEmpty ? results.length - 1 : 0);

      // Parse expense list
      List<ExpenseModel> expenses = [];
      if (results is List) {
        expenses = List<ExpenseModel>.from(
            results.map((x) => ExpenseModel.fromJson(Map<String, dynamic>.from(x)))
        );
      }


      emit(ExpenseListSuccess(
        list: expenses,
        totalPages: totalPages,
        currentPage: currentPage,
        count: count,
        pageSize: pageSize,
        from: from,
        to: to.toInt(),
      ));
    } catch (error) {

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
      // Debug log

      final res = await postResponse(
          url: AppUrls.expense, payload: event.body);


      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => ExpenseModel.fromJson(data),
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
      final jsonString = jsonEncode(res);

      // FIX: Parse as single object, not list
      ApiResponse<ExpenseModel> response = appParseJson<ExpenseModel>(
        jsonString,
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
    emit(ExpenseDeleteLoading());

    try {
      final res = await deleteResponse(
          url: '${AppUrls.expense}${event.id}/'); // Add trailing slash

      // ✅ Convert the Map to JSON string for appParseJson
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString, // Now passing String instead of Map
            (data) => data, // Just return data as-is for delete operations
      );

      if (response.success == false) {
        emit(ExpenseDeleteFailed(
            title: 'Error',
            content: response.message ?? "Failed to delete expense"
        ));
        return;
      }

      emit(ExpenseDeleteSuccess() );
    } catch (error) {
      emit(ExpenseDeleteFailed(title: "Error", content: error.toString()));
    }
  }
}