class SettingsModel {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String language;

  SettingsModel({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkModeEnabled: map['darkModeEnabled'] ?? false,
      language: map['language'] ?? 'English',
    );
  }

  SettingsModel copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? language,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
    );
  }
}