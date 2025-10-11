part of 'synchronization_bloc.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object> get props => [];
}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {
  final SyncType? type;
  final int progress;
  final int total;
  final String currentOperation;
  final double percentage;

  const SyncInProgress({
    this.type,
    this.progress = 0,
    this.total = 1,
    this.currentOperation = '',
  }) : percentage = total > 0 ? (progress / total) * 100 : 0;

  @override
  List<Object> get props =>
      [type ?? '', progress, total, currentOperation, percentage];
}

class SyncSuccess extends SyncState {
  final SyncType? type;
  final String message;

  const SyncSuccess({this.type, this.message = 'Sync completed successfully'});

  @override
  List<Object> get props => [type ?? '', message];
}

// class AutoSyncSuccess extends SyncState {
//   final SyncType? type;
//   final String message;

//   const AutoSyncSuccess({this.type, this.message = 'Sync completed successfully'});

//   @override
//   List<Object> get props => [type ?? '', message];
// }

class SyncFailure extends SyncState {
  final SyncType? type;
  final String error;
  final String failedOperation;

  const SyncFailure({
    this.type,
    required this.error,
    this.failedOperation = '',
  });

  @override
  List<Object> get props => [type ?? '', error, failedOperation];
}

class SyncServerLoading extends SyncState {}

class SyncServerSuccess extends SyncState {
  final String invoiceId;
  final String message;
  final bool isSingleSync;

  const SyncServerSuccess(this.message, this.invoiceId,
      {this.isSingleSync = false});
}

class SyncServerFailure extends SyncState {
  final String error;

  const SyncServerFailure(this.error);
}

class FullRefundServerInvoiceLoading extends SyncState {}

class FullRefundServerInvoiceSuccess extends SyncState {
  final String invoiceId;
  final String message;

  const FullRefundServerInvoiceSuccess(this.message, this.invoiceId);
}

class FullRefundServerInvoiceFailure extends SyncState {
  final String error;

  const FullRefundServerInvoiceFailure(this.error);
}
