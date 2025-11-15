// lib/feature/report/presentation/bloc/low_stock_bloc/low_stock_bloc.dart
import 'package:smart_inventory/core/core.dart';

import '../../../data/model/low_stock_model.dart';

part 'low_stock_event.dart';
part 'low_stock_state.dart';

class LowStockBloc extends Bloc<LowStockEvent, LowStockState> {
  LowStockBloc() : super(LowStockInitial()) {
    on<FetchLowStockReport>((event, emit) async {
      emit(LowStockLoading());

      try {

        final responseString = await getResponse(
          url: AppUrls.lowStock,
          context: event.context,
        );

        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];

          try {
            final lowStockResponse = LowStockResponse.fromJson(data as Map<String, dynamic>);

            emit(LowStockSuccess(response: lowStockResponse));
          } catch (parseError) {
            emit(LowStockFailed(
              title: "Parsing Error",
              content: "Failed to parse low stock report data: $parseError",
            ));
          }
        } else {
          emit(LowStockFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load low stock report",
          ));
        }
      } catch (e) {
        emit(LowStockFailed(
          title: "Error",
          content: "Failed to load low stock report: ${e.toString()}",
        ));
      }
    });

    on<ClearLowStockFilters>((event, emit) {
      emit(LowStockInitial());
    });
  }
}