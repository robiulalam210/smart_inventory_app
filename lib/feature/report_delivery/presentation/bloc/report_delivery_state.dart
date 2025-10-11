part of 'report_delivery_bloc.dart';

abstract class ReportDeliveryState extends Equatable {
  const ReportDeliveryState();

  @override
  List<Object?> get props => [];
}

class ReportDeliveryInitial extends ReportDeliveryState {}

class ReportDeliveryLoading extends ReportDeliveryState {}

class ReportDeliverySuccess extends ReportDeliveryState {
  final String message;
  const ReportDeliverySuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportDeliveryFailure extends ReportDeliveryState {
  final String error;
  const ReportDeliveryFailure(this.error);

  @override
  List<Object?> get props => [error];
}