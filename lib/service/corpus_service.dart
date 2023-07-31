import 'package:get/get.dart';

import '../bean/corpus.dart';
import '../http/request.dart';

class CorpusService extends GetxService {
  late List<Corpus> corpusList = [];

  Future<CorpusService> init() async {
    loadCorpusList();
    return this;
  }

  Future loadCorpusList() async {
    List<dynamic> res = await HttpUtils.get(
        path: 'corpus', showLoading: false, showErrorMessage: false);
    if (res.isNotEmpty) {
      for (var element in res) {
        corpusList.add(Corpus.fromJson(element));
      }
    }
  }
}
