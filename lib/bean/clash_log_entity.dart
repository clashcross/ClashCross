import 'dart:convert';

import '../generated/json/base/json_field.dart';
import '../generated/json/clash_log_entity.g.dart';



@JsonSerializable()
class ClashLogEntity {
  String? type;
  String? payload;

  ClashLogEntity();

  factory ClashLogEntity.fromJson(Map<String, dynamic> json) =>
      $ClashLogEntityFromJson(json);

  Map<String, dynamic> toJson() => $ClashLogEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
