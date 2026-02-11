/// Role of a participant in a rally.
enum ParticipantRole {
  /// Creator and admin of the rally.
  owner,

  /// Can edit rally details and spots.
  editor,

  /// Can only view and experience the rally.
  participant;

  /// Creates a [ParticipantRole] from a string.
  static ParticipantRole fromString(String value) {
    return ParticipantRole.values.firstWhere(
      (ParticipantRole e) => e.name == value,
      orElse: () => ParticipantRole.participant,
    );
  }
}

/// Status of a participant in a rally.
enum ParticipationStatus {
  /// User has been invited but not yet responded.
  invited,

  /// User has accepted and joined the rally.
  joined,

  /// User has declined the invitation.
  declined,

  /// User has left the rally.
  left;

  /// Creates a [ParticipationStatus] from a string.
  static ParticipationStatus fromString(String value) {
    return ParticipationStatus.values.firstWhere(
      (ParticipationStatus e) => e.name == value,
      orElse: () => ParticipationStatus.invited,
    );
  }
}

/// Status of a rally.
enum RallyStatus {
  /// Rally is currently being planned.
  draft,

  /// Rally is currently active.
  active,

  /// Rally is currently inactive.
  inactive,

  /// Rally has been completed.
  completed,

  /// Rally has been archived.
  archived;

  /// Creates a [RallyStatus] from a string.
  static RallyStatus fromString(String value) {
    return RallyStatus.values.firstWhere(
      (RallyStatus e) => e.name == value,
      orElse: () => RallyStatus.draft,
    );
  }
}
