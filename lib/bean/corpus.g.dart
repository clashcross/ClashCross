// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corpus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Corpus _$CorpusFromJson(Map<String, dynamic> json) => Corpus(
      json['id'] as int,
      json['siteurl'] as String,
      json['sitename'] as String,
      json['dec'] as String?,
      json['is_recommend'] as int?,
      json['views'] as int?,
      json['created_at'] as int,
      json['updated_at'] as int,
    );

Map<String, dynamic> _$CorpusToJson(Corpus instance) => <String, dynamic>{
      'id': instance.id,
      'siteurl': instance.siteurl,
      'sitename': instance.sitename,
      'dec': instance.dec,
      'is_recommend': instance.is_recommend,
      'views': instance.views,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };
