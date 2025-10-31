// lib/feature/report/presentation/bloc/supplier_due_advance_bloc/supplier_due_advance_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_inventory/core/core.dart';
import 'package:smart_inventory/core/configs/configs.dart';
import '../../../data/model/supplier_due_advance_report_model.dart';

part 'supplier_due_advance_event.dart';
part 'supplier_due_advance_state.dart';

class SupplierDueAdvanceBloc extends Bloc<SupplierDueAdvanceEvent, SupplierDueAdvanceState> {
  DateTime? fromDate;
  DateTime? toDate;

  SupplierDueAdvanceBloc() : super(SupplierDueAdvanceInitial()) {
    on<FetchSupplierDueAdvanceReport>((event, emit) async {
      emit(SupplierDueAdvanceLoading());

      try {
        // Update filter values
        fromDate = event.from ?? fromDate;
        toDate = event.to ?? toDate;

        // Build query parameters
        final Map<String, String> queryParams = {};

        if (event.from != null && event.to != null) {
          queryParams['start_date'] = event.from!.toIso8601String().split('T')[0];
          queryParams['end_date'] = event.to!.toIso8601String().split('T')[0];
        }

        // Build filter string
        String filter = '';
        if (queryParams.isNotEmpty) {
          filter = '?${Uri(queryParameters: queryParams).query}';
        }

        print('🔗 Making API request to: ${AppUrls.supplierDueAdvance + filter}');

        final responseString = await getResponse(
          url: AppUrls.supplierDueAdvance + filter,
          context: event.context,
        );

        print('📥 Raw API response type: ${responseString.runtimeType}');
        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];
          print('🔍 Data to parse: $data');

          try {
            final supplierDueAdvanceResponse = SupplierDueAdvanceResponse.fromJson(data as Map<String, dynamic>);
            print('✅ Successfully parsed SupplierDueAdvanceResponse');
            print('✅ Total suppliers: ${supplierDueAdvanceResponse.report.length}');
            print('✅ Net balance: ${supplierDueAdvanceResponse.summary.netBalance}');

            emit(SupplierDueAdvanceSuccess(response: supplierDueAdvanceResponse));
          } catch (parseError, stackTrace) {
            print('❌ Error parsing SupplierDueAdvanceResponse: $parseError');
            print('❌ Stack trace: $stackTrace');
            emit(SupplierDueAdvanceFailed(
              title: "Parsing Error",
              content: "Failed to parse supplier due & advance data: $parseError",
            ));
          }
        } else {
          emit(SupplierDueAdvanceFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load supplier due & advance report",
          ));
        }
      } catch (e, stackTrace) {
        print('❌ Error in SupplierDueAdvanceBloc: $e');
        print('❌ Stack trace: $stackTrace');
        emit(SupplierDueAdvanceFailed(
          title: "Error",
          content: "Failed to load supplier due & advance report: ${e.toString()}",
        ));
      }
    });

    on<ClearSupplierDueAdvanceFilters>((event, emit) {
      fromDate = null;
      toDate = null;
      emit(SupplierDueAdvanceInitial());
    });
  }
}