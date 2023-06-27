import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_compress/json_compress.dart';

part 'user.g.dart';

@JsonSerializable()
class User with EquatableMixin {
  @JsonKey(ignore: true)
  String? uid;
  String? firstName;
  String? lastName;
  String? email;
  bool? registered;

  User();

  @override
  List<Object?> get props => [
        uid,
        firstName,
        lastName,
        email,
        registered,
      ];

  String fullName() => "${firstName ?? "Unknown User"} ${lastName ?? ""}";

  String first() => (firstName ?? "Unknown User");

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(decompressJson(json));

  Map<String, dynamic> toJson() => compressJson(_$UserToJson(this),
      forceEncode: true, retainer: (k, v) => k == "email");
}
