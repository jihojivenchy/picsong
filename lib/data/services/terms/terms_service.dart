import 'package:picsong/data/dio/dio_service.dart';
import 'package:picsong/domain/entities/terms/terms.dart';

/// 약관 서비스
class TermsService {
  final DioService _dioService = DioService();

  ///
  /// 약관 목록 조회
  ///
  Future<List<Terms>> fetchTermList() async {
    final response = await _dioService.get<Map<String, dynamic>>(
      path: 'term/list',
    );
    return (response['result']['list'] as List? ?? [])
        .map((e) => Terms.fromJson(e))
        .toList();
  }

  ///
  /// 약관 상세 조회
  ///
  Future<Terms> fetchTermsDetail({required TermAgreeType type}) async {
    final response = await _dioService.get<Map<String, dynamic>>(
      path: 'term/detail',
      parameters: {
        'type': type.queryValue,
      },
    );
    return Terms.fromJson(response['result']);
  }
}
