// lib/feature/report/presentation/bloc/supplier_ledger_bloc/supplier_ledger_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:smart_inventory/core/core.dart';

import '../../../data/model/supplier_ledger_model.dart';

part 'supplier_ledger_event.dart';
part 'supplier_ledger_state.dart';

class SupplierLedgerBloc extends Bloc<SupplierLedgerEvent, SupplierLedgerState> {
  DateTime? fromDate;
  DateTime? toDate;
  int? selectedSupplierId;

  SupplierLedgerBloc() : super(SupplierLedgerInitial()) {
    on<FetchSupplierLedgerReport>((event, emit) async {
      emit(SupplierLedgerLoading());

      try {
        // Update filter values
        fromDate = event.from ?? fromDate;
        toDate = event.to ?? toDate;
        selectedSupplierId = event.supplierId ?? selectedSupplierId;

        // Build query parameters
        final Map<String, String> queryParams = {};

        if (event.from != null && event.to != null) {
          queryParams['start'] = event.from!.toIso8601String().split('T')[0];
          queryParams['end'] = event.to!.toIso8601String().split('T')[0];
        }

        if (event.supplierId != null) {
          queryParams['supplier'] = event.supplierId.toString();
        }

        // Build filter string
        String filter = '';
        if (queryParams.isNotEmpty) {
          filter = '?${Uri(queryParameters: queryParams).query}';
        }

        print('🔗 Making API request to: ${AppUrls.supplierLedger + filter}');

        final responseString = await getResponse(
          url: AppUrls.supplierLedger + filter,
          context: event.context,
        );

        print('📥 Raw API response type: ${responseString.runtimeType}');
        final Map<String, dynamic> res = jsonDecode(responseString);

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];
          print('🔍 Data to parse: $data');

          try {
            final supplierLedgerResponse = SupplierLedgerResponse.fromJson(data as Map<String, dynamic>);
            print('✅ Successfully parsed SupplierLedgerResponse');
            print('✅ Total transactions: ${supplierLedgerResponse.report.length}');
            print('✅ Closing balance: ${supplierLedgerResponse.summary.closingBalance}');

            emit(SupplierLedgerSuccess(response: supplierLedgerResponse));
          } catch (parseError, stackTrace) {
            print('❌ Error parsing SupplierLedgerResponse: $parseError');
            print('❌ Stack trace: $stackTrace');
            emit(SupplierLedgerFailed(
              title: "Parsing Error",
              content: "Failed to parse supplier ledger data: $parseError",
            ));
          }
        } else {
          emit(SupplierLedgerFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load supplier ledger report",
          ));
        }
      } catch (e, stackTrace) {
        print('❌ Error in SupplierLedgerBloc: $e');
        print('❌ Stack trace: $stackTrace');
        emit(SupplierLedgerFailed(
          title: "Error",
          content: "Failed to load supplier ledger report: ${e.toString()}",
        ));
      }
    });

    on<ClearSupplierLedgerFilters>((event, emit) {
      fromDate = null;
      toDate = null;
      selectedSupplierId = null;
      emit(SupplierLedgerInitial());
    });
  }
}