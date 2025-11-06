part of 'supplier_payment_bloc.dart';

// @immutable
sealed class SupplierPaymentState {}

final class SupplierPaymentInitial extends SupplierPaymentState {}



final class SupplierPaymentListLoading extends SupplierPaymentState {}

final class SupplierPaymentListSuccess extends SupplierPaymentState {
  String selectedState = "";
  final List<SupplierPaymentModel> list;
  final int totalPages;
  final int currentPage;
  final int count;
  final int pageSize;
  final int from;
  final int to;

  SupplierPaymentListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
    required this.count,
    required this.pageSize,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [
    list,
    totalPages,
    currentPage,
    count,
    pageSize,
    from,
    to,
    selectedState,
  ];
}
final class SupplierPaymentListFailed extends SupplierPaymentState {
  final String title, content;

  SupplierPaymentListFailed({required this.title, required this.content});
}



final class SupplierPaymentAddInitial extends SupplierPaymentState {}

final class SupplierPaymentAddLoading extends SupplierPaymentState {}

final class SupplierPaymentAddSuccess extends SupplierPaymentState {
  SupplierPaymentAddSuccess();
}

final class SupplierPaymentAddFailed extends SupplierPaymentState {
  final String title, content;

  SupplierPaymentAddFailed({required this.title, required this.content});
}




final class SupplierPaymentDeleteInitial extends SupplierPaymentState {}

final class SupplierPaymentDeleteLoading extends SupplierPaymentState {}

final class SupplierPaymentDeleteSuccess extends SupplierPaymentState {
  SupplierPaymentDeleteSuccess();
}

final class SupplierPaymentDeleteFailed extends SupplierPaymentState {
  final String title, content;

  SupplierPaymentDeleteFailed({required this.title, required this.content});
}



final class SupplierPaymentDetailsInitial extends SupplierPaymentState {}

final class SupplierPaymentDetailsLoading extends SupplierPaymentState {}

final class SupplierPaymentDetailsSuccess extends SupplierPaymentState {
  SupplierPaymentDetailsModel details;
  SupplierPaymentDetailsSuccess({ required this.details});
}

final class SupplierPaymentDetailsFailed extends SupplierPaymentState {
  final String title, content;

  SupplierPaymentDetailsFailed({required this.title, required this.content});
}