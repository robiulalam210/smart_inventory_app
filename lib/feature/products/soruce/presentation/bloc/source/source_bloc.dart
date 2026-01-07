



import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/source_model.dart';

part 'source_event.dart';
part 'source_state.dart';

class SourceBloc extends Bloc<SourceEvent, SourceState> {

  String selectedId = "";
  String selectedIdState = "";

  List<SourceModel> list = [];
  final int _itemsPerPage = 15;
  String selectedState = "";
  TextEditingController filterTextController = TextEditingController();


  TextEditingController nameController = TextEditingController();


  SourceBloc() : super(SourceInitial()) {
    on<FetchSourceList >(_onFetchSourceList);
    on<AddSource>(_onCreateSourceList);
    on<UpdateSource>(_onUpdateSourceList);
    on<DeleteSource>(_onDeleteSourceList);
  }



  Future<void> _onFetchSourceList(
      FetchSourceList event, Emitter<SourceState> emit) async {

    emit(SourceListLoading());

    try {
      final res  = await getResponse(url: AppUrls.source, context: event.context); // Use the correct API URL


      ApiResponse<List<SourceModel>> response = appParseJson<List<SourceModel>>(
        res,
            (data) => List<SourceModel>.from(data.map((x) => SourceModel.fromJson(x))),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        emit(SourceListSuccess(
          list: const [],
          totalPages: 0,
          currentPage: event.pageNumber,
        ));
        return;
      }
      // Store all warehouses for filtering and pagination
      list = data;

      // Apply filtering and pagination
      final filteredData = _filterSource(list, event.filterText);
      final paginatedData = _paginateSource(filteredData, event.pageNumber);

      final totalPages = (filteredData.length / _itemsPerPage).ceil();

      emit(SourceListSuccess(
        list: paginatedData,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(SourceListFailed(title: "Error",content: error.toString()));
    }
  }

  List<SourceModel> _filterSource(
      List<SourceModel> list, String filterText) {
    return list.where((warehouse) {
      final matchesText = filterText.isEmpty || warehouse.name!.toLowerCase().contains(filterText.toLowerCase());
      return  matchesText;
    }).toList();
  }

  List<SourceModel> _paginateSource(List<SourceModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }


  Future<void> _onCreateSourceList(
      AddSource event, Emitter<SourceState> emit) async {

    emit(SourceAddLoading());

    try {
      final res  = await postResponse(url: AppUrls.source,payload: event.body); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => SourceModel.fromJson(data),
      );


      if (response.success == false) {
        emit(SourceAddFailed(title: '', content: response.message??""));
        return;
      }
      clearData();
      emit(SourceAddSuccess(

      ));
    } catch (error) {
      clearData();
      emit(SourceAddFailed(title: "Error",content: error.toString()));

    }
  }

  Future<void> _onUpdateSourceList(
      UpdateSource event, Emitter<SourceState> emit) async {
    emit(SourceUpdateLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.source}${event.id.toString()}/",
        payload: event.body!,
      );

      final jsonString = jsonEncode(res);

      // For single object response
      ApiResponse response = appParseJson(
        jsonString,
            (data) => SourceModel.fromJson(data), // Single object, not list
      );

      if (response.success == false) {
        emit(SourceUpdateFailed(
            title: 'Update Failed',
            content: response.message ?? "Failed to update source"
        ));
        return;
      }

      final updatedSource = response.data as SourceModel;

      // Update the local list
      final updatedList = list.map((source) {
        if (source.id.toString() == event.id) {
          return updatedSource;
        }
        return source;
      }).toList();

      list = updatedList;

      emit(SourceUpdateSuccess(

      ));

    } catch (error) {
      emit(SourceUpdateFailed(
          title: "Error",
          content: "Failed to update source: ${error.toString()}"
      ));
    }
  }


  Future<void> _onDeleteSourceList(
      DeleteSource event, Emitter<SourceState> emit) async {

    emit(SourceDeleteLoading());

    try {
      final res  = await deleteResponse(url: "${AppUrls.source+event.id.toString()}/"); // Use the correct API URL

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString, // Now passing String instead of Map
            (data) => data, // Just return data as-is for delete operations
      );
      if (response.success == false) {
        emit(SourceDeleteFailed(title: 'Json', content: response.message??""));
        return;
      }
      clearData();
      emit(SourceDeleteSuccess(
        response.message??""

      ));
    } catch (error) {
      clearData();
      emit(SourceDeleteFailed(title: "Error",content: error.toString()));

    }
  }

  void clearData(){
    nameController.clear();
  }

}



