import 'package:cloud_functions/cloud_functions.dart';

class SummaryService {
  final FirebaseFunctions _functions;

  SummaryService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// 메시지 목록을 Claude API로 요약 (Cloud Functions 경유)
  Future<String> summarizeMessages(List<String> messages) async {
    final callable = _functions.httpsCallable('summarizeMessages');
    final result = await callable.call({'messages': messages});
    return result.data['summary'] as String;
  }

  /// 아카이브 항목에 태그 자동 추천
  Future<List<String>> suggestTags(String content) async {
    final callable = _functions.httpsCallable('suggestTags');
    final result = await callable.call({'content': content});
    return List<String>.from(result.data['tags'] as List);
  }
}
