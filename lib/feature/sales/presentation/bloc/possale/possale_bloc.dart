import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/delete_response.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
import '../../../data/models/pos_sale_model.dart';

part 'possale_event.dart';

part 'possale_state.dart';

class PosSaleBloc extends Bloc<PosSaleEvent, PosSaleState> {
  List<String> posTypeList = ["Sale", "Pos Sale"];
  List<PosSaleModel> list = [];

  PosSaleBloc() : super(PosSaleInitial()) {
    on<FetchPosSaleList>(_onFetchPosSaleList);
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

        emit(PosSaleListSuccess(list: data));
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

  List<PosSaleModel> _filterData(
    List<PosSaleModel> posSale,
    String filterText,
    String customerName,
    String sellerName,
    String paymentType,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return posSale.where((sale) {
      final invoiceNo = sale.invoiceNo?.toLowerCase() ?? '';
      final customer = sale.customerName?.toLowerCase() ?? '';
      final payment = sale.saleType?.toLowerCase() ?? '';
      final saleDate = sale.saleDate;

      // Check filterText (invoiceNo, customerName, customerPhone)
      final matchesText =
          filterText.isEmpty ||
          invoiceNo.contains(filterText.toLowerCase()) ||
          customer.contains(filterText.toLowerCase());

      // Check customerName filter
      final matchesCustomer =
          customerName.isEmpty || customer.contains(customerName.toLowerCase());

      // Check sellerName filter

      // Check paymentType filter
      final matchesPaymentType =
          paymentType.isEmpty || payment.contains(paymentType.toLowerCase());

      // Check date range filter with specific date comparisons
      final matchesDate =
          (startDate == null ||
              saleDate != null && !saleDate.isBefore(startDate)) &&
          (endDate == null || saleDate != null && !saleDate.isAfter(endDate));

      // Return true if all filters match
      return matchesText &&
          matchesCustomer &&
          matchesPaymentType &&
          matchesDate;
    }).toList();
  }
}
