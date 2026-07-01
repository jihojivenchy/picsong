/// 목록 정렬 조건 (API 쿼리 파라미터용)
enum SortOption {
  oldest(displayText: '오래된순', queryValue: 'OLDEST'),
  latest(displayText: '최신순', queryValue: 'LATEST');

  final String displayText;
  final String queryValue;

  const SortOption({required this.displayText, required this.queryValue});

  factory SortOption.fromQueryValue(String? value) {
    if (value == null) return SortOption.latest;
    return SortOption.values.firstWhere(
      (e) => e.queryValue == value,
      orElse: () => SortOption.latest,
    );
  }
}
