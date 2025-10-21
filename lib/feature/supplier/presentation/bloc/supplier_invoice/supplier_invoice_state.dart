part of 'supplier_invoice_bloc.dart';

// @immutable
sealed class SupplierInvoiceState {}

final class SupplierInvoiceInitial extends SupplierInvoiceState {}






final class SupplierInvoiceListLoading extends SupplierInvoiceState {}

final class SupplierInvoiceListSuccess extends SupplierInvoiceState {
  String selectedState = "";

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




sealed class SupplierInvoiceDetailsState {}

final class SupplierInvoiceDetailsInitial extends SupplierInvoiceDetailsState {}

final class SupplierInvoiceDetailsLoading extends SupplierInvoiceDetailsState {}



final class SupplierInvoiceDetailsFailed extends SupplierInvoiceDetailsState {
  final String title, content;

  SupplierInvoiceDetailsFailed({required this.title, required this.content});
}
