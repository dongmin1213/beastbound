import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/minimap/minimap_connection_painter.dart';

void main() {
  group('MinimapConnectionPainter', () {
    test('연결선 문자 결정: 직선/왼쪽/오른쪽', () {
      // 같은 위치 → 직선 │
      expect(
        MinimapConnectionPainter.connectionChar(
          parentIndex: 0,
          childIndex: 0,
          parentCount: 2,
          childCount: 2,
        ),
        '\u2502', // │
      );

      // 부모가 왼쪽, 자식이 오른쪽 → ╲
      expect(
        MinimapConnectionPainter.connectionChar(
          parentIndex: 0,
          childIndex: 1,
          parentCount: 2,
          childCount: 2,
        ),
        '\u2572', // ╲
      );

      // 부모가 오른쪽, 자식이 왼쪽 → ╱
      expect(
        MinimapConnectionPainter.connectionChar(
          parentIndex: 1,
          childIndex: 0,
          parentCount: 2,
          childCount: 2,
        ),
        '\u2571', // ╱
      );

      // 단일 부모, 단일 자식 → 직선
      expect(
        MinimapConnectionPainter.connectionChar(
          parentIndex: 0,
          childIndex: 0,
          parentCount: 1,
          childCount: 1,
        ),
        '\u2502', // │
      );
    });
  });
}
