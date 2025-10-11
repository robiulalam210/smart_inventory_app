part of 'finder_bloc.dart';

@immutable
sealed class FinderEvent {}



// Fetch all invoices with optional search (no user filtering)
class FetchInvoicesEvent extends FinderEvent {
  final String? search;

  FetchInvoicesEvent({this.search});

  List<Object?> get props => [search];
}

// Fetch invoices filtered by current logged-in user with optional search
class FetchInvoicesByUserEvent extends FinderEvent {
  final String? search;

  FetchInvoicesByUserEvent({this.search});

  List<Object?> get props => [search];
}
