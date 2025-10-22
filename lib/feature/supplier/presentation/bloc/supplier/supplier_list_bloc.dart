import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../core/repositories/patch_response.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../products/soruce/data/model/source_model.dart';
import '../../../data/model/supplier_list_model.dart';

part 'supplier_list_event.dart';
part 'supplier_list_state.dart';

class SupplierListBloc extends Bloc<SupplierListEvent, SupplierListState> {
  List<SupplierListModel> supplierListModel = [];
  final int _itemsPerPage = 10;
  String selectedState = "";
  TextEditingController filterTextController = TextEditingController();
  List<String> statesList = ["Active", "Inactive"];

  String selectedStateBalanceType = "";
  List<String> statusBalanceType = ["Due", "Advance"];

  SourceModel? sourceModel;

  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerNumberController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerOpeningBalanceController = TextEditingController();
  TextEditingController customerAdditionalNumberController = TextEditingController();
  TextEditingController customerAdditionalEmailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  void clearData() {
    addressController.clear();
    customerAdditionalEmailController.clear();
    customerAdditionalNumberController.clear();
    customerEmailController.clear();
    customerOpeningBalanceController.clear();
    customerNameController.clear();
    customerNumberController.clear();
    selectedStateBalanceType = "";
    selectedState = "";
  }

  SupplierListBloc() : super(SupplierListInitial()) {
    on<FetchSupplierList>(_onFetchSupplierList);
    on<AddSupplierList>(_onCreateSupplier);
    on<UpdateSupplierList>(_onUpdateSupplier);
  }

  Future<void> _onFetchSupplierList(
      FetchSupplierList event, Emitter<SupplierListState> emit) async {
    emit(SupplierListLoading());

    try {
      final res = await getResponse(url: AppUrls.supplierList, context: event.context);

      ApiResponse<List<SupplierListModel>> response = appParseJson<List<SupplierListModel>>(
        res,
            (data) => List<SupplierListModel>.from(data.map((x) => SupplierListModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(SupplierListSuccess(
          list: [],
          totalPages: 0,
          currentPage: event.pageNumber,
        ));
        return;
      }

      supplierListModel = data;
      final filteredSuppliers = _filterData(supplierListModel, event.state, event.filterText);
      final paginatedSuppliers = _paginatePage(filteredSuppliers, event.pageNumber);
      final totalPages = (filteredSuppliers.length / _itemsPerPage).ceil();

      emit(SupplierListSuccess(
        list: paginatedSuppliers,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(SupplierListFailed(title: "Error", content: error.toString()));
    }
  }

  List<SupplierListModel> _filterData(
      List<SupplierListModel> suppliers, String state, String filterText) {
    return suppliers.where((supplier) {
      final matchesState = state.isEmpty ||
          supplier.status.toString() == (state == 'Active' ? '1' : '0');
      final matchesText = filterText.isEmpty ||
          supplier.name!.toLowerCase().contains(filterText.toLowerCase()) ||
          (supplier.email?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
          (supplier.phone?.toLowerCase().contains(filterText.toLowerCase()) ?? false);
      return matchesState && matchesText;
    }).toList();
  }

  List<SupplierListModel> _paginatePage(List<SupplierListModel> suppliers, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= suppliers.length) return [];
    return suppliers.sublist(
        start, end > suppliers.length ? suppliers.length : end);
  }

  Future<void> _onCreateSupplier(
      AddSupplierList event, Emitter<SupplierListState> emit) async {
    emit(SupplierAddLoading());

    try {
      print('Creating supplier with body: ${event.body}'); // Debug log

      final res = await postResponse(url: AppUrls.supplierList, payload: event.body);

      // FIX: Parse as single object, not list
      ApiResponse<SupplierListModel> response = appParseJson<SupplierListModel>(
        res,
            (data) => SupplierListModel.fromJson(data), // Single object, not list
      );

      if (response.success == false) {
        emit(SupplierAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to create supplier"
        ));
        return;
      }

      clearData();
      emit(SupplierAddSuccess());
    } catch (error) {
      clearData();
      emit(SupplierAddFailed(title: "Error", content: error.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
      UpdateSupplierList event, Emitter<SupplierListState> emit) async {
    emit(SupplierAddLoading());

    try {
      final res = await patchResponse(
          url: '${AppUrls.supplierList}${event.branchId}/', // Add trailing slash
          payload: event.body!
      );

      // FIX: Parse as single object, not list
      ApiResponse<SupplierListModel> response = appParseJson<SupplierListModel>(
        res,
            (data) => SupplierListModel.fromJson(data), // Single object, not list
      );

      if (response.success == false) {
        emit(SupplierAddFailed(
            title: 'Error',
            content: response.message ?? "Failed to update supplier"
        ));
        return;
      }

      clearData();
      emit(SupplierAddSuccess());
    } catch (error) {
      clearData();
      emit(SupplierAddFailed(title: "Error", content: error.toString()));
    }
  }
}