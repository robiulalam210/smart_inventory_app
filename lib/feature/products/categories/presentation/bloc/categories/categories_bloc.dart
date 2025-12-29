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

  // TextEditingController shortNameController = TextEditingController();

  CategoriesBloc() : super(CategoriesInitial()) {
    on<FetchCategoriesList>(_onFetchCategoriesList);
    on<AddCategories>(_onCreateCategoriesList);
    on<UpdateCategories>(_onUpdateCategoriesList);
    on<UpdateSwitchCategories>(_onUpdateSwitchCategoriesList);
    on<DeleteCategories>(_onDeleteCategoriesList);
  }

  Future<void> _onFetchCategoriesList(
      FetchCategoriesList event,
      Emitter<CategoriesState> emit,
      ) async {
    emit(CategoriesListLoading());

    try {
      /// 1️⃣ API call
      final res = await getResponse(
        url: AppUrls.category,
        context: event.context,
      );

      /// 2️⃣ Ensure response is String (important)
      final String jsonString =
      res is String ? res : json.encode(res);

      /// 3️⃣ Parse API response safely
      final ApiResponse<List<CategoryModel>> response =
      appParseJson<List<CategoryModel>>(
        jsonString,
            (data) => (data as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList(),
      );

      /// 4️⃣ Validate response
      if (!response.success || response.data == null) {
        emit(
          CategoriesListFailed(
            title: response.title ?? "Failed",
            content:
            response.message ?? "Unable to fetch category list",
          ),
        );
        return;
      }

      /// 5️⃣ Store full list (for filtering)
      list = response.data!;

      /// 6️⃣ Apply filter
      final filteredData =
      _filterData(list, event.filterText, event.state);

      /// 7️⃣ Emit success
      emit(CategoriesListSuccess(list: filteredData));
    } catch (e) {
      emit(
        CategoriesListFailed(
          title: "Error",
          content: e.toString(),
        ),
      );
    }
  }


  List<CategoryModel> _filterData(
    List<CategoryModel> list,
    String filterText,
    status,
  ) {
    return list.where((data) {
      final matchesText =
          filterText.isEmpty ||
          data.name!.toLowerCase().contains(filterText.toLowerCase());
      // final matchesStatus = status.isEmpty || data.status.toString() ==(status=="Active"?"1":"0");
      return matchesText;
    }).toList();
  }

  Future<void> _onCreateCategoriesList(
    AddCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesAddLoading());

    try {
      final res = await postResponse(
        url: AppUrls.category,
        payload: event.body,
      ); // Use the correct API URL

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
        (data) => CategoryModel.fromJson(data),
      );

      if (response.success == false) {
        emit(CategoriesAddFailed(title: '', content: response.message ?? ""));
        return;
      }
      emit(CategoriesAddSuccess());
      clearData();

    } catch (error) {
      clearData();
      emit(CategoriesAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateCategoriesList(
    UpdateCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.category + event.id.toString()}/",
        payload: event.body!,
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
        (data) => CategoryModel.fromJson(data),
      );

      if (response.success == false) {
        emit(
          CategoriesAddFailed(title: 'Json', content: response.message ?? ""),
        );
        return;
      }
      emit(CategoriesAddSuccess());
      clearData();

    } catch (error) {
      clearData();
      emit(CategoriesAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateSwitchCategoriesList(
    UpdateSwitchCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesSwitchLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.category + event.id.toString()}/",
        payload: event.body!,
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
        (data) => List<CategoryModel>.from(
          data.map((x) => CategoryModel.fromJson(x)),
        ),
      );
      if (response.success == false) {
        emit(
          CategoriesSwitchFailed(
            title: 'Json',
            content: response.message ?? "",
          ),
        );
        return;
      }
      clearData();
      emit(CategoriesSwitchSuccess());
    } catch (error) {
      clearData();
      emit(CategoriesSwitchFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteCategoriesList(
    DeleteCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesDeleteLoading());

    try {
      final res = await deleteResponse(
        url: "${AppUrls.category + event.id.toString()}/",
      ); // Use the correct API URL

      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString, // Now passing String instead of Map
        (data) => data, // Just return data as-is for delete operations
      );
      if (response.success == false) {
        emit(
          CategoriesDeleteFailed(
            title: 'Alert',
            content: response.message ?? "",
          ),
        );
        return;
      }
      clearData();
      emit(CategoriesDeleteSuccess(response.message??""));
    } catch (error) {
      clearData();
      emit(CategoriesDeleteFailed(title: "Error", content: error.toString()));
    }
  }

  void clearData() {
    nameController.clear();
    // shortNameController.clear();
  }
}
