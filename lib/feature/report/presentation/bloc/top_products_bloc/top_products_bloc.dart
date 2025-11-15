// lib/feature/report/presentation/bloc/top_products_bloc/top_products_bloc.dart
import 'package:smart_inventory/core/core.dart';
import '../../../data/model/top_products_model.dart';

part 'top_products_event.dart';
part 'top_products_state.dart';

class TopProductsBloc extends Bloc<TopProductsEvent, TopProductsState> {
  DateTime? fromDate;
  DateTime? toDate;

  TopProductsBloc() : super(TopProductsInitial()) {
    on<FetchTopProductsReport>((event, emit) async {
      emit(TopProductsLoading());

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
          url: AppUrls.topProducts + filter,
          context: event.context,
        );

        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];

          try {
            final topProductsResponse = TopProductsResponse.fromJson(data as Map<String, dynamic>);

            emit(TopProductsSuccess(response: topProductsResponse));
          } catch (parseError) {
            emit(TopProductsFailed(
              title: "Parsing Error",
              content: "Failed to parse top products report data: $parseError",
            ));
          }
        } else {
          emit(TopProductsFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load top products report",
          ));
        }
      } catch (e) {
        emit(TopProductsFailed(
          title: "Error",
          content: "Failed to load top products report: ${e.toString()}",
        ));
      }
    });

    on<ClearTopProductsFilters>((event, emit) {
      fromDate = null;
      toDate = null;
      emit(TopProductsInitial());
    });
  }
}