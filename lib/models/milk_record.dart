class MilkRecord {
  final String id;
  final DateTime setorDate;
  final String farmerName;
  final double milkQuantity;
  final DateTime? createdAt;

  MilkRecord({
    required this.id,
    required this.setorDate,
    required this.farmerName,
    required this.milkQuantity,
    this.createdAt,
  });

  factory MilkRecord.fromJson(Map<String, dynamic> json) {
    return MilkRecord(
      id: json['id'],
      setorDate: DateTime.parse(json['setor_date']),
      farmerName: json['farmer_name'],
      milkQuantity: (json['milk_quantity'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setor_date': setorDate.toIso8601String().split('T').first,
      'farmer_name': farmerName,
      'milk_quantity': milkQuantity,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
