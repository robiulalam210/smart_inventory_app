class IncomeModel {
  final int? id;
  final String? invoiceNumber;
  final int? head;
  final String? headName;
  final String? amount;
  final int? account;
  final String? accountName;
  final String? incomeDate;
  final String? note;
  final int? createdBy;
  final String? createdByName;
  final String? dateCreated;
  final int? company;

  IncomeModel({
    this.id,
    this.invoiceNumber,
    this.head,
    this.headName,
    this.amount,
    this.account,
    this.accountName,
    this.incomeDate,
    this.note,
    this.createdBy,
    this.createdByName,
    this.dateCreated,
    this.company,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
    id: json['id'],
    invoiceNumber: json['invoice_number'],
    head: json['head'],
    headName: json['head_name'],
    amount: json['amount'].toString(),
    account: json['account'],
    accountName: json['account_name'],
    incomeDate: json['income_date'],
    note: json['note'],
    createdBy: json['created_by'],
    createdByName: json['created_by_name'],
    dateCreated: json['date_created'],
    company: json['company'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoice_number': invoiceNumber,
    'head': head,
    'amount': amount,
    'account': account,
    'income_date': incomeDate,
    'note': note,
    'created_by': createdBy,
    'date_created': dateCreated,
    'company': company,
  };
}