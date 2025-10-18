



import 'package:meta/meta.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/repositories/delete_response.dart';
import '../../../../core/repositories/get_response.dart';
import '../../../common/data/models/api_response_mod.dart';
import '../../../common/data/models/app_parse_json.dart';
import '../../data/model/purchase_sale_model.dart';

part 'purchase_event.dart';

part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  List<PurchaseModel> list = [];
  String selectedStatus = "";
  String selectedSupplier = "";
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
      final res = await getResponse(url: AppUrls.purchase, context: event.context);

      // Decode JSON response
      ApiResponse response = appParseJson(
        res,
            (data) =>
        List<PurchaseModel>.from(data.map((x) => PurchaseModel.fromJson(x))),
      );

      if (response.success == true) {
        final data = response.data ?? [];

        if (data.isEmpty) {
          emit(PurchaseListSuccess(list: data));
          return;
        }

        emit(PurchaseListSuccess(list: data));
      } else {
        emit(
          PurchaseListFailed(
            title: "Error",
            content: response.message ?? "Unknown error occurred",
          ),
        );
      }
      // Check if success is true

    } catch (error) {
      emit(PurchaseListFailed(title: "Error", content: error.toString()));
    }
  }

  List<PurchaseModel> _filterData(
    List<PurchaseModel> warehouses,
    DateTime? startDate,
    DateTime? endDate,
    String supplierFilter,
    String paymentStatusFilter,
  ) {
    return warehouses.where((purchase) {
      // Debugging each condition
      final matchesDate = (startDate == null || endDate == null) ||
          (purchase.date != null &&
              ((purchase.date!.isAfter(startDate) &&
                      purchase.date!.isBefore(endDate)) ||
                  purchase.date!.isAtSameMomentAs(startDate) ||
                  purchase.date!.isAtSameMomentAs(endDate)));



      final matchesSupplier = supplierFilter.isEmpty ||
          (purchase.supplier != null &&
              purchase.supplier!.toString().toLowerCase() ==
                  (supplierFilter.toLowerCase()));

      final matchesPaymentStatus = paymentStatusFilter.isEmpty ||
          (purchase.paymentStatus != null &&
              purchase.paymentStatus!.toLowerCase() ==
                  paymentStatusFilter.toLowerCase());

      return matchesDate &&
          matchesSupplier &&
          matchesPaymentStatus;
    }).toList();
  }


}
