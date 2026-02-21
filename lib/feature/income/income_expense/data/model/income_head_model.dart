class IncomeHeadModel {
  final int? id;
  final String? name;
  final int? company;
  final int? createdBy;
  final DateTime? dateCreated;
  final bool? isActive;

  IncomeHeadModel({
     this.id,
    this.name,
    this.company,
    this.createdBy,
    this.dateCreated,
    this.isActive,
  });

  @override
  String toString() {
    // TODO: implement toString
    return name??'';
  }

  factory IncomeHeadModel.fromJson(Map<String, dynamic> json) {
    return IncomeHeadModel(
      id: json['id'] ,
      name: json['name'] ,
      company: json['company'] ,
      createdBy: json['created_by'] ,
      dateCreated: json['date_created'] != null
          ? DateTime.parse(json['date_created'])
          : null,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'created_by': createdBy,
      'date_created': dateCreated?.toIso8601String(),
      'is_active': isActive,
    };
  }
}