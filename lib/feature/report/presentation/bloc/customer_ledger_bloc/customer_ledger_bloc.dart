// lib/feature/report/presentation/bloc/customer_ledger_bloc/customer_ledger_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_inventory/core/core.dart';
import 'package:smart_inventory/feature/customer/data/model/customer_active_model.dart';
import '../../../data/model/customer_ledger_model.dart';

part 'customer_ledger_event.dart';
part 'customer_ledger_state.dart';

class CustomerLedgerBloc extends Bloc<CustomerLedgerEvent, CustomerLedgerState> {
  // Selected filters
  CustomerActiveModel? selectedCustomer;
  DateTime? fromDate;
  DateTime? toDate;

  CustomerLedgerBloc() : super(CustomerLedgerInitial()) {
    on<FetchCustomerLedger>((event, emit) async {
      emit(CustomerLedgerLoading());

      try {
        // Update filter values
        selectedCustomer = event.customer != null && event.customer!.isNotEmpty
            ? CustomerActiveModel(id: int.tryParse(event.customer!) ?? 0, name: '')
            : selectedCustomer;
        fromDate = event.from ?? fromDate;
        toDate = event.to ?? toDate;

        // Build query parameters
        final Map<String, String> queryParams = {};

        if (event.customer != null && event.customer!.isNotEmpty) {
          queryParams['customer'] = event.customer!;
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

        print('🔗 Making API request to: ${AppUrls.customerLedger + filter}');

        final responseString = await getResponse(
          url: AppUrls.customerLedger + filter,
          context: event.context,
        );
        final Map<String, dynamic> res = jsonDecode(responseString);

        print('📥 Raw API response type: ${res.runtimeType}');

        // Check if the response indicates success
        if (res['status'] == true) {
          final data = res['data'];
          print('🔍 Data to parse: $data');

          try {
            final customerLedgerResponse = CustomerLedgerResponse.fromJson(data as Map<String, dynamic>);
            print('✅ Successfully parsed CustomerLedgerResponse');
            print('✅ Transactions: ${customerLedgerResponse.report.length}');
            print('✅ Closing Balance: ${customerLedgerResponse.summary.closingBalance}');

            emit(CustomerLedgerSuccess(response: customerLedgerResponse));
          } catch (parseError, stackTrace) {
            print('❌ Error parsing CustomerLedgerResponse: $parseError');
            print('❌ Stack trace: $stackTrace');
            emit(CustomerLedgerFailed(
              title: "Parsing Error",
              content: "Failed to parse customer ledger data: $parseError",
            ));
          }
        } else {
          emit(CustomerLedgerFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load customer ledger",
          ));
        }
      } catch (e, stackTrace) {
        print('❌ Error in CustomerLedgerBloc: $e');
        print('❌ Stack trace: $stackTrace');
        emit(CustomerLedgerFailed(
          title: "Error",
          content: "Failed to load customer ledger: ${e.toString()}",
        ));
      }
    });

    on<ClearCustomerLedgerFilters>((event, emit) {
      selectedCustomer = null;
      fromDate = null;
      toDate = null;
      emit(CustomerLedgerInitial());
    });
  }
}