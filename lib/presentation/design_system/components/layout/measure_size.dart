import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 자식 위젯의 렌더 크기를 실측해 [onChanged] 로 전달하는 도우미 위젯
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({
    super.key,
    required this.onChanged,
    required Widget super.child,
  });

  /// 자식 크기가 변할 때마다 호출되는 콜백
  final ValueChanged<Size> onChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChanged);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _MeasureSizeRenderObject).onChanged = onChanged;
  }
}

/// 자식 크기 변화 감지 전용 RenderProxyBox
class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChanged);

  ValueChanged<Size> onChanged;
  Size? _previousSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_previousSize == newSize) return;
    _previousSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(newSize));
  }
}
