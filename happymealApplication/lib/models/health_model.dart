class Health {
  final DateTime createdAt;
  final String height;
  final String weight;
  final String wrist;
  final double bmi;
  final String userId;
  final bool isDelete;

  Health({
    required this.createdAt,
    required this.height,
    required this.weight,
    required this.wrist,
    required this.bmi,
    required this.userId,
    this.isDelete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'height': height,
      'weight': weight,
      'wrist': wrist,
      'bmi': bmi,
      'userId': userId,
      'isDelete': isDelete,
    };
  }

  factory Health.fromSnapshot(Map<String, dynamic> map) {
    return Health(
      createdAt: DateTime.parse(map['createdAt']),
      height: map['height'] ?? '',
      weight: map['weight'] ?? '',
      wrist: map['wrist'] ?? '',
      bmi: (map['bmi'] as num?)?.toDouble() ?? 0.0,
      userId: map['userId'] ?? '',
      isDelete: map['isDelete'] ?? false,
    );
  }
}