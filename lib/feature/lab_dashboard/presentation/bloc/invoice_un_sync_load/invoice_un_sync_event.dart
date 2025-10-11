part of 'invoice_un_sync_bloc.dart';

sealed class InvoiceUnSyncEvent {}

class LoadUnSyncInvoice extends InvoiceUnSyncEvent {
    bool isSingleSync;
  LoadUnSyncInvoice({this.isSingleSync = false});
}
class PostUnSyncInvoice extends InvoiceUnSyncEvent {
  List<Map<String, dynamic>> body;
  bool invoiceCreate;
  bool isSingleSync;

  PostUnSyncInvoice({required this.body,required this.invoiceCreate, required this.isSingleSync});
}
