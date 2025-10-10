class FlgResponse {
  final int id;
  final bool isCompleted;
  final String organization;
  final String number;
  final String result;

  FlgResponse({
    required this.id,
    required this.isCompleted,
    required this.organization,
    required this.number,
    required this.result,
  });

  factory FlgResponse.fromJson(Map<String, dynamic> json) {
    return FlgResponse(
      id: json['id'] as int,
      isCompleted: json['is_completed'] as bool,
      organization: json['organization'] as String,
      number: json['number'] as String,
      result: json['result'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_completed': isCompleted,
      'organization': organization,
      'number': number,
      'result': result,
    };
  }
}