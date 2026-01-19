

class AccountTransferModel {
  final int? id;
  final String? transferNo;
  final String? fromAccountId;
  final String? toAccountId;
  final AccountModel? fromAccount;
  final AccountModel? toAccount;
  final String? amount;
  final String? description;
  final String? transferType;
  final dynamic? status;
  final DateTime? transferDate;
  final DateTime? createdAt;
  final String? createdByName;
  final String? approvedByName;
  final String? referenceNo;
  final String? remarks;
  final bool? isReversal;
  final String? debitTransaction;
  final String? creditTransaction;

  AccountTransferModel({
    this.id,
    this.transferNo,
    this.fromAccountId,
    this.toAccountId,
    this.fromAccount,
    this.toAccount,
    this.amount,
    this.description,
    this.transferType,
    this.status,
    this.transferDate,
    this.createdAt,
    this.createdByName,
    this.approvedByName,
    this.referenceNo,
    this.remarks,
    this.isReversal,
    this.debitTransaction,
    this.creditTransaction,
  });

  factory AccountTransferModel.fromJson(Map<String, dynamic> json) {
    return AccountTransferModel(
      id: json['id'],
      transferNo: json['transfer_no'],
      fromAccountId: json['from_account_id']?.toString(),
      toAccountId: json['to_account_id']?.toString(),
      fromAccount: json['from_account'] != null
          ? AccountModel.fromJson(json['from_account'])
          : null,
      toAccount: json['to_account'] != null
          ? AccountModel.fromJson(json['to_account'])
          : null,
      amount: json['amount']?.toString(),
      description: json['description'],
      transferType: json['transfer_type'],
      status: json['status'],
      transferDate: json['transfer_date'] != null
          ? DateTime.tryParse(json['transfer_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      createdByName: json['created_by_name'],
      approvedByName: json['approved_by_name'],
      referenceNo: json['reference_no'],
      remarks: json['remarks'],
      isReversal: json['is_reversal'],
      debitTransaction: json['debit_transaction']?.toString(),
      creditTransaction: json['credit_transaction']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'amount': amount,
      'description': description,
      'transfer_type': transferType ?? 'internal',
      'reference_no': referenceNo,
      'remarks': remarks,
    };
  }

  @override
  String toString() {
    return 'Transfer $transferNo: ${fromAccount?.name} → ${toAccount?.name} - $amount';
  }
}

class AccountModel {
  final int? id;
  final String? name;
  final String? acType;
  final String? acNo;
  final String? balance;
  final bool? isActive;

  AccountModel({
    this.id,
    this.name,
    this.acType,
    this.acNo,
    this.balance,
    this.isActive,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      name: json['name'],
      acType: json['ac_type'],
      acNo: json['ac_no'],
      balance: json['balance']?.toString(),
      isActive: json['is_active'],
    );
  }

  @override
  String toString() {
    return '${name ?? "Unknown"}${acNo != null && acNo!.isNotEmpty ? ' - $acNo' : ''}';
  }
}