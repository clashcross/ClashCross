

import '../../bean/clash_log_entity.dart';
import 'base/json_convert_content.dart';

ClashLogEntity $ClashLogEntityFromJson(Map<String, dynamic> json) {
  final ClashLogEntity clashLogEntity = ClashLogEntity();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    clashLogEntity.type = type;
  }
  final String? payload = jsonConvert.convert<String>(json['payload']);
  if (payload != null) {
    clashLogEntity.payload = payload;
  }
  return clashLogEntity;
}

Map<String, dynamic> $ClashLogEntityToJson(ClashLogEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['payload'] = entity.payload;
  return data;
}
