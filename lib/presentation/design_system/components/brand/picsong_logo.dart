import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_fonts.dart';

/// 픽송 워드마크 로고.
/// Pretendard 700 모노톤 본체 + "i"의 점을 코랄 이미지-타일로 대체한
/// 단일 포인트 액센트. 모든 치수는 em(=fontSize) 비율이라 크기에 비례한다.
/// 클리어스페이스(글자 높이 0.5×)는 호출처에서 여백으로 확보한다.
class PicSongLogo extends StatelessWidget {
  /// 본체 글자 크기 (DS 기본 34, 최소 18)
  final double fontSize;

  /// 코랄 배경 위 역상 — 본체·점 모두 흰색
  final bool reversed;

  /// "i" 코랄 점의 스케일 — 스플래시 bloom 연출용 (기본 1.0, 0이면 숨김)
  final double dotScale;

  const PicSongLogo({
    super.key,
    this.fontSize = 34,
    this.reversed = false,
    this.dotScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color bodyColor = reversed ? AppColors.neutral0 : AppColors.textStrong;
    final Color dotColor = reversed ? AppColors.neutral0 : AppColors.primary;
    final TextStyle wordStyle = TextStyle(
      fontFamily: AppFonts.pretendard,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: fontSize * -0.035,
      height: 1,
      color: bodyColor,
    );
    return Text.rich(
      TextSpan(
        style: wordStyle,
        children: <InlineSpan>[
          const TextSpan(text: 'P'),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _buildDottedI(bodyColor, dotColor),
          ),
          const TextSpan(text: 'cSong'),
        ],
      ),
    );
  }

  ///
  /// "i" 글리프를 획(stem) + 코랄 점(dot)으로 직접 조립한다.
  ///
  Widget _buildDottedI(Color stemColor, Color dotColor) {
    final double stemWidth = fontSize * 0.155;
    final double stemHeight = fontSize * 0.52;
    final double dotSize = fontSize * 0.2;
    final double dotBottom = fontSize * 0.57;
    final double cornerRadius = fontSize * 0.045;
    return Padding(
      padding: EdgeInsets.only(left: fontSize * 0.1, right: fontSize * 0.045),
      child: SizedBox(
        width: stemWidth,
        height: dotBottom + dotSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: stemHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: stemColor,
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
            ),
            Positioned(
              left: (stemWidth - dotSize) / 2,
              bottom: dotBottom,
              width: dotSize,
              height: dotSize,
              child: Transform.scale(
                scale: dotScale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: dotColor,
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
