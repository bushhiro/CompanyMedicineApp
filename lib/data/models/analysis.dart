class AnalysisOrderResponse {
  final int id;
  final String orderNumber;
  final int totalAmount;
  final List<AnalysisOrderItemResponse> orderItems;

  AnalysisOrderResponse({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderItems,
  });

  factory AnalysisOrderResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisOrderResponse(
      id: json['id'],
      orderNumber: json['order_number'],
      totalAmount: json['total_amount'],
      orderItems: (json['order_items'] as List)
          .map((e) => AnalysisOrderItemResponse.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'total_amount': totalAmount,
    'order_items': orderItems.map((e) => e.toJson()).toList(),
  };
}

class AnalysisOrderItemResponse {
  final int id;
  final int analysisId;
  final AnalysisResponse analysis;
  final bool isCompleted;

  AnalysisOrderItemResponse({
    required this.id,
    required this.analysisId,
    required this.analysis,
    required this.isCompleted,
  });

  factory AnalysisOrderItemResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisOrderItemResponse(
      id: json['id'],
      analysisId: json['analysis_id'],
      analysis: AnalysisResponse.fromJson(json['analysis']),
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'analysis_id': analysisId,
    'analysis': analysis.toJson(),
    'is_completed': isCompleted,
  };
}

class AnalysisResponse {
  final int id;
  final String code;
  final String title;
  final int price;

  AnalysisResponse({
    required this.id,
    required this.code,
    required this.title,
    required this.price,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'price': price,
  };
}