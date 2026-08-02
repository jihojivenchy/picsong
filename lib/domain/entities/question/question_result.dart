import 'package:picsong/domain/entities/question/question.dart';

/// 문제 하나를 푼 결과 — 출제 정보와 정오 여부.
class QuestionResult {
  /// 출제된 문제
  final Question question;

  /// 정답을 맞혔는지 여부 (false면 답안 공개)
  final bool isCorrect;

  const QuestionResult({
    required this.question,
    required this.isCorrect,
  });
}
