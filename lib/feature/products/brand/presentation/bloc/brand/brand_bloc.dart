import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/repositories/delete_response.dart';
import '../../../../../../core/repositories/get_response.dart';
import '../../../../../../core/repositories/patch_response.dart';
import '../../../../../../core/repositories/post_response.dart';
import '../../../../../common/data/models/api_response_mod.dart';
import '../../../../../common/data/models/app_parse_json.dart';
import '../../../data/model/brand_model.dart';

part 'brand_event.dart';

part 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  List<BrandModel> brandModel = [];
  final int _itemsPerPage = 20;
  String selectedState = "";
  String selectedId = "";
  TextEditingController filterTextController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  BrandBloc() : super(BrandInitial()) {
    on<FetchBrandList>(_onFetchBrandList);
    on<AddBrand>(_onCreateBrandList);
    on<UpdateBrand>(_onUpdateBrandList);
    on<DeleteBrand>(_onDeleteBrandList);
  }

  Future<void> _onFetchBrandList(
    FetchBrandList event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandListLoading());

    try {
      final res = await getResponse(
        url: AppUrls.brand,
        context: event.context,
      ); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
        (data) =>
            List<BrandModel>.from(data.map((x) => BrandModel.fromJson(x))),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        emit(
          BrandListSuccess(
            list: [],
            totalPages: 0,
            currentPage: event.pageNumber,
          ),
        );
        return;
      }
      // Store all warehouses for filtering and pagination
      brandModel = data;

      // Apply filtering and pagination
      final filteredData = _filterBrand(brandModel, event.filterText);
      final paginatedPage = _paginatePage(filteredData, event.pageNumber);

      final totalPages = (filteredData.length / _itemsPerPage).ceil();

      emit(
        BrandListSuccess(
          list: paginatedPage,
          totalPages: totalPages,
          currentPage: event.pageNumber,
        ),
      );
    } catch (error) {
      emit(BrandListFailed(title: "Error", content: error.toString()));
    }
  }

  List<BrandModel> _filterBrand(List<BrandModel> list, String filterText) {
    return list.where((data) {
      final matchesText =
          filterText.isEmpty ||
          data.name!.toLowerCase().contains(filterText.toLowerCase());
      return matchesText;
    }).toList();
  }

  List<BrandModel> _paginatePage(List<BrandModel> list, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }

  Future<void> _onCreateBrandList(
    AddBrand event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandAddLoading());

    try {
      final res = await postResponse(url: AppUrls.brand, payload: event.body);

      // Log the response for debugging
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => BrandModel.fromJson(data),
      );



      if (response.success == false) {
        emit(BrandAddFailed(title: '', content: response.message ?? ""));
        return;
      }

      emit(BrandAddSuccess());
      clearData();
    } catch (error) {
      clearData();
      emit(BrandAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateBrandList(
    UpdateBrand event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandAddLoading());

    try {
      final res = await patchResponse(
        url: "${AppUrls.brand + event.id.toString()}/",
        payload: event.body!,
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);
      ApiResponse response = appParseJson(
        jsonString,
            (data) => BrandModel.fromJson(data),
      );


      if (response.success == false) {
        emit(BrandAddFailed(title: 'Alert', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(BrandAddSuccess());
    } catch (error) {
      clearData();
      emit(BrandAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onDeleteBrandList(
    DeleteBrand event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandDeleteLoading());

    try {
      final res = await deleteResponse(
        url: "${AppUrls.brand + event.id.toString()}/",
      ); // Use the correct API URL
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString, // Now passing String instead of Map
            (data) => data, // Just return data as-is for delete operations
      );
      if (response.success == false) {
        emit(BrandDeleteFailed(title: 'Json', content: response.message ?? ""));
        return;
      }
      clearData();
      emit(BrandDeleteSuccess());
    } catch (error) {
      clearData();
      emit(BrandDeleteFailed(title: "Error", content: error.toString()));
    }
  }

  clearData() {
    nameController.clear();
    addressController.clear();
  }
}
