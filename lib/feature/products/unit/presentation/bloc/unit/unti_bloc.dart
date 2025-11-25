import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/unit_model.dart';

part 'unti_event.dart';

part 'unti_state.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  List<UnitsModel> list = [];
  final int _itemsPerPage = 15;
  String selectedState = "";
  String selectedIdState = "";
  TextEditingController filterTextController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController shortNameController = TextEditingController();

  UnitBloc() : super(UnitInitial()) {
    on<FetchUnitList>(_onFetchUnitList);
    on<AddUnit>(_onCreateUnitList);
    on<UpdateUnit>(_onUpdateUnitList);
    on<DeleteUnit>(_onDeleteUnitList);
  }

  Future<void> _onFetchUnitList(
    FetchUnitList event,
    Emitter<UnitState> emit,
  ) async {
    emit(UnitListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.unit,
        context: event.context,
      ); // Use the correct API URL

      ApiResponse<List<UnitsModel>> response = appParseJson<List<UnitsModel>>(
        res,
        (data) =>
            List<UnitsModel>.from(data.map((x) => UnitsModel.fromJson(x))),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        emit(
          UnitListSuccess(
            list: [],
            totalPages: 0,
            currentPage: event.pageNumber,
          ),
        );
        return;
      }
      // Store all warehouses for filtering and pagination
      list = data;

      // Apply filtering and pagination
      final filteredWarehouses = _filterUnit(list, event.filterText);
      final paginatedWarehouses = _paginatePage(
        filteredWarehouses,
        event.pageNumber,
      );

      final totalPages = (filteredWarehouses.length / _itemsPerPage).ceil();

      emit(
        UnitListSuccess(
          list: paginatedWarehouses,
          totalPages: totalPages,
          currentPage: event.pageNumber,
        ),
      );
    } catch (error) {
      emit(UnitListFailed(title: "Error", content: error.toString()));
    }
  }

  List<UnitsModel> _filterUnit(List<UnitsModel> list, String filterText) {
    return list.where((warehouse) {
      final matchesText =
          filterText.isEmpty ||
          warehouse.name!.toLowerCase().contains(filterText.toLowerCase());
      return matchesText;
    }).toList();
  }

  List<UnitsModel> _paginatePage(List<UnitsModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }

  Future<void> _onCreateUnitList(AddUnit event, Emitter<UnitState> emit) async {
    emit(UnitAddLoading());

    try {
      final res = await postResponse(
        url: AppUrls.unit,
        payload: event.body,
      ); // Use the correct API URL

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
        (data) => UnitsModel.fromJson(data),
      );

      if (response.success == false) {
        emit(UnitAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(UnitAddSuccess());
    } catch (error) {
      clearData();
      emit(UnitAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateUnitList(
    UpdateUnit event,
    Emitter<UnitState> emit,
  ) async {
    emit(UnitUpdateLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.unit + event.id.toString()}/",
        payload: event.body!,
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
        (data) =>
            List<UnitsModel>.from(data.map((x) => UnitsModel.fromJson(x))),
      );
      if (response.data == false) {
        emit(
          UnitUpdateFailed(title: 'Update', content: response.message ?? ""),
        );
        return;
      }
      clearData();
      emit(UnitUpdateSuccess());
    } catch (error) {
      clearData();
      emit(UnitUpdateFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteUnitList(
    DeleteUnit event,
    Emitter<UnitState> emit,
  ) async {
    emit(UnitDeleteLoading());

    try {
      final res = await deleteResponse(
        url: "${AppUrls.unit + event.id.toString()}/",
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString, // Now passing String instead of Map
        (data) => data, // Just return data as-is for delete operations
      );
      if (response.success == false) {
        emit(UnitDeleteFailed(title: 'Json', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(UnitDeleteSuccess(response.message ?? ""));
    } catch (error) {
      clearData();
      emit(UnitDeleteFailed(title: "Error", content: error.toString()));
    }
  }

  void clearData() {
    nameController.clear();
    shortNameController.clear();
  }
}
