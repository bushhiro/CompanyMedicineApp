class FilterResponse<T> {
  final List<T> hits;
  final int currentPage;
  final int totalPages;
  final int totalHits;
  final int hitsPerPage;

  FilterResponse({
    required this.hits,
    required this.currentPage,
    required this.totalPages,
    required this.totalHits,
    required this.hitsPerPage,
  });

  factory FilterResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return FilterResponse<T>(
      hits: (json['hits'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalHits: json['totalHits'],
      hitsPerPage: json['hitsPerPage'],
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'hits': hits.map((e) => toJsonT(e)).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalHits': totalHits,
      'hitsPerPage': hitsPerPage,
    };
  }
}