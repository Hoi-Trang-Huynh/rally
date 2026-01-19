/// Enum representing feedback categories.
///
/// Maps to backend enum values for feedback categorization.
enum FeedbackCategory {
  /// UI/UX related feedback.
  uiUx('ui'),

  /// Bug report.
  bug('bug'),

  /// Feature request.
  feature('feature'),

  /// Performance related feedback.
  performance('performance'),

  /// Other/miscellaneous feedback.
  other('other');

  /// The API value for this category.
  final String value;

  /// Creates a [FeedbackCategory] with the given API value.
  const FeedbackCategory(this.value);

  /// Gets all category values as a list of strings.
  static List<String> toValueList(List<FeedbackCategory> categories) {
    return categories.map((FeedbackCategory c) => c.value).toList();
  }
}
