import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User with EquatableMixin {
  @JsonKey(ignore: true)
  String? uid;
  String? firstName;
  String? lastName;
  String? emailAddress;

  User();

  @override
  List<Object?> get props => [
        uid,
        firstName,
        lastName,
        emailAddress,
      ];

  String fullName() => "${firstName ?? "Unknown User"} ${lastName ?? ""}";

  String first() => (firstName ?? "Unknown User");

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
