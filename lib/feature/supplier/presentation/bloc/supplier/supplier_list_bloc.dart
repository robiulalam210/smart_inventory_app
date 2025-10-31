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
      // Build query parameters with pagination
      Map<String, dynamic> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      // Add search filter if provided
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }

      // Add status filter if provided
      if (event.state.isNotEmpty) {
        queryParams['status'] = event.state;
      }

      final res = await getResponse(
        url: AppUrls.supplierList,
        queryParams: queryParams,
        context: event.context,
      );

      // Parse the response
      ApiResponse<Map<String, dynamic>> response = appParseJson<Map<String, dynamic>>(
        res,
            (data) => data,
      );

      final data = response.data;

      if (data == null) {
        emit(SupplierListSuccess(
          list: [],
          count: 0,
          totalPages: 0,
          currentPage: event.pageNumber,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }

      // Extract pagination info from response
      final pagination = data['pagination'] ?? {};
      final results = data['results'] ?? [];

      // Parse the supplier list
      List<SupplierListModel> supplierList = [];
      if (results is List) {
        supplierList = List<SupplierListModel>.from(
          results.map((x) => SupplierListModel.fromJson(x)),
        );
      }

      // Calculate pagination values with null safety
      int count = (pagination['count'] as int?) ?? supplierList.length;
      int totalPages = (pagination['total_pages'] as int?) ?? 1;
      int currentPage = (pagination['current_page'] as int?) ?? event.pageNumber;
      int pageSize = (pagination['page_size'] as int?) ?? event.pageSize;

      // Calculate from and to with bounds checking
      int from = count > 0 ? ((currentPage - 1) * pageSize) + 1 : 0;
      int to = count > 0 ? from + supplierList.length - 1 : 0;

      // Ensure 'to' doesn't exceed total count
      if (to > count) {
        to = count;
      }

      // Store all suppliers for filtering and pagination
      supplierListModel = supplierList;

      emit(SupplierListSuccess(
        list: supplierList,
        count: count,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
        from: from,
        to: to,
      ));

    } catch (error, stackTrace) {
      // FIXED: Proper error handling with stack trace
      debugPrint('Supplier List Error: $error');
      debugPrint('Stack Trace: $stackTrace');

      emit(SupplierListFailed(
          title: "Error",
          content: error.toString()
      ));
    }
  }
  Future<void> _onCreateSupplier(
      AddSupplierList event, Emitter<SupplierListState> emit) async {
    emit(SupplierAddLoading());

    try {
      print('Creating supplier with body: ${event.body}'); // Debug log

      final res = await postResponse(url: AppUrls.supplierList, payload: event.body);
      final jsonString = jsonEncode(res);

      ApiResponse response = appParseJson(
        jsonString,
            (data) => SupplierListModel.fromJson(data),
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