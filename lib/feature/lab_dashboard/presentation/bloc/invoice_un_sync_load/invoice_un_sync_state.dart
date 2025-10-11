part of 'invoice_un_sync_bloc.dart';

sealed class InvoiceUnSyncState {}

final class InvoiceSyncInitial extends InvoiceUnSyncState {}

class InvoiceUnSyncLoading extends InvoiceUnSyncState {}
class InvoiceUnSyncEmpty extends InvoiceUnSyncState {}

class InvoiceUnSyncLoaded extends InvoiceUnSyncState {
  final List<Map<String, dynamic>>? invoices; // ✅ Holds unsynced invoices
bool isSingleSync;  
  InvoiceUnSyncLoaded(this.invoices, {this.isSingleSync = false});

  InvoiceUnSyncLoaded copyWith({
    List<Map<String, dynamic>>? invoices, // ✅ Holds unsynced invoices
    bool? isSingleSync,
  }) {
    return InvoiceUnSyncLoaded(
      invoices ?? this.invoices,
      isSingleSync: isSingleSync ?? this.isSingleSync,
    );
  }
}

class InvoiceSyncError extends InvoiceUnSyncState {
  final String error;

  InvoiceSyncError(this.error);

  List<Object?> get props => [error];
}

class PostInvoiceUnSyncLoading extends InvoiceUnSyncState {}

class PostInvoiceUnSyncLoaded extends InvoiceUnSyncState {
  final InvoiceServerSyncResponseModel invoices;

  bool isCreate;
  bool isSingleSync;
  PostInvoiceUnSyncLoaded(this.invoices,this.isCreate,{this.isSingleSync=false});

}

class PostInvoiceSyncError extends InvoiceUnSyncState {
  final String error;

  PostInvoiceSyncError(this.error);

  List<Object?> get props => [error];
}
