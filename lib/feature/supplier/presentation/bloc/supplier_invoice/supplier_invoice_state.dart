part of 'supplier_invoice_bloc.dart';

// @immutable
sealed class SupplierInvoiceState {}

final class SupplierInvoiceInitial extends SupplierInvoiceState {}






final class SupplierInvoiceListLoading extends SupplierInvoiceState {}

final class SupplierInvoiceListSuccess extends SupplierInvoiceState {

  final List<SupplierInvoiceListModel> list;
  final int totalPages;
  final int currentPage;

  SupplierInvoiceListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}
final class SupplierInvoiceListFailed extends SupplierInvoiceState {
  final String title, content;

  SupplierInvoiceListFailed({required this.title, required this.content});
}
final class SupplierActiveListLoading extends SupplierInvoiceState {}

final class SupplierActiveListSuccess extends SupplierInvoiceState {

  final List<SupplierActiveModel> list;


  SupplierActiveListSuccess({
    required this.list,

  });
}
final class SupplierActiveListFailed extends SupplierInvoiceState {
  final String title, content;

  SupplierActiveListFailed({required this.title, required this.content});
}




sealed class SupplierInvoiceDetailsState {}

final class SupplierInvoiceDetailsInitial extends SupplierInvoiceDetailsState {}

final class SupplierInvoiceDetailsLoading extends SupplierInvoiceDetailsState {}



final class SupplierInvoiceDetailsFailed extends SupplierInvoiceDetailsState {
  final String title, content;

  SupplierInvoiceDetailsFailed({required this.title, required this.content});
}
