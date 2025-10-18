

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
  List<String> statusBalanceType = [
    "Due",
    "Advance",
  ];

  SourceModel? sourceModel;


  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerNumberController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();

  TextEditingController customerOpeningBalanceController =
  TextEditingController();
  TextEditingController customerAdditionalNumberController =
  TextEditingController();
  TextEditingController customerAdditionalEmailController =
  TextEditingController();
  TextEditingController addressController = TextEditingController();
  clearData(){
    addressController.clear();
    customerAdditionalEmailController.clear();
    customerAdditionalNumberController.clear();
    customerEmailController.clear();
    customerOpeningBalanceController.clear();
   selectedStateBalanceType="";
    selectedState="";
  }
  SupplierListBloc() : super(SupplierListInitial()) {
    on<FetchSupplierList>(_onFetchWarehouseList);
    on<AddSupplierList>(_onCreateWarehouseList);
    on<UpdateSupplierList>(_onUpdateBranchList);
  }



  Future<void> _onFetchWarehouseList(
      FetchSupplierList event, Emitter<SupplierListState> emit) async {

    emit(SupplierListLoading());

    try {
      final res  = await getResponse(url: AppUrls.supplierList, context: event.context); // Use the correct API URL

      // final response=warehouseBranchModelFromJson(res);

      ApiResponse<List<SupplierListModel>> response = appParseJson<List<SupplierListModel>>(
        res,
            (data) => List<SupplierListModel>.from(data.map((x) => SupplierListModel.fromJson(x))),
      );
      final data = response.data;

      if (data == null || data.isEmpty) {
        emit(SupplierListFailed(title: "Error",content: "No Data"));

        return;
      }
      // Store all warehouses for filtering and pagination
      supplierListModel = data;

      // Apply filtering and pagination
      final filteredWarehouses = _filterData(supplierListModel, event.state, event.filterText);
      final paginatedWarehouses = __paginatePage(filteredWarehouses, event.pageNumber);

      final totalPages = (filteredWarehouses.length / _itemsPerPage).ceil();

      emit(SupplierListSuccess(
        list: paginatedWarehouses,
        totalPages: totalPages,
        currentPage: event.pageNumber,
      ));
    } catch (error) {
      emit(SupplierListFailed(title: "Error",content: error.toString()));
    }
  }

  List<SupplierListModel> _filterData(
      List<SupplierListModel> warehouses, String state, String filterText) {
    return warehouses.where((warehouse) {
      final matchesState = state.isEmpty || warehouse.status.toString() == (state == 'Active' ? '1' : '0');
      final matchesText = filterText.isEmpty || warehouse.name!.toLowerCase().contains(filterText.toLowerCase());
      return matchesState && matchesText;
    }).toList();
  }

  List<SupplierListModel> __paginatePage(List<SupplierListModel> warehouses, int pageNumber) {
    final start = pageNumber * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= warehouses.length) return [];
    return warehouses.sublist(start, end > warehouses.length ? warehouses.length : end);
  }


  Future<void> _onCreateWarehouseList(
      AddSupplierList event, Emitter<SupplierListState> emit) async {

    emit(SupplierAddLoading());

    try {
      final res  = await postResponse(url: AppUrls.supplierList,payload: event.body); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<SupplierListModel>.from(data.map((x) => SupplierListModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(SupplierAddFailed(title: '', content: response.message??""));
        return;
      }
      clearData();
      emit(SupplierAddSuccess(

      ));
    } catch (error) {
      clearData();
      emit(SupplierAddFailed(title: "Error",content: error.toString()));

    }
  }

  Future<void> _onUpdateBranchList(
      UpdateSupplierList event, Emitter<SupplierListState> emit) async {

    emit(SupplierAddLoading());

    try {
      final res  = await patchResponse(url: AppUrls.supplierList+event.branchId.toString(),payload: event.body!); // Use the correct API URL

      ApiResponse response = appParseJson(
        res,
            (data) => List<SupplierListModel>.from(data.map((x) => SupplierListModel.fromJson(x))),
      );
      if (response.success == false) {
        emit(SupplierAddFailed(title: '', content: response.message??""));
        return;
      }
      clearData();
      emit(SupplierAddSuccess(

      ));
    } catch (error) {
      clearData();
      emit(SupplierAddFailed(title: "Error",content: error.toString()));

    }
  }


}
