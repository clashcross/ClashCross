

import '../../bean/clash_config_entity.dart';
import 'base/json_convert_content.dart';

ClashConfigEntity $ClashConfigEntityFromJson(Map<String, dynamic> json) {
  final ClashConfigEntity clashConfigEntity = ClashConfigEntity();
  final int? port = jsonConvert.convert<int>(json['port']);
  if (port != null) {
    clashConfigEntity.port = port;
  }
  final int? socksPort = jsonConvert.convert<int>(json['socks-port']);
  if (socksPort != null) {
    clashConfigEntity.socksPort = socksPort;
  }
  final int? redirPort = jsonConvert.convert<int>(json['redir-port']);
  if (redirPort != null) {
    clashConfigEntity.redirPort = redirPort;
  }
  final int? tproxyPort = jsonConvert.convert<int>(json['tproxy-port']);
  if (tproxyPort != null) {
    clashConfigEntity.tproxyPort = tproxyPort;
  }
  final int? mixedPort = jsonConvert.convert<int>(json['mixed-port']);
  if (mixedPort != null) {
    clashConfigEntity.mixedPort = mixedPort;
  }
  final List<dynamic>? authentication =
      jsonConvert.convertListNotNull<dynamic>(json['authentication']);
  if (authentication != null) {
    clashConfigEntity.authentication = authentication;
  }
  final bool? allowLan = jsonConvert.convert<bool>(json['allow-lan']);
  if (allowLan != null) {
    clashConfigEntity.allowLan = allowLan;
  }
  final String? bindAddress = jsonConvert.convert<String>(json['bind-address']);
  if (bindAddress != null) {
    clashConfigEntity.bindAddress = bindAddress;
  }
  final String? mode = jsonConvert.convert<String>(json['mode']);
  if (mode != null) {
    clashConfigEntity.mode = mode;
  }
  final String? logLevel = jsonConvert.convert<String>(json['log-level']);
  if (logLevel != null) {
    clashConfigEntity.logLevel = logLevel;
  }
  final bool? ipv6 = jsonConvert.convert<bool>(json['ipv6']);
  if (ipv6 != null) {
    clashConfigEntity.ipv6 = ipv6;
  }
  return clashConfigEntity;
}

Map<String, dynamic> $ClashConfigEntityToJson(ClashConfigEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['port'] = entity.port;
  data['socks-port'] = entity.socksPort;
  data['redir-port'] = entity.redirPort;
  data['tproxy-port'] = entity.tproxyPort;
  data['mixed-port'] = entity.mixedPort;
  data['authentication'] = entity.authentication;
  data['allow-lan'] = entity.allowLan;
  data['bind-address'] = entity.bindAddress;
  data['mode'] = entity.mode;
  data['log-level'] = entity.logLevel;
  data['ipv6'] = entity.ipv6;
  return data;
}
