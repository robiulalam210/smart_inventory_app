import 'package:bloc/bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meta/meta.dart';

import '../../../data/repositories/summery_repo_db.dart';

part 'summary_event.dart';
part 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final SummeryRepoDB repo;
  DateRange? selectedDateRange;

  SummaryBloc(this.repo) : super(SummaryInitial()) {
    on<LoadSummary>((event, emit) async {
      emit(SummaryLoading());
      try {
        final result = await repo.fetchMoneyReceiptWithSummary(
          fromDate: event.fromDate,
          toDate: event.toDate,
        );
        emit(SummaryLoaded(result));
      } catch (e) {
        emit(SummaryError(e.toString()));
      }
    });
  }
}

