import 'package:smart_inventory/core/core.dart';

import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../data/model/sales_report_model.dart';

part 'sales_report_event.dart';
part 'sales_report_state.dart';


class SalesReportBloc extends Bloc<SalesReportEvent, SalesReportState> {
  // Selected filters
  CustomerActiveModel? selectedCustomer;
  UsersListModel? selectedSeller;
  DateTime? fromDate;
  DateTime? toDate;

  SalesReportBloc() : super(SalesReportInitial()) {
    on<FetchSalesReport>((event, emit) async {
      emit(SalesReportLoading());

      try {
        // Update filter values
        selectedCustomer = event.customer != null && event.customer!.isNotEmpty
            ? CustomerActiveModel(id: int.tryParse(event.customer!) ?? 0, name: '')
            : selectedCustomer;
        selectedSeller = event.seller != null && event.seller!.isNotEmpty
            ? UsersListModel(id: int.tryParse(event.seller!) ?? 0, username: '')
            : selectedSeller;
        fromDate = event.from ?? fromDate;
        toDate = event.to ?? toDate;

        // Build query parameters
        final Map<String, String> queryParams = {};

        if (event.customer != null && event.customer!.isNotEmpty) {
          queryParams['customer'] = event.customer!;
        }
        if (event.seller != null && event.seller!.isNotEmpty) {
          queryParams['seller'] = event.seller!;
        }
        if (event.from != null && event.to != null) {
          queryParams['start_date'] = event.from!.toIso8601String().split('T')[0];
          queryParams['end_date'] = event.to!.toIso8601String().split('T')[0];
        }

        // Build filter string
        String filter = '';
        if (queryParams.isNotEmpty) {
          filter = '?${Uri(queryParameters: queryParams).query}';
        }


        final responseString = await getResponse(
          url: AppUrls.salesReport + filter,
          context: event.context,
        );


        // Parse the JSON string to Map
        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];

          try {
            final salesReportResponse = SalesReportResponse.fromJson(data as Map<String, dynamic>);

            emit(SalesReportSuccess(response: salesReportResponse));
          } catch (parseError) {
            emit(SalesReportFailed(
              title: "Parsing Error",
              content: "Failed to parse sales report data: $parseError",
            ));
          }
        } else {
          emit(SalesReportFailed(
            title: res['title']?.toString() ?? "Error",
            content: res['message']?.toString() ?? "Failed to load sales report",
          ));
        }
      } catch (e) {
        emit(SalesReportFailed(
          title: "Error",
          content: "Failed to load sales report: ${e.toString()}",
        ));
      }
    });

    on<ClearSalesReportFilters>((event, emit) {
      selectedCustomer = null;
      selectedSeller = null;
      fromDate = null;
      toDate = null;
      emit(SalesReportInitial());
    });
  }
}