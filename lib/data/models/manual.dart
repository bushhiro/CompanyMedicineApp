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

// class ManualResponse {
//   final int id;
//   final String type;
//   final String value;
//
//   ManualResponse({
//     required this.id,
//     required this.type,
//     required this.value,
//   });
//
//   factory ManualResponse.fromJson(Map<String, dynamic> json) {
//     return ManualResponse(
//       id: json['id'] as int,
//       type: json['type'] as String,
//       value: json['value'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'type': type,
//       'value': value,
//     };
//   }
// }