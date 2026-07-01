///
/// 파일(이미지, 비디오) 업로드 응답 DTO
///
class UploadFileResponseDTO {
  final int id;
  final String fileName;
  final String fileURL;

  UploadFileResponseDTO({
    required this.id,
    required this.fileName,
    required this.fileURL,
  });

  factory UploadFileResponseDTO.fromJson(Map<String, dynamic> json) {
    final result = json['result'];

    return UploadFileResponseDTO(
      id: (result['id'] as num?)?.toInt() ?? 0,
      fileName: result['originalName'] as String,
      fileURL: result['url'] as String,
    );
  }
}
