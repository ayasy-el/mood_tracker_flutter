import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String? avatar;
  final DateTime joinDate;
  final int streakDays;
  final UserPreferences preferences;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatar,
    required this.joinDate,
    required this.streakDays,
    required this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      joinDate: DateTime.parse(json['joinDate'] as String),
      streakDays: json['streakDays'] as int,
      preferences:
          UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'joinDate': joinDate.toIso8601String(),
      'streakDays': streakDays,
      'preferences': preferences.toJson(),
    };
  }

  @override
  List<Object?> get props =>
      [id, name, avatar, joinDate, streakDays, preferences];

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatar,
    DateTime? joinDate,
    int? streakDays,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      joinDate: joinDate ?? this.joinDate,
      streakDays: streakDays ?? this.streakDays,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences extends Equatable {
  final bool darkMode;
  final bool privateJournal;
  final String? reminderTime;

  const UserPreferences({
    required this.darkMode,
    required this.privateJournal,
    this.reminderTime,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] as bool,
      privateJournal: json['privateJournal'] as bool,
      reminderTime: json['reminderTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'privateJournal': privateJournal,
      'reminderTime': reminderTime,
    };
  }

  @override
  List<Object?> get props => [darkMode, privateJournal, reminderTime];

  UserPreferences copyWith({
    bool? darkMode,
    bool? privateJournal,
    String? reminderTime,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      privateJournal: privateJournal ?? this.privateJournal,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
