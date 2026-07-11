import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/models/map_node.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';
import 'package:soul_dungeon/presentation/widgets/minimap/room_symbol.dart';

/// 미니맵 위젯 — "모험가의 메모" 테두리 프레임.
///
/// FloorMap 데이터를 텍스트 심볼 기반 DAG로 시각화.
/// 순수 presentation — domain import 없음 (models만 사용), 데이터는 파라미터로 수신.
///
/// 안개 시스템: 현재 위치 기준 앞뒤 일정 범위만 표시.
/// [visibleDepthBehind] 뒤쪽 깊이, [visibleDepthAhead] 앞쪽 깊이.
class MinimapWidget extends StatelessWidget {
  final FloorMap floorMap;
  final String currentNodeId;
  final Set<String> visitedNodeIds;
  final void Function(String nodeId)? onNodeTap;

  /// 타입 공개 범위: 현재 위치 기준 앞으로 이 깊이까지만 방 타입을 공개.
  /// 그 너머의 잠금 노드는 [·] (존재만 표시, 타입 미공개).
  final int typeRevealAhead;

  final Color? frameBackground;
  final Color? titleBarColor;

  const MinimapWidget({
    super.key,
    required this.floorMap,
    required this.currentNodeId,
    required this.visitedNodeIds,
    this.onNodeTap,
    this.typeRevealAhead = 2,
    this.frameBackground,
    this.titleBarColor,
  });

  int get _currentDepth {
    final node = floorMap.nodeById(currentNodeId);
    return node?.depth ?? 0;
  }

  NodeVisualState _nodeState(MapNode node) {
    if (node.id == currentNodeId) return NodeVisualState.current;
    if (visitedNodeIds.contains(node.id)) return NodeVisualState.visited;

    // 현재 노드의 다음 노드만 available
    final currentNode = floorMap.nodeById(currentNodeId);
    if (currentNode != null && currentNode.nextNodeIds.contains(node.id)) {
      return NodeVisualState.available;
    }

    return NodeVisualState.locked;
  }

  /// 잠금 노드의 타입 공개 여부 (typeRevealAhead 범위 내만 공개).
  bool _isTypeRevealed(MapNode node) {
    final state = _nodeState(node);
    // current / visited / available: 항상 공개
    if (state != NodeVisualState.locked) return true;
    // locked 노드: typeRevealAhead 범위 내만 공개
    return node.depth <= _currentDepth + typeRevealAhead;
  }

  /// 전체 깊이 목록 반환 (D-02: 안개 제거, 전체 맵 표시).
  List<int> _visibleDepths() {
    return [for (int d = 0; d <= floorMap.maxDepth; d++) d];
  }

  List<Widget> _buildMapRows(BuildContext context) {
    final depths = _visibleDepths();
    final rows = <Widget>[];

    for (int i = 0; i < depths.length; i++) {
      rows.add(_buildDepthRow(context, depths[i]));
      if (i < depths.length - 1) {
        rows.add(_buildConnections(context, depths[i]));
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final mapRows = _buildMapRows(context);
    return RetroWindowFrame(
      title: '~ 모험가의 메모 ~',
      titleBarColor: titleBarColor ?? const Color(0xFF1A1A2E),
      borderColor: AppTheme.minimapBorderColor,
      backgroundColor: frameBackground ?? const Color(0xFF0D0D14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: mapRows,
        ),
      ),
    );
  }

  Widget _buildDepthRow(BuildContext context, int depth) {
    final nodesAtDepth = floorMap.nodesAtDepth(depth);
    final isCurrent = depth == _currentDepth;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 깊이 마커 (현재 깊이에만 표시)
          SizedBox(
            width: 20,
            child: isCurrent
                ? Text(
                    '\u25B6',
                    style: TextStyle(
                      color: AppTheme.minimapCurrentColor,
                      fontSize: ResponsiveScale.scaleFontSize(context, 10),
                      fontFamily: 'monospace',
                    ),
                  )
                : null,
          ),
          for (int i = 0; i < nodesAtDepth.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            RoomSymbolWidget(
              roomType: nodesAtDepth[i].roomType,
              visualState: _nodeState(nodesAtDepth[i]),
              typeRevealed: _isTypeRevealed(nodesAtDepth[i]),
            ),
          ],
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildConnections(BuildContext context, int depth) {
    final parentNodes = floorMap.nodesAtDepth(depth);
    final childNodes = floorMap.nodesAtDepth(depth + 1);

    if (parentNodes.isEmpty || childNodes.isEmpty) {
      return const SizedBox(height: 8);
    }

    // DAG 연결 수집 (parentIdx, childIdx, visited 여부)
    final connections = <_ConnectionLine>[];
    for (int pi = 0; pi < parentNodes.length; pi++) {
      final parent = parentNodes[pi];
      final visited =
          visitedNodeIds.contains(parent.id) || parent.id == currentNodeId;
      for (int ci = 0; ci < childNodes.length; ci++) {
        if (parent.nextNodeIds.contains(childNodes[ci].id)) {
          connections.add(_ConnectionLine(
            parentIdx: pi,
            childIdx: ci,
            visited: visited,
          ));
        }
      }
    }

    if (connections.isEmpty) return const SizedBox(height: 8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        double nodeCenter(int index, int count) {
          const nodeW = 36.0;
          const gap = 16.0;
          const margin = 20.0;
          final rowW = count * nodeW + (count - 1) * gap + margin * 2;
          final startX = (totalWidth - rowW) / 2 + margin;
          return startX + index * (nodeW + gap) + nodeW / 2;
        }

        final lines = connections
            .map((c) => _ResolvedLine(
                  x0: nodeCenter(c.parentIdx, parentNodes.length),
                  x1: nodeCenter(c.childIdx, childNodes.length),
                  visited: c.visited,
                ))
            .toList();

        return CustomPaint(
          size: Size(totalWidth, 18),
          painter: _MinimapLinePainter(lines: lines),
        );
      },
    );
  }
}

// ── 미니맵 연결선 CustomPainter ──

class _ConnectionLine {
  final int parentIdx;
  final int childIdx;
  final bool visited;
  const _ConnectionLine({
    required this.parentIdx,
    required this.childIdx,
    required this.visited,
  });
}

class _ResolvedLine {
  final double x0;
  final double x1;
  final bool visited;
  const _ResolvedLine({
    required this.x0,
    required this.x1,
    required this.visited,
  });
}

class _MinimapLinePainter extends CustomPainter {
  final List<_ResolvedLine> lines;

  _MinimapLinePainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.visited
            ? AppTheme.minimapConnectionColor
            : AppTheme.minimapLockedColor
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final path = Path()
        ..moveTo(line.x0, 0)
        ..cubicTo(
          line.x0, size.height * 0.45,
          line.x1, size.height * 0.55,
          line.x1, size.height,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MinimapLinePainter old) {
    if (lines.length != old.lines.length) return true;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].x0 != old.lines[i].x0 ||
          lines[i].x1 != old.lines[i].x1 ||
          lines[i].visited != old.lines[i].visited) {
        return true;
      }
    }
    return false;
  }
}

