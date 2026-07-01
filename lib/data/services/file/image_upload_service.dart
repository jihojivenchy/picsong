import 'dart:async';
import 'dart:io';

import 'package:picsong/data/dio/dio_service.dart';
import 'package:picsong/data/dtos/file/upload_file_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

/// 이미지 업로드 서비스
class ImageUploadService {
  final DioService _dioService = DioService();

  ///
  /// 지원하는 이미지 확장자
  ///
  static const Set<String> supportedImageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
  };

  static const Set<String> supportedVideoExtensions = {
    '.mp4',
    '.mov',
  };

  ///
  /// 이미지 리스트 업로드
  ///
  Future<List<UploadFileResponseDTO>> uploadMultipleImages({
    required List<File> imageFileList,
  }) async {
    final responseList = await Future.wait(
      imageFileList.map(
        (file) async {
          return await uploadImageFromFile(imageFile: file);
        },
      ),
    );

    return responseList;
  }

  ///
  /// 이미지 업로드
  ///
  Future<UploadFileResponseDTO> uploadImageFromFile({
    required File imageFile,
  }) async {
    // 1. 파일 유효성 체크
    _validateImageFile(imageFile.path);

    // 2. MIME 타입 결정
    final mediaType = _getMediaType(imageFile.path);

    // 3. 파일 생성
    final multipartFile = await MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.path.split('/').last,
      contentType: mediaType,
    );

    // 4. FormData 생성
    final formData = FormData.fromMap({
      'imageFile': multipartFile,
    });

    // 5. 요청
    final response = await _dioService.post(
      path: 'file/image',
      data: formData,
      tokenType: TokenType.access,
    );

    // 6. 응답 처리
    final responseDTO = UploadFileResponseDTO.fromJson(response);
    return responseDTO;
  }

  ///
  /// 파일 유효성 체크
  ///
  void _validateImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    if (!supportedImageExtensions.contains(extension)) {
      throw UnsupportedError('지원하지 않는 파일 형식입니다: $extension\n'
          '지원 형식: ${supportedImageExtensions.join(', ')}');
    }
  }

  ///
  /// 비디오 업로드
  ///
  Future<UploadFileResponseDTO> uploadVideoFromFile({
    required File videoFile,
  }) async {
    // 1. 파일 유효성 체크
    // _validateVideoFile(videoFile.path);

    // 2. MIME 타입 결정
    final mediaType = _getMediaType(videoFile.path);

    // 3. 파일 생성
    final multipartFile = await MultipartFile.fromFile(
      videoFile.path,
      filename: videoFile.path.split('/').last,
      contentType: mediaType,
    );

    // 4. FormData 생성
    final formData = FormData.fromMap({
      'videoFile': multipartFile,
    });

    // 5. 요청
    final response = await _dioService.post(
      path: 'user-file/video',
      data: formData,
      tokenType: TokenType.access,
    );

    // 6. 응답 처리
    final responseDTO = UploadFileResponseDTO.fromJson(response);
    return responseDTO;
  }

  ///
  /// 파일 유효성 체크
  ///
  void _validateVideoFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    if (!supportedVideoExtensions.contains(extension)) {
      throw UnsupportedError('지원하지 않는 파일 형식입니다: $extension\n'
          '지원 형식: ${supportedVideoExtensions.join(', ')}');
    }
  }

  ///
  /// MIME 타입 결정
  ///
  MediaType _getMediaType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      // 이미지 타입
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      case '.bmp':
        return MediaType('image', 'bmp');
      case '.pdf':
        return MediaType('application', 'pdf');

      // 비디오 타입
      case '.mp4':
        return MediaType('video', 'mp4');
      case '.mov':
        return MediaType('video', 'quicktime');
      case '.avi':
        return MediaType('video', 'x-msvideo');
      case '.mkv':
        return MediaType('video', 'x-matroska');
      case '.flv':
        return MediaType('video', 'x-flv');
      case '.wmv':
        return MediaType('video', 'x-ms-wmv');
      case '.webm':
        return MediaType('video', 'webm');
      case '.m4v':
        return MediaType('video', 'x-m4v');

      default:
        return MediaType('application', 'octet-stream'); // 기타 확장자 처리
    }
  }
}
