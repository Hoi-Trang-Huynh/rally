import 'dart:convert';

/// Model representing a draft Rally that hasn't been created yet.
///
/// This is used to persist partially filled Rally creation forms
/// so users can continue where they left off.
class RallyDraft {
  /// Creates a new [RallyDraft].
  const RallyDraft({
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.coverImagePath,
    this.invitedMembers = const <Map<String, String?>>[],
    required this.lastModified,
  });

  /// Rally name.
  final String? name;

  /// Rally description (as JSON from Quill editor).
  final String? description;

  /// Session start date.
  final DateTime? startDate;

  /// Session end date.
  final DateTime? endDate;

  /// Local path or URL of cover image.
  final String? coverImagePath;

  /// List of invited members with their data.
  /// Each member is stored as a map with keys: id, username, displayName, avatarUrl
  final List<Map<String, String?>> invitedMembers;

  /// When this draft was last modified.
  final DateTime lastModified;

  /// Creates an empty draft.
  factory RallyDraft.empty() => RallyDraft(lastModified: DateTime.now());

  /// Creates a draft from JSON.
  factory RallyDraft.fromJson(Map<String, dynamic> json) {
    return RallyDraft(
      name: json['name'] as String?,
      description: json['description'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      coverImagePath: json['coverImagePath'] as String?,
      invitedMembers:
          (json['invitedMembers'] as List<dynamic>?)
              ?.map((dynamic e) => Map<String, String?>.from(e as Map))
              .toList() ??
          <Map<String, String?>>[],
      lastModified:
          json['lastModified'] != null
              ? DateTime.parse(json['lastModified'] as String)
              : DateTime.now(),
    );
  }

  /// Converts this draft to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'coverImagePath': coverImagePath,
      'invitedMembers': invitedMembers,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Converts to JSON string.
  String toJsonString() => jsonEncode(toJson());

  /// Creates from JSON string.
  static RallyDraft? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
      return RallyDraft.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Whether this draft has any meaningful content.
  bool get hasContent =>
      (name != null && name!.isNotEmpty) ||
      (description != null && description!.isNotEmpty) ||
      startDate != null ||
      endDate != null ||
      coverImagePath != null ||
      invitedMembers.isNotEmpty;

  /// Creates a copy with updated fields.
  RallyDraft copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImagePath,
    List<Map<String, String?>>? invitedMembers,
    DateTime? lastModified,
  }) {
    return RallyDraft(
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      invitedMembers: invitedMembers ?? this.invitedMembers,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'RallyDraft(name: $name, hasContent: $hasContent)';
}
