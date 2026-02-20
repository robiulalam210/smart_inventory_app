
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/patch_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../data/model/income_head_model.dart';

part 'income_expense_head_event.dart';
part 'income_expense_head_state.dart';



class IncomeHeadBloc extends Bloc<IncomeHeadEvent, IncomeHeadState> {
  List<IncomeHeadModel> list = [];

  final int _itemsPerPage = 15;
  String selectedState = "";
  TextEditingController filterTextController = TextEditingController();
  TextEditingController name = TextEditingController();
  List<String> statesList = ["Active", "Inactive"];
  IncomeHeadBloc() : super(IncomeHeadInitial()) {
    on<FetchIncomeHeadList>(_onFetchIncomeHeadList);
    on<AddIncomeHead>(_onCreateIncomeHead);
    on<UpdateIncomeHead>(_onUpdateIncomeHead);
    on<DeleteIncomeHead>(_onDeleteIncomeHead);
  }

  // ---------------------------------------------------------------------------
  // FETCH LIST
  // ---------------------------------------------------------------------------
  Future<void> _onFetchIncomeHeadList(
      FetchIncomeHeadList event, Emitter<IncomeHeadState> emit) async {
    emit(IncomeHeadListLoading());

    try {
      final res = await getResponse(url: AppUrls.incomeHead, context: event.context);

      ApiResponse<List<IncomeHeadModel>> response =
      appParseJson<List<IncomeHeadModel>>(
        res,
            (data) => List<IncomeHeadModel>.from(
          data.map((x) => IncomeHeadModel.fromJson(x)),
        ),
      );

      final data = response.data ?? [];

      list = data;
      final filtered = _filterIncomeHead(list, event.filterText);
      final paginated = _paginatePage(filtered, event.pageNumber);
      final totalPages = (filtered.length / _itemsPerPage).ceil();

      emit(IncomeHeadListSuccess(
        list: paginated,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(IncomeHeadListFailed(title: "Error", content: error.toString()));
    }
  }

  List<IncomeHeadModel> _filterIncomeHead(List<IncomeHeadModel> list, String filterText) {
    return list.where((item) {
      final matchesText =
          filterText.isEmpty || item.name!.toLowerCase().contains(filterText.toLowerCase());
      return matchesText;
    }).toList();
  }

  List<IncomeHeadModel> _paginatePage(List<IncomeHeadModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }

  // ---------------------------------------------------------------------------
  // CREATE INCOME HEAD
  // ---------------------------------------------------------------------------
  Future<void> _onCreateIncomeHead(
      AddIncomeHead event, Emitter<IncomeHeadState> emit) async {
    emit(IncomeHeadAddLoading());

    try {
      final res = await postResponse(url: AppUrls.incomeHead, payload: event.body);
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => IncomeHeadModel.fromJson(data),
      );

      if (response.success == false) {
        emit(IncomeHeadAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      name.clear();
      emit(IncomeHeadAddSuccess());
    } catch (error) {
      emit(IncomeHeadAddFailed(title: "Error", content: error.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE INCOME HEAD
  // ---------------------------------------------------------------------------
  Future<void> _onUpdateIncomeHead(
      UpdateIncomeHead event, Emitter<IncomeHeadState> emit) async {
    emit(IncomeHeadAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.incomeHead + event.id.toString()}/",
        payload: event.body!,
      );
      final jsonString = jsonEncode(res);

      ApiResponse<IncomeHeadModel> response = appParseJson(
        jsonString,
            (data) => IncomeHeadModel.fromJson(data),
      );

      if (response.success == false) {
        emit(IncomeHeadAddFailed(title: '', content: response.message ?? ""));
        return;
      }

      emit(IncomeHeadAddSuccess());
    } catch (error) {
      emit(IncomeHeadAddFailed(title: "Error", content: error.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE INCOME HEAD
  // ---------------------------------------------------------------------------
  Future<void> _onDeleteIncomeHead(
      DeleteIncomeHead event, Emitter<IncomeHeadState> emit) async {
    emit(IncomeHeadAddLoading());

    try {
      final res = await deleteResponse(url: "${AppUrls.incomeHead + event.id.toString()}/");

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => data,
      );

      if (response.success == false) {
        emit(IncomeHeadAddFailed(title: '', content: response.message ?? ""));
        return;
      }

      emit(IncomeHeadAddSuccess());
      // add(FetchIncomeHeadList());
    } catch (error) {
      emit(IncomeHeadAddFailed(title: "Error", content: error.toString()));
    }
  }
}