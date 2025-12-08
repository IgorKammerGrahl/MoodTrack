class ActivityCorrelation {
  final String keyword;
  final String displayName;
  final String emoji;
  final int occurrences;
  final double averageMood;
  final double impactPercentage;

  ActivityCorrelation({
    required this.keyword,
    required this.displayName,
    required this.emoji,
    required this.occurrences,
    required this.averageMood,
    required this.impactPercentage,
  });

  bool get isPositive => impactPercentage > 0;
  bool get isNegative => impactPercentage < 0;
  bool get isNeutral => impactPercentage == 0;
}
