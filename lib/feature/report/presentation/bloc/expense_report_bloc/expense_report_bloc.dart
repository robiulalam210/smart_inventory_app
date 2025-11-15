// lib/feature/report/presentation/bloc/expense_report_bloc/expense_report_bloc.dart
import 'package:smart_inventory/core/core.dart';
import '../../../data/model/expense_report_model.dart';

part 'expense_report_event.dart';
part 'expense_report_state.dart';

class ExpenseReportBloc extends Bloc<ExpenseReportEvent, ExpenseReportState> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedHead;
  String? selectedSubHead;
  String? selectedPaymentMethod;

  ExpenseReportBloc() : super(ExpenseReportInitial()) {
    on<FetchExpenseReport>((event, emit) async {
      emit(ExpenseReportLoading());

      try {
        // Update filter values
        fromDate = event.from ?? fromDate;
        toDate = event.to ?? toDate;
        selectedHead = event.head ?? selectedHead;
        selectedSubHead = event.subHead ?? selectedSubHead;
        selectedPaymentMethod = event.paymentMethod ?? selectedPaymentMethod;

        // Build query parameters
        final Map<String, String> queryParams = {};

        if (event.from != null && event.to != null) {
          queryParams['start'] = event.from!.toIso8601String().split('T')[0];
          queryParams['end'] = event.to!.toIso8601String().split('T')[0];
        }

        if (event.head != null && event.head!.isNotEmpty) {
          queryParams['category'] = event.head!;
        }

        if (event.subHead != null && event.subHead!.isNotEmpty) {
          queryParams['sub_category'] = event.subHead!;
        }

        if (event.paymentMethod != null && event.paymentMethod!.isNotEmpty) {
          queryParams['payment_method'] = event.paymentMethod!;
        }

        // Build filter string
        String filter = '';
        if (queryParams.isNotEmpty) {
          filter = '?${Uri(queryParameters: queryParams).query}';
        }


        final responseString = await getResponse(
          url: AppUrls.expenseReport + filter,
          context: event.context,
        );
        final Map<String, dynamic> res = jsonDecode(responseString);


        if (res['status'] == true) {
          final data = res['data'];

          try {
            final expenseReportResponse = ExpenseReportResponse.fromJson(data as Map<String, dynamic>);

            emit(ExpenseReportSuccess(response: expenseReportResponse));
          } catch (parseError, stackTrace) {
            emit(ExpenseReportFailed(
              title: "Parsing Error",
              content: "Failed to parse expense report data: $parseError",
            ));
          }
        } else {
          emit(ExpenseReportFailed(
            title: res['title'] ?? "Error",
            content: res['message'] ?? "Failed to load expense report",
          ));
        }
      } catch (e, stackTrace) {
        emit(ExpenseReportFailed(
          title: "Error",
          content: "Failed to load expense report: ${e.toString()}",
        ));
      }
    });

    on<ClearExpenseReportFilters>((event, emit) {
      fromDate = null;
      toDate = null;
      selectedHead = null;
      selectedSubHead = null;
      selectedPaymentMethod = null;
      emit(ExpenseReportInitial());
    });
  }
}