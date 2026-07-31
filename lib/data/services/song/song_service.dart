import 'dart:convert';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/song/song.dart';

/// 곡 데이터 서비스 — 번들 자산의 songs.json을 읽어 곡 목록을 제공
class SongService {
  /// 곡 데이터 자산 경로
  static const String _assetPath = 'assets/data/songs.json';

  ///
  /// 전체 곡 목록 조회
  ///
  Future<List<Song>> fetchSongList() async =>
      _parseSongList(await _loadSource());

  ///
  /// 곡 데이터 자산을 문자열로 읽는다
  ///
  Future<String> _loadSource() async {
    try {
      return await rootBundle.loadString(_assetPath);
    } on FlutterError {
      throw SongDataException('곡 데이터를 찾을 수 없습니다 ($_assetPath)');
    }
  }

  ///
  /// JSON 문자열을 곡 목록으로 변환 (순수)
  ///
  List<Song> _parseSongList(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! List<Object?>) {
      throw SongDataException('곡 데이터 형식이 올바르지 않습니다');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .toList();
  }

  ///
  /// 해당 시대의 곡 목록 조회
  ///
  Future<List<Song>> fetchSongListOf(Era era) async {
    final List<Song> songList = await fetchSongList();
    return songList.where((Song song) => song.era == era).toList();
  }
}
