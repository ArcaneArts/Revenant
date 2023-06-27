import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_compress/json_compress.dart';

part 'user_settings.g.dart';

@JsonSerializable()
class UserSettings with EquatableMixin {
  @JsonKey(ignore: true)
  String? uid;
  Map<String, dynamic>? settings;

  UserSettings();

  @override
  List<Object?> get props => [uid, settings];

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(decompressJson(json));

  Map<String, dynamic> toJson() =>
      compressJson(_$UserSettingsToJson(this), forceEncode: true);
}
