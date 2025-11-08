class ManualItem {
  final int id;
  final String type;
  final String value;

  ManualItem({
    required this.id,
    required this.type,
    required this.value,
  });

  factory ManualItem.fromJson(Map<String, dynamic> json) {
    return ManualItem(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'value': value,
    };
  }
}