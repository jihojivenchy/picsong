import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:flutter/material.dart';

/// Custom Gradient Slider
class GradientSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double>? onChanged;

  const GradientSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.divisions = 4,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 14,
        activeTrackColor: Colors.transparent,
        inactiveTrackColor: Colors.transparent,
        thumbShape: const _GradientSliderThumbShape(),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
        trackShape: _GradientSliderTrackShape(),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

/// Custom Track Shape with Gradient
class _GradientSliderTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 8;
    final double trackLeft = offset.dx + 12;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 24;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final double trackHeight = sliderTheme.trackHeight ?? 8;
    final Radius trackRadius = Radius.circular(trackHeight / 2);

    // Inactive track (오른쪽)
    final Paint inactivePaint =
        Paint()
          ..color = AppColors.background
          ..style = PaintingStyle.fill;

    final RRect inactiveTrackRRect = RRect.fromRectAndRadius(
      trackRect,
      trackRadius,
    );
    canvas.drawRRect(inactiveTrackRRect, inactivePaint);

    // Active track (왼쪽) - gradient
    final double activeTrackWidth = thumbCenter.dx - trackRect.left;
    if (activeTrackWidth > 0) {
      final Rect activeTrackRect = Rect.fromLTWH(
        trackRect.left,
        trackRect.top,
        activeTrackWidth,
        trackHeight,
      );

      final Paint activePaint =
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.subText, AppColors.primary],
            ).createShader(
              Rect.fromLTWH(
                trackRect.left,
                trackRect.top,
                trackRect.width,
                trackHeight,
              ),
            )
            ..style = PaintingStyle.fill;

      final RRect activeTrackRRect = RRect.fromRectAndCorners(
        activeTrackRect,
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        topRight:
            activeTrackWidth >= trackRect.width ? trackRadius : Radius.zero,
        bottomRight:
            activeTrackWidth >= trackRect.width ? trackRadius : Radius.zero,
      );
      canvas.drawRRect(activeTrackRRect, activePaint);
    }
  }
}

/// Custom Thumb Shape
class _GradientSliderThumbShape extends SliderComponentShape {
  const _GradientSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Shadow
    final Path shadowPath =
        Path()..addOval(
          Rect.fromCircle(center: center.translate(0, 2), radius: 12),
        );
    canvas.drawShadow(shadowPath, AppColors.black.withValues(alpha: 0.15), 4, true);

    // Inner circle
    final Paint innerPaint =
        Paint()
          ..color = AppColors.appPink
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, innerPaint);

    // Center dot
    final Paint centerPaint =
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);
  }
}
