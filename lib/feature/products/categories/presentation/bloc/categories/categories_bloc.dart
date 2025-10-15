


import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/categories_model.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {



  List<CategoryModel> list = [];
  String selectedCategory = "";
  String selectedStateId = "";
  String selectedGroups = "";
  String selectedState = "";

  List<String> statesList = ["Active", "Inactive"];

  TextEditingController filterTextController = TextEditingController();


  TextEditingController nameController = TextEditingController();
  TextEditingController shortNameController = TextEditingController();

  CategoriesBloc() : super(CategoriesInitial()) {
    on<FetchCategoriesList >(_onFetchCategoriesList);
    on<AddCategories>(_onCreateCategoriesList);
    on<UpdateCategories>(_onUpdateCategoriesList);
    on<UpdateSwitchCategories>(_onUpdateSwitchCategoriesList);
    on<DeleteCategories>(_onDeleteCategoriesList);
  }

  Future<void> _onFetchCategoriesList(
      FetchCategoriesList event, Emitter<CategoriesState> emit) async {

    emit(CategoriesListLoading());

    try {
      final res  = await getResponse(url: AppUrls.category, context: event.context); // Use the correct API URL


      ApiResponse<List<CategoryModel>> response = appParseJson<List<CategoryModel>>(
        res,
            (data) => List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        emit(CategoriesListSuccess(
          list: [],
        ));

        return;
      }
      // Store all warehouses for filtering and pagination
      list = data;

      // Apply filtering and pagination
      final filteredData = _filterData(list, event.filterText,event.state);


      emit(CategoriesListSuccess(
        list: filteredData,
      ));
    } catch (error) {
      emit(CategoriesListFailed(title: "Error",content: error.toString()));
    }
  }

  List<CategoryModel> _filterData(
      List<CategoryModel> list, String filterText,status) {

    return list.where((data) {
      final matchesText = filterText.isEmpty || data.name!.toLowerCase().contains(filterText.toLowerCase());
      // final matchesStatus = status.isEmpty || data.status.toString() ==(status=="Active"?"1":"0");
      return  matchesText  ;
    }).toList();
  }



  Future<void> _onCreateCategoriesList(
      AddCategories event, Emitter<CategoriesState> emit) async {

    emit(CategoriesAddLoading());

    try {
      final res  = await postResponse(url: AppUrls.category,payload: event.body); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(CategoriesAddFailed(title: '', content: response.message??""));
        return;
      }
      clearData();
      emit(CategoriesAddSuccess(

      ));
    } catch (error) {
      clearData();
      emit(CategoriesAddFailed(title: "Error",content: error.toString()));

    }
  }

  Future<void> _onUpdateCategoriesList(
      UpdateCategories event, Emitter<CategoriesState> emit) async {

    emit(CategoriesAddLoading());

    try {
      final res  = await patchResponse(url: AppUrls.category+event.id.toString(),payload: event.body!); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(CategoriesAddFailed(title: 'Json', content: response.message??""));
        return;
      }
      clearData();
      emit(CategoriesAddSuccess(

      ));
    } catch (error) {
      clearData();
      emit(CategoriesAddFailed(title: "Error",content: error.toString()));

    }
  }


  Future<void> _onUpdateSwitchCategoriesList(
      UpdateSwitchCategories event, Emitter<CategoriesState> emit) async {

    emit(CategoriesSwitchLoading());

    try {
      final res  = await patchResponse(url: AppUrls.category+event.id.toString(),payload: event.body!); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(CategoriesSwitchFailed(title: 'Json', content: response.message??""));
        return;
      }
      clearData();
      emit(CategoriesSwitchSuccess(

      ));
    } catch (error) {
      clearData();
      emit(CategoriesSwitchFailed(title: "Error",content: error.toString()));

    }
  }

  Future<void> _onDeleteCategoriesList(
      DeleteCategories event, Emitter<CategoriesState> emit) async {

    emit(CategoriesDeleteLoading());

    try {
      final res  = await deleteResponse(url: AppUrls.category+event.id.toString()); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<CategoryModel>.from(data.map((x) => CategoryModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(CategoriesDeleteFailed(title: 'Alert', content: response.message??""));
        return;
      }
      clearData();
      emit(CategoriesDeleteSuccess(

      ));
    } catch (error) {
      clearData();
      emit(CategoriesDeleteFailed(title: "Error",content: error.toString()));

    }
  }

  clearData(){
    nameController.clear();
    shortNameController.clear();
  }

}



