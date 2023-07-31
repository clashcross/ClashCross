import 'package:json_annotation/json_annotation.dart';

part 'corpus.g.dart';

@JsonSerializable()
class Corpus {
  // id
  // siteurl
  // sitename
  // dec
  // is_recommend
  // views
  // created_at
  // updated_at

  final int id;
  final String siteurl;
  final String sitename;
  String? dec;
  int? is_recommend;
  int? views;
  final int created_at;
  final int updated_at;

  Corpus(this.id, this.siteurl, this.sitename, this.dec, this.is_recommend,
      this.views, this.created_at, this.updated_at);

  factory Corpus.fromJson(Map<String, dynamic> json) => _$CorpusFromJson(json);

  Map<String, dynamic> toJson() => _$CorpusToJson(this);
}
