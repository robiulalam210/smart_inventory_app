// lib/feature/report/presentation/bloc/purchase_report_bloc/purchase_report_bloc.dart
import 'package:smart_inventory/core/core.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_active_model.dart';

import '../../../data/model/purchase_report_model.dart';

part 'purchase_report_event.dart';
part 'purchase_report_state.dart';

class PurchaseReportBloc extends Bloc<PurchaseReportEvent, PurchaseReportState> {
  // Selected filters
  SupplierActiveModel? selectedSupplier;
  DateTime? fromDate;
  DateTime? toDate;

  PurchaseReportBloc() : super(PurchaseReportInitial()) {
    on<FetchPurchaseReport>((event, emit) async {
      emit(PurchaseReportLoading());

      try {
        // Update filter values
        selectedSupplier = event.supplier != null && event.supplier!.isNotEmpty
            ? SupplierActiveModel(id: int.tryParse(event.supplier!) ?? 0, name: '')
            : selectedSupplier;
        fromDate = event.from ?? fromDate;
        toDate = event.to ?? toDate;

        // Build query parameters
        final Map<String, String> queryParams = {};

        if (event.supplier != null && event.supplier!.isNotEmpty) {
          queryParams['supplier'] = event.supplier!;
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

        print('🔗 Making API request to: ${AppUrls.purchaseReport + filter}');

        final responseString = await getResponse(
          url: AppUrls.purchaseReport + filter,
          context: event.context,
        );
        final Map<String, dynamic> res = jsonDecode(responseString);

        print('📥 Raw API response type: ${res.runtimeType}');
        print('📥 Raw API response keys: ${res.keys}');

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];
          print('🔍 Data to parse: $data');
          print('🔍 Data type: ${data.runtimeType}');

          try {
            final purchaseReportResponse = PurchaseReportResponse.fromJson(data as Map<String, dynamic>);
            print('✅ Successfully parsed PurchaseReportResponse');
            print('✅ Report items count: ${purchaseReportResponse.report.length}');
            print('✅ Summary total: ${purchaseReportResponse.summary.totalPurchases}');

            emit(PurchaseReportSuccess(response: purchaseReportResponse));
          } catch (parseError, stackTrace) {
            print('❌ Error parsing PurchaseReportResponse: $parseError');
            print('❌ Stack trace: $stackTrace');
            emit(PurchaseReportFailed(
              title: "Parsing Error",
              content: "Failed to parse purchase report data: $parseError",
            ));
          }
        } else {
          emit(PurchaseReportFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load purchase report",
          ));
        }
      } catch (e, stackTrace) {
        print('❌ Error in PurchaseReportBloc: $e');
        print('❌ Stack trace: $stackTrace');
        emit(PurchaseReportFailed(
          title: "Error",
          content: "Failed to load purchase report: ${e.toString()}",
        ));
      }
    });

    on<ClearPurchaseReportFilters>((event, emit) {
      selectedSupplier = null;
      fromDate = null;
      toDate = null;
      emit(PurchaseReportInitial());
    });
  }
}