
import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/expense_head_model.dart';

part 'expense_head_event.dart';
part 'expense_head_state.dart';

class ExpenseHeadBloc extends Bloc<ExpenseHeadEvent, ExpenseHeadState> {
  List<ExpenseHeadModel> list = [];
  final int _itemsPerPage = 15;
  String selectedState = "";
  TextEditingController filterTextController = TextEditingController();
  TextEditingController name = TextEditingController();
  List<String> statesList = ["Active", "Inactive"];

  ExpenseHeadBloc() : super(ExpenseHeadInitial()) {
    on<FetchExpenseHeadList>(_onFetchExpenseHeadList);
    on<AddExpenseHead>(_onCreateExpenseHead);
    on<UpdateExpenseHead>(_onUpdateExpenseHead);
    on<DeleteExpenseHead>(_onDeleteExpenseHead);
  }

  // ---------------------------------------------------------------------------
  // FETCH LIST
  // ---------------------------------------------------------------------------
  Future<void> _onFetchExpenseHeadList(
      FetchExpenseHeadList event, Emitter<ExpenseHeadState> emit) async {
    emit(ExpenseHeadListLoading());

    try {
      final res = await getResponse(url: AppUrls.expenseHead, context: event.context);

      ApiResponse<List<ExpenseHeadModel>> response =
      appParseJson<List<ExpenseHeadModel>>(
        res,
            (data) => List<ExpenseHeadModel>.from(
          data.map((x) => ExpenseHeadModel.fromJson(x)),
        ),
      );

      final data = response.data ?? [];

      list = data;
      final filtered = _filterExpenseHead(list, event.filterText);
      final paginated = _paginatePage(filtered, event.pageNumber);
      final totalPages = (filtered.length / _itemsPerPage).ceil();

      emit(ExpenseHeadListSuccess(
        list: paginated,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(ExpenseHeadListFailed(title: "Error", content: error.toString()));
    }
  }

  List<ExpenseHeadModel> _filterExpenseHead(List<ExpenseHeadModel> list, String filterText) {
    return list.where((item) {
      final matchesText =
          filterText.isEmpty || item.name!.toLowerCase().contains(filterText.toLowerCase());
      return matchesText;
    }).toList();
  }

  List<ExpenseHeadModel> _paginatePage(List<ExpenseHeadModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }

  // ---------------------------------------------------------------------------
  // CREATE EXPENSE HEAD
  // ---------------------------------------------------------------------------
  Future<void> _onCreateExpenseHead(
      AddExpenseHead event, Emitter<ExpenseHeadState> emit) async {
    emit(ExpenseHeadAddLoading());

    try {
      final res = await postResponse(url: AppUrls.expenseHead, payload: event.body);
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => ExpenseHeadModel.fromJson(data),
      );



      if (response.success == false) {
        emit(ExpenseHeadAddFailed(title: '', content: response.message ?? ""));
        return;
      }name.clear();

      emit(ExpenseHeadAddSuccess());
    } catch (error) {
      emit(ExpenseHeadAddFailed(title: "Error", content: error.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE EXPENSE HEAD
  // ---------------------------------------------------------------------------
  Future<void> _onUpdateExpenseHead(
      UpdateExpenseHead event, Emitter<ExpenseHeadState> emit) async {
    emit(ExpenseHeadAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.expenseHead + event.id.toString()}/",
        payload: event.body!,
      );
      final jsonString = jsonEncode(res);

      ApiResponse<ExpenseHeadModel> response = appParseJson(
        jsonString,
            (data) => ExpenseHeadModel.fromJson(data),
      );

      if (response.success == false) {
        emit(ExpenseHeadAddFailed(title: '', content: response.message ?? ""));
        return;
      }

      emit(ExpenseHeadAddSuccess());
    } catch (error) {
      emit(ExpenseHeadAddFailed(title: "Error", content: error.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE EXPENSE HEAD
  // ---------------------------------------------------------------------------
  Future<void> _onDeleteExpenseHead(
      DeleteExpenseHead event, Emitter<ExpenseHeadState> emit) async {
    emit(ExpenseHeadAddLoading());

    try {
      final res = await deleteResponse(url: "${AppUrls.expenseHead + event.id.toString()}/");

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString, // Now passing String instead of Map
            (data) => data, // Just return data as-is for delete operations
      );

      if (response.success == false) {

        emit(ExpenseHeadAddFailed(title: '', content: response.message ?? ""));
        return;
      }

      emit(ExpenseHeadAddSuccess());
      // add(FetchExpenseHeadList( ));

    } catch (error) {
      emit(ExpenseHeadAddFailed(title: "Error", content: error.toString()));
    }
  }
}
