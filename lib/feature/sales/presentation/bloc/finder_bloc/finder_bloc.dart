import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../transactions/data/models/invoice_sync_response_model.dart';
import '../../../data/repositories/finder_repo_db.dart';

part 'finder_event.dart';
part 'finder_state.dart';




class FinderBloc extends Bloc<FinderEvent, FinderState> {
  final FinderRepoDb finderRepo;

  FinderBloc({required this.finderRepo}) : super(FinderInitial()) {
    // Fetch all invoices (no user filtering)
    on<FetchInvoicesEvent>((event, emit) async {
      emit(FinderLoading());
      try {
        final invoiceData = await finderRepo.fetchInvoicesWithSummary(event.search);
        emit(FinderLoaded(invoiceData));
      } catch (e) {
        emit(FinderError('Failed to fetch invoices: $e'));
      }
    });

    // Fetch invoices filtered by current user
    on<FetchInvoicesByUserEvent>((event, emit) async {
      emit(FinderInvoiceUserLoading());
      try {
        final invoiceData = await finderRepo.fetchInvoicesWithCurrentUser(search: event.search);
        emit(FinderInvoiceUserLoaded(invoiceData));
      } catch (e) {
        emit(FinderInvoiceUserError('Failed to fetch user invoices: $e'));
      }
    });
  }
}

