class Manual {
  final int id;
  final String type;
  final String value;

  Manual({
    required this.id,
    required this.type,
    required this.value,
  });

  factory Manual.fromJson(Map<String, dynamic> json) {
    return Manual(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

