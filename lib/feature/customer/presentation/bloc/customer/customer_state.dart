part of 'customer_bloc.dart';

// @immutable
sealed class CustomerState {}

final class CustomerInitial extends CustomerState {}

final class CustomerListLoading extends CustomerState {}

final class CustomerSuccess extends CustomerState {
  String selectedState = "";

  final List<CustomerModel> list;

  CustomerSuccess({
    required this.list,
  });
}

final class CustomerListFailed extends CustomerState {
  final String title, content;

  CustomerListFailed({required this.title, required this.content});
}

final class CustomerAddInitial extends CustomerState {}

final class CustomerAddLoading extends CustomerState {}

final class CustomerAddSuccess extends CustomerState {
  CustomerAddSuccess();
}



final class CustomerDeleteLoading extends CustomerState {}

final class CustomerDeleteSuccess extends CustomerState {
  CustomerDeleteSuccess();
}
final class CustomerAddFailed extends CustomerState {
  final String title, content;

  CustomerAddFailed({required this.title, required this.content});
}

final class CustomerSwitchInitial extends CustomerState {}

final class CustomerSwitchLoading extends CustomerState {}

final class CustomerSwitchSuccess extends CustomerState {
  CustomerSwitchSuccess();
}

final class CustomerSwitchFailed extends CustomerState {
  final String title, content;

  CustomerSwitchFailed({required this.title, required this.content});
}

sealed class CustomerDetailsState {}

final class CustomerDetailsInitial extends CustomerDetailsState {}

final class CustomerDetailsLoading extends CustomerDetailsState {}



final class CustomerDetailsFailed extends CustomerDetailsState {
  final String title, content;

  CustomerDetailsFailed({required this.title, required this.content});
}
