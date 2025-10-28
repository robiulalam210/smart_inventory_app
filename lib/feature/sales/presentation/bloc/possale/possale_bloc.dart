import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../data/models/pos_sale_model.dart';

part 'possale_event.dart';

part 'possale_state.dart';

class PosSaleBloc extends Bloc<PosSaleEvent, PosSaleState> {
  List<String> posTypeList = ["Sale", "Pos Sale"];
  List<PosSaleModel> list = [];
  CustomerActiveModel? selectCustomerModel;
  UsersListModel? selectUserModel;
  PosSaleBloc() : super(PosSaleInitial()) {
    on<FetchPosSaleList>(_onFetchPosSaleList);
    on<FetchCustomerSaleList>(_onFetchCustomerSaleList);
  }
  Future<void> _onFetchPosSaleList(
      FetchPosSaleList event,
      Emitter<PosSaleState> emit,
      ) async {
    emit(PosSaleListLoading());
    list = [];

    try {
      final res = await getResponse(
        url: AppUrls.posSale + (event.dropdownFilter ?? ''),
        context: event.context,
      );

      // Use the same proven approach as your product list
      final Map<String, dynamic> payload;
      payload = jsonDecode(res) as Map<String, dynamic>;

      // Support both "status" and "success" naming
      final bool ok = (payload['status'] == true) || (payload['success'] == true);

      if (ok) {
        final data = payload['data'] ?? {};
        final List<dynamic> results = (data['results'] is List) ? List<dynamic>.from(data['results']) : [];

        print("📋 Raw results length: ${results.length}");
        print("📊 Data count from API: ${data['count']}");

        // Parse POS sale list
        list = results.map((x) => PosSaleModel.fromJson(Map<String, dynamic>.from(x))).toList();

        print("✅ Parsed list length: ${list.length}");

        // Pagination info - match your API response structure
        final int totalPages = (data['total_pages'] is int) ? data['total_pages'] as int : 1;
        final int currentPage = (data['current_page'] is int) ? data['current_page'] as int : 1;
        final int count = (data['count'] is int) ? data['count'] as int : list.length;
        final int pageSize = (data['page_size'] is int) ? data['page_size'] as int : 10;
        final int from = ((currentPage - 1) * pageSize + 1);
        final int to = ((currentPage - 1) * pageSize + list.length);

        if (list.isEmpty) {
          emit(
            PosSaleListSuccess(
              list: list,
              totalPages: totalPages < 1 ? 1 : totalPages,
              currentPage: currentPage < 1 ? 1 : currentPage,
              count: count,
              pageSize: pageSize,
              from: from,
              to: to,
            ),
          );
          return;
        }

        emit(
          PosSaleListSuccess(
            list: list,
            totalPages: totalPages < 1 ? 1 : totalPages,
            currentPage: currentPage < 1 ? 1 : currentPage,
            count: count,
            pageSize: pageSize,
            from: from,
            to: to,
          ),
        );

        print("🎉 Success! Emitted ${list.length} items");
      } else {
        final message = payload['message'] ?? payload['error'] ?? 'Unknown Error';
        emit(
          PosSaleListFailed(
            title: "Error",
            content: message.toString(),
          ),
        );
      }
    } catch (error, st) {
      print("💥 Error fetching POS sales: $error");
      print("📝 Stack trace: $st");
      emit(PosSaleListFailed(title: "Exception", content: error.toString()));
    }
  }

  Future<void> _onFetchCustomerSaleList(
      FetchCustomerSaleList event,
      Emitter<PosSaleState> emit,
      ) async {
    emit(PosSaleListLoading());
    list = [];

    try {
      final res = await getResponse(
        url: AppUrls.baseUrl + (event.dropdownFilter ?? ''),
        context: event.context,
      );

      // Parse and wrap response with ApiResponse
      ApiResponse response = appParseJson(
        res,
            (data) =>
        List<PosSaleModel>.from(data.map((x) => PosSaleModel.fromJson(x))),
      );

      if (response.success == true) {
        final data = response.data ?? [];

        if (data.isEmpty) {
          emit(PosSaleListFailed(title: "Error", content: "No data found"));
          return;
        }
        list=data;

        // emit(PosSaleListSuccess(list: data));
      } else {
        emit(
          PosSaleListFailed(
            title: "Error",
            content: response.message ?? "Unknown error occurred",
          ),
        );
      }
    } catch (error, st) {
      print(error);
      print(st);
      emit(PosSaleListFailed(title: "Exception", content: error.toString()));
    }
  }

}
