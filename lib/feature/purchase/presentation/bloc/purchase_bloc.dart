



import 'package:meherin_mart/feature/users_list/data/model/user_model.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/repositories/get_response.dart';
import '../../../common/data/models/api_response_mod.dart';
import '../../../common/data/models/app_parse_json.dart';
import '../../data/model/purchase_sale_model.dart';

part 'purchase_event.dart';

part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  List<PurchaseModel> list = [];
  String selectedStatus = "";
  UsersListModel? selectedSupplier ;
  String selectedId = "";
  List<String> statesList = ["Paid", "Pending"];

  TextEditingController filterTextController = TextEditingController();

  PurchaseBloc() : super(PurchaseInitial()) {
    on<FetchPurchaseList>(_onFetchPurchaseList);
  }
  Future<void> _onFetchPurchaseList(
      FetchPurchaseList event, Emitter<PurchaseState> emit) async {
    emit(PurchaseListLoading());

    try {
      // Build query parameters with pagination and filters
      Map<String, dynamic> queryParams = {
        'page': event.pageNumber.toString(),
        'page_size': event.pageSize.toString(),
      };

      // Add filters if provided
      if (event.filterText.isNotEmpty) {
        queryParams['search'] = event.filterText;
      }
      if (event.supplier.isNotEmpty) {
        queryParams['supplier'] = event.supplier;
      }
      if (event.paymentStatus.isNotEmpty) {
        queryParams['payment_status'] = event.paymentStatus;
      }
      if (event.startDate != null && event.endDate != null) {
        queryParams['start_date'] = event.startDate!.toIso8601String().split('T')[0];
        queryParams['end_date'] = event.endDate!.toIso8601String().split('T')[0];
      }

      // Build the complete URL with query parameters
      Uri uri = Uri.parse(AppUrls.purchase).replace(
        queryParameters: queryParams,
      );

      final res = await getResponse(
        url: uri.toString(),
        context: event.context,
      );

      // Parse the response
      ApiResponse<Map<String, dynamic>> response = appParseJson<Map<String, dynamic>>(
        res,
            (data) => data,
      );

      final data = response.data;

      if (data == null) {
        emit(PurchaseListSuccess(
          list: [],
          count: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: event.pageSize,
          from: 0,
          to: 0,
        ));
        return;
      }

      // Extract pagination info from response
      final pagination = data['pagination'] ?? data;
      final results = data['results'] ?? data['data'] ?? data;

      // Parse the purchase list
      List<PurchaseModel> purchaseList = [];
      if (results is List) {
        purchaseList = List<PurchaseModel>.from(
          results.map((x) => PurchaseModel.fromJson(x)),
        );
      }

      // Calculate pagination values
      int count = pagination['count'] ?? pagination['total'] ?? purchaseList.length;
      int totalPages = pagination['total_pages'] ?? pagination['last_page'] ??
          ((count / event.pageSize).ceil());
      int currentPage = pagination['current_page'] ?? pagination['page'] ?? event.pageNumber;
      int pageSize = pagination['page_size'] ?? pagination['per_page'] ?? event.pageSize;
      int from = ((currentPage - 1) * pageSize) + 1;
      int to = from + purchaseList.length - 1;

      emit(PurchaseListSuccess(
        list: purchaseList,
        count: count,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
        from: from,
        to: to,
      ));
    } catch (error,st) {
      print(st);
      emit(PurchaseListFailed(title: "Error", content: error.toString()));
    }
  }



}
