
import 'dart:convert';

import '../generated/json/clash_config_entity.g.dart';
import '../generated/json/base/json_field.dart';

@JsonSerializable()
class ClashConfigEntity {
  int? port;
  @JSONField(name: "socks-port")
  int? socksPort;
  @JSONField(name: "redir-port")
  int? redirPort;
  @JSONField(name: "tproxy-port")
  int? tproxyPort;
  @JSONField(name: "mixed-port")
  int? mixedPort;
  List<dynamic>? authentication;
  @JSONField(name: "allow-lan")
  bool? allowLan;
  @JSONField(name: "bind-address")
  String? bindAddress;
  String? mode;
  @JSONField(name: "log-level")
  String? logLevel;
  bool? ipv6;

  ClashConfigEntity();

  factory ClashConfigEntity.fromJson(Map<String, dynamic> json) =>
      $ClashConfigEntityFromJson(json);

  Map<String, dynamic> toJson() => $ClashConfigEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
