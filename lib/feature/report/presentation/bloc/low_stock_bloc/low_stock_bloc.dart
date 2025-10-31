// lib/feature/report/presentation/bloc/low_stock_bloc/low_stock_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:smart_inventory/core/core.dart';
import 'package:smart_inventory/core/configs/configs.dart';
import 'package:smart_inventory/feature/common/data/models/api_response_mod.dart';
import 'package:smart_inventory/feature/common/data/models/app_parse_json.dart';

import '../../../data/model/low_stock_model.dart';

part 'low_stock_event.dart';
part 'low_stock_state.dart';

class LowStockBloc extends Bloc<LowStockEvent, LowStockState> {
  LowStockBloc() : super(LowStockInitial()) {
    on<FetchLowStockReport>((event, emit) async {
      emit(LowStockLoading());

      try {
        print('🔗 Making API request to: ${AppUrls.lowStock}');

        final responseString = await getResponse(
          url: AppUrls.lowStock,
          context: event.context,
        );

        print('📥 Raw API response type: ${responseString.runtimeType}');
        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];
          print('🔍 Data to parse: $data');

          try {
            final lowStockResponse = LowStockResponse.fromJson(data as Map<String, dynamic>);
            print('✅ Successfully parsed LowStockResponse');
            print('✅ Low stock items: ${lowStockResponse.report.length}');
            print('✅ Critical items: ${lowStockResponse.summary.criticalItems}');

            emit(LowStockSuccess(response: lowStockResponse));
          } catch (parseError, stackTrace) {
            print('❌ Error parsing LowStockResponse: $parseError');
            print('❌ Stack trace: $stackTrace');
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
      } catch (e, stackTrace) {
        print('❌ Error in LowStockBloc: $e');
        print('❌ Stack trace: $stackTrace');
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