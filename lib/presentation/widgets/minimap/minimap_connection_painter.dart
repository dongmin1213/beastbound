/// 미니맵 노드 간 연결선 텍스트 문자 결정 유틸.
class MinimapConnectionPainter {
  MinimapConnectionPainter._();

  /// 부모 노드(parentIndex)와 자식 노드(childIndex) 위치 관계에 따른 연결 문자.
  /// parentIndex, childIndex는 같은 depth row 내 인덱스.
  static String connectionChar({
    required int parentIndex,
    required int childIndex,
    required int parentCount,
    required int childCount,
  }) {
    if (parentCount <= 0 || childCount <= 0) return ' ';

    final parentCenter = parentCount > 1
        ? parentIndex / (parentCount - 1)
        : 0.5;
    final childCenter = childCount > 1
        ? childIndex / (childCount - 1)
        : 0.5;

    final diff = childCenter - parentCenter;

    if (diff.abs() < 0.01) return '\u2502'; // │ 직선
    if (diff > 0) return '\u2572'; // ╲ 오른쪽 아래
    return '\u2571'; // ╱ 왼쪽 아래
  }
}
