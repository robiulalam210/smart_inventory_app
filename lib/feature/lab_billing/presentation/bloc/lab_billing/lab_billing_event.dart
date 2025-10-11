part of 'lab_billing_bloc.dart';

abstract class LabBillingEvent extends Equatable {
  const LabBillingEvent();

  @override
  List<Object?> get props => [];
}

class AddTestItem extends LabBillingEvent {
  final String id;
  final String name;
  final String? testGroupName;
  final String code;
  final String type;
  final double price;
  final int quantity;
  final int discountApplied;
  final double discountPercentage ;

  const AddTestItem({
    required this.id,
    required this.name,
    required this.testGroupName,
    required this.code,
    required this.type,
    required this.price,
    required this.discountPercentage,
    this.quantity = 1,
    this.discountApplied = 0,
  });
}

class RemoveTestItem extends LabBillingEvent {
  final int index;

  const RemoveTestItem(this.index);
}

class UpdateTestItemQty extends LabBillingEvent {
  final int index;
  final int qty;

  const UpdateTestItemQty({required this.index, required this.qty});

  @override
  List<Object?> get props => [index,qty];
}


// ignore: must_be_immutable
class LoadInvoiceDetails extends LabBillingEvent {
  final String invoiceId;
  bool isSyncing = false;
  BuildContext context;
  LoadInvoiceDetails(this.invoiceId, {this.isSyncing = false, required this.context});    

  @override
  List<Object?> get props => [invoiceId];
}



class ClearFormData extends LabBillingEvent {}

class SaveInvoice extends LabBillingEvent {
  final BuildContext context;
  final bool isUpdate;
  final String? patientID;
  final String? patientWebId;

  const SaveInvoice({
    required this.context,
    required this.isUpdate,
    this.patientID,
    this.patientWebId,
  });
}

