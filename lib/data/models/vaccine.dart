class VaccineAllResponse {
  final int id;
  final DateTime date;
  final String type;
  final String title;

  VaccineAllResponse({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
  });

  factory VaccineAllResponse.fromJson(Map<String, dynamic> json) {
    return VaccineAllResponse(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      title: json['title'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'title': title,
    };
  }
}