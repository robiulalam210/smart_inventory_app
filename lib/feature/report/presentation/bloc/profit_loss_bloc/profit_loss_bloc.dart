// lib/feature/report/presentation/bloc/profit_loss_bloc/profit_loss_bloc.dart
import 'package:smart_inventory/core/core.dart';
import '../../../data/model/profit_loss_report_model.dart';

part 'profit_loss_event.dart';
part 'profit_loss_state.dart';

class ProfitLossBloc extends Bloc<ProfitLossEvent, ProfitLossState> {
  DateTime? fromDate;
  DateTime? toDate;

  ProfitLossBloc() : super(ProfitLossInitial()) {
    on<FetchProfitLossReport>((event, emit) async {
      emit(ProfitLossLoading());

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
          url: AppUrls.profitLoss + filter,
          context: event.context,
        );

        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];

          try {
            final profitLossResponse = ProfitLossResponse.fromJson(data as Map<String, dynamic>);

            emit(ProfitLossSuccess(response: profitLossResponse));
          } catch (parseError, stackTrace) {
            emit(ProfitLossFailed(
              title: "Parsing Error",
              content: "Failed to parse profit & loss report data: $parseError",
            ));
          }
        } else {
          emit(ProfitLossFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load profit & loss report",
          ));
        }
      } catch (e, stackTrace) {
        emit(ProfitLossFailed(
          title: "Error",
          content: "Failed to load profit & loss report: ${e.toString()}",
        ));
      }
    });

    on<ClearProfitLossFilters>((event, emit) {
      fromDate = null;
      toDate = null;
      emit(ProfitLossInitial());
    });
  }
}