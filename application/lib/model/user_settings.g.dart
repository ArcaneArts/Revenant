// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map json) => $checkedCreate(
      'UserSettings',
      json,
      ($checkedConvert) {
        final val = UserSettings();
        $checkedConvert(
            'settings',
            (v) => val.settings = (v as Map?)?.map(
                  (k, e) => MapEntry(k as String, e),
                ));
        return val;
      },
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'settings': instance.settings,
    };
