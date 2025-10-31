import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:smart_inventory/core/core.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../common/data/models/api_response_mod.dart';
import '../../../../common/data/models/app_parse_json.dart';
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

        print('🔗 Making API request to: ${AppUrls.salesReport + filter}');

        final responseString = await getResponse(
          url: AppUrls.salesReport + filter,
          context: event.context,
        );

        print('📥 Raw API response type: ${responseString.runtimeType}');
        print('📥 Raw API response: $responseString');

        // Parse the JSON string to Map
        final Map<String, dynamic> res = jsonDecode(responseString);
        print('📊 Parsed response keys: ${res.keys}');

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];
          print('🔍 Data to parse: $data');
          print('🔍 Data type: ${data.runtimeType}');

          try {
            final salesReportResponse = SalesReportResponse.fromJson(data as Map<String, dynamic>);
            print('✅ Successfully parsed SalesReportResponse');
            print('✅ Report items count: ${salesReportResponse.report.length}');
            print('✅ Summary: ${salesReportResponse.summary.totalSales}');

            emit(SalesReportSuccess(response: salesReportResponse));
          } catch (parseError, stackTrace) {
            print('❌ Error parsing SalesReportResponse: $parseError');
            print('❌ Stack trace: $stackTrace');
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
      } catch (e, stackTrace) {
        print('❌ Error in SalesReportBloc: $e');
        print('❌ Stack trace: $stackTrace');
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