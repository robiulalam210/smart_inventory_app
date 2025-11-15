// lib/feature/report/presentation/bloc/stock_report_bloc/stock_report_bloc.dart
import 'package:smart_inventory/core/core.dart';
import '../../../data/model/stock_report_model.dart';

part 'stock_report_event.dart';
part 'stock_report_state.dart';

class StockReportBloc extends Bloc<StockReportEvent, StockReportState> {
  DateTime? fromDate;
  DateTime? toDate;

  StockReportBloc() : super(StockReportInitial()) {
    on<FetchStockReport>((event, emit) async {
      emit(StockReportLoading());

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


        final responseString = await getResponse(
          url: AppUrls.stockReport + filter,
          context: event.context,
        );
        final Map<String, dynamic> res = jsonDecode(responseString);


        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];

          try {
            final stockReportResponse = StockReportResponse.fromJson(data as Map<String, dynamic>);

            emit(StockReportSuccess(response: stockReportResponse));
          } catch (parseError) {
            emit(StockReportFailed(
              title: "Parsing Error",
              content: "Failed to parse stock report data: $parseError",
            ));
          }
        } else {
          emit(StockReportFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load stock report",
          ));
        }
      } catch (e) {
        emit(StockReportFailed(
          title: "Error",
          content: "Failed to load stock report: ${e.toString()}",
        ));
      }
    });

    on<ClearStockReportFilters>((event, emit) {
      fromDate = null;
      toDate = null;
      emit(StockReportInitial());
    });
  }
}