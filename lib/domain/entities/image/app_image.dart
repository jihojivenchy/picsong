/// 이미지 공통 모델
class AppImage {
  final int? id;
  final String imageURL;
  final int width;
  final int height;

  const AppImage({
    required this.id,
    required this.imageURL,
    required this.width,
    required this.height,
  });

  factory AppImage.fromJson(Map<String, dynamic> json) {
    return AppImage(
      id: json['fileId'],
      imageURL: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}
