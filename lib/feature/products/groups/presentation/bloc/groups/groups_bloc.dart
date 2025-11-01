import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/groups.dart';

part 'groups_event.dart';

part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  List<GroupsModel> list = [];
  final int _itemsPerPage = 10;
  String selectedState = "";
  GroupsModel? selectedGroups;

  TextEditingController filterTextController = TextEditingController();
  List<String> statesList = ["Active", "Inactive"];

  TextEditingController nameController = TextEditingController();
  TextEditingController shortNameController = TextEditingController();

  GroupsBloc() : super(GroupsInitial()) {
    on<FetchGroupsList>(_onFetchWarehouseList);
    on<AddGroups>(_onCreateWarehouseList);
    on<UpdateGroups>(_onUpdateGroupsList);
    on<UpdateSwitchGroups>(_onUpdateSwitchGroupsList);
    on<DeleteGroups>(_onDeleteBrandList);
  }

  Future<void> _onFetchWarehouseList(
    FetchGroupsList event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.group,
        context: event.context,
      ); // Use the correct API URL

      ApiResponse<List<GroupsModel>> response = appParseJson<List<GroupsModel>>(
        res,
        (data) =>
            List<GroupsModel>.from(data.map((x) => GroupsModel.fromJson(x))),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        emit(
          GroupsListSuccess(
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
      final filteredWarehouses = _filterData(list, event.filterText);
      final paginatedWarehouses = __paginatePage(
        filteredWarehouses,
        event.pageNumber,
      );

      final totalPages = (filteredWarehouses.length / _itemsPerPage).ceil();

      emit(
        GroupsListSuccess(
          list: paginatedWarehouses,
          totalPages: totalPages,
          currentPage: event.pageNumber,
        ),
      );
    } catch (error) {
      emit(GroupsListFailed(title: "Error", content: error.toString()));
    }
  }

  List<GroupsModel> _filterData(
    List<GroupsModel> warehouses,
    String filterText,
  ) {
    return warehouses.where((warehouse) {
      final matchesText =
          filterText.isEmpty ||
          warehouse.name!.toLowerCase().contains(filterText.toLowerCase());
      return matchesText;
    }).toList();
  }

  List<GroupsModel> __paginatePage(
    List<GroupsModel> warehouses,
    int pageNumber,
  ) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= warehouses.length) return [];
    return warehouses.sublist(
      start,
      end > warehouses.length ? warehouses.length : end,
    );
  }

  Future<void> _onCreateWarehouseList(
    AddGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsAddLoading());

    try {
      final res = await postResponse(
        url: AppUrls.group,
        payload: event.body,
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => GroupsModel.fromJson(data),
      );


      if (response.success == false) {
        emit(GroupsAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(GroupsAddSuccess());
    } catch (error) {
      clearData();
      emit(GroupsAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateGroupsList(
    UpdateGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.group + event.id.toString()}/",
        payload: event.body!,
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
        (data) =>
            List<GroupsModel>.from(data.map((x) => GroupsModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(GroupsAddFailed(title: 'Json', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(GroupsAddSuccess());
    } catch (error) {
      clearData();
      emit(GroupsAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateSwitchGroupsList(
    UpdateSwitchGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsSwitchLoading());

    try {
      final res = await patchResponse(
        url: AppUrls.group + event.id.toString(),
        payload: event.body!,
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
        (data) =>
            List<GroupsModel>.from(data.map((x) => GroupsModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(GroupSwitchFailed(title: 'Json', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(GroupsSwitchSuccess());
    } catch (error) {
      clearData();
      emit(GroupSwitchFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteBrandList(
      DeleteGroups event, Emitter<GroupsState> emit) async {

    emit(GroupsAddLoading());

    try {
      final res  = await deleteResponse(url: "${AppUrls.group+event.id.toString()}/"); // Use the correct API URL

      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => List<GroupsModel>.from(data.map((x) => GroupsModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(GroupsAddFailed(title: 'Json', content: response.message??""));
        return;
      }
      clearData();
      emit(GroupsAddSuccess(

      ));
    } catch (error,stack) {
      print(stack);
      clearData();
      emit(GroupsAddFailed(title: "Error",content: error.toString()));

    }
  }

  clearData() {
    nameController.clear();
    shortNameController.clear();
  }
}
