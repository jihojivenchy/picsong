import 'dart:io';

import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// 이미지 선택 및 크롭 서비스
abstract class ImagePickCropService {
  ImagePickCropService._();

  /// 갤러리에서 이미지를 선택하고 크롭 후 반환
  static Future<File?> pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (selectedImage == null) {
      return null;
    }

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: selectedImage.path,
      uiSettings: [
        /// Android 크롭 설정
        AndroidUiSettings(
          toolbarTitle: '사진 편집',
          toolbarColor: AppColors.gray800,
          toolbarWidgetColor: AppColors.white,
          activeControlsWidgetColor: AppColors.primary,
          backgroundColor: AppColors.white,
          statusBarLight: false,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),

        /// iOS 크롭 설정
        IOSUiSettings(
          title: '사진 편집',
          doneButtonTitle: '완료',
          cancelButtonTitle: '취소',
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: true,
        ),
      ],
    );

    if (croppedFile == null) {
      return null;
    }

    return File(croppedFile.path);
  }
}
