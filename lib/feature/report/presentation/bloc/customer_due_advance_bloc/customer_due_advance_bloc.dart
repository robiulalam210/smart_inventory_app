// lib/feature/report/presentation/bloc/customer_due_advance_bloc/customer_due_advance_bloc.dart
import 'package:smart_inventory/core/core.dart';
import '../../../data/model/customer_due_advance_report_model.dart';

part 'customer_due_advance_event.dart';
part 'customer_due_advance_state.dart';

class CustomerDueAdvanceBloc extends Bloc<CustomerDueAdvanceEvent, CustomerDueAdvanceState> {
  DateTime? fromDate;
  DateTime? toDate;
  int? selectedCustomerId;
  String? selectedStatus;

  CustomerDueAdvanceBloc() : super(CustomerDueAdvanceInitial()) {
    on<FetchCustomerDueAdvanceReport>((event, emit) async {
      emit(CustomerDueAdvanceLoading());

      try {
        // Update filter values
        fromDate = event.from ?? fromDate;
        toDate = event.to ?? toDate;
        selectedCustomerId = event.customerId ?? selectedCustomerId;
        selectedStatus = event.status ?? selectedStatus;

        // Build query parameters
        final Map<String, String> queryParams = {};

        if (event.from != null && event.to != null) {
          queryParams['start'] = event.from!.toIso8601String().split('T')[0];
          queryParams['end'] = event.to!.toIso8601String().split('T')[0];
        }

        if (event.customerId != null) {
          queryParams['customer'] = event.customerId.toString();
        }

        if (event.status != null && event.status!.isNotEmpty) {
          queryParams['status'] = event.status!;
        }

        // Build filter string
        String filter = '';
        if (queryParams.isNotEmpty) {
          filter = '?${Uri(queryParameters: queryParams).query}';
        }

        print('🔗 Making API request to: ${AppUrls.customerDueAdvance + filter}');

        final responseString = await getResponse(
          url: AppUrls.customerDueAdvance + filter,
          context: event.context,
        );
        final Map<String, dynamic> res = jsonDecode(responseString);

        print('📥 Raw API response: ${res['status']}');

        if (res['status'] == true) {
          final data = res['data'];
          print('🔍 Data to parse: $data');

          try {
            final customerDueAdvanceResponse = CustomerDueAdvanceResponse.fromJson(data as Map<String, dynamic>);
            print('✅ Successfully parsed CustomerDueAdvanceResponse');
            print('✅ Total customers: ${customerDueAdvanceResponse.report.length}');

            emit(CustomerDueAdvanceSuccess(response: customerDueAdvanceResponse));
          } catch (parseError, stackTrace) {
            print('❌ Error parsing CustomerDueAdvanceResponse: $parseError');
            print('❌ Stack trace: $stackTrace');
            emit(CustomerDueAdvanceFailed(
              title: "Parsing Error",
              content: "Failed to parse customer due & advance data: $parseError",
            ));
          }
        } else {
          emit(CustomerDueAdvanceFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load customer due & advance report",
          ));
        }
      } catch (e, stackTrace) {
        print('❌ Error in CustomerDueAdvanceBloc: $e');
        print('❌ Stack trace: $stackTrace');
        emit(CustomerDueAdvanceFailed(
          title: "Error",
          content: "Failed to load customer due & advance report: ${e.toString()}",
        ));
      }
    });

    on<ClearCustomerDueAdvanceFilters>((event, emit) {
      fromDate = null;
      toDate = null;
      selectedCustomerId = null;
      selectedStatus = null;
      emit(CustomerDueAdvanceInitial());
    });
  }
}