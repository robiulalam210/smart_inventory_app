class GenderLocalModel {
  final int? id;
  final int? originalId;
  final String? name;

  GenderLocalModel({
     this.id,
    this.originalId,
     this.name,
  });

  @override
  String toString() {
    return name??"";
  }
  factory GenderLocalModel.fromMap(Map<String, dynamic> map) {
    return GenderLocalModel(
      id: map['id'],
      originalId: map['original_id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_id': originalId,
      'name': name,
    };
  }
}

class BloodGroupLocalModel {
  final int? id;
  final int? originalId;
  final String? name;

  BloodGroupLocalModel({
     this.id,
    this.originalId,
     this.name,
  });

  @override
  String toString() {
    return name??"";
  }
  factory BloodGroupLocalModel.fromMap(Map<String, dynamic> map) {
    return BloodGroupLocalModel(
      id: map['id'],
      originalId: map['original_id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_id': originalId,
      'name': name,
    };
  }
}