// lib/feature/report/presentation/bloc/supplier_due_advance_bloc/supplier_due_advance_bloc.dart
import '/core/core.dart';
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
        // page_size: backend প্রতি page এ ১০০টা দেয় — আগে শুধু প্রথম page আসত, তাই table অসম্পূর্ণ থাকত
        final Map<String, String> queryParams = {'page_size': '1000'};

        if (event.from != null && event.to != null) {
          queryParams['start'] = event.from!.toIso8601String().split('T')[0];
          queryParams['end'] = event.to!.toIso8601String().split('T')[0];
        }

        // Build filter string
        String filter = '';
        if (queryParams.isNotEmpty) {
          filter = '?${Uri(queryParameters: queryParams).query}';
        }


        final responseString = await getResponse(
          url: AppUrls.supplierDueAdvance + filter,
          context: event.context,
        );

        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];

          try {
            final supplierDueAdvanceResponse = SupplierDueAdvanceResponse.fromJson(data as Map<String, dynamic>);

            emit(SupplierDueAdvanceSuccess(response: supplierDueAdvanceResponse));
          } catch (parseError) {
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
      } catch (e) {
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