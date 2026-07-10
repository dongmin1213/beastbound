import 'package:soul_dungeon/core/models/game_enums.dart';

/// 콘텐츠 엔진 쿼리 빌더.
///
/// 지정된 필드로 TextBlockSchema를 필터링한다.
/// null 필드는 "아무 값이나 허용"을 의미.
class ContentQuery {
  final int? floor;
  final RoomType? roomType;
  final Set<String> tags;
  final NarrativeLayer? layer;
  final RunType? runType;
  final BossDisposition? bossDisposition;
  final bool? reliable;

  const ContentQuery({
    this.floor,
    this.roomType,
    this.tags = const {},
    this.layer,
    this.runType,
    this.bossDisposition,
    this.reliable,
  });

  /// 역인덱스 조회용 키 목록 생성.
  List<String> toIndexKeys() {
    final keys = <String>[];
    if (floor != null) keys.add('floor:$floor');
    if (roomType != null) keys.add('room_type:${roomType!.name}');
    if (layer != null) keys.add('layer:${layer!.name}');
    if (runType != null) keys.add('run_type:${runType!.name}');
    if (bossDisposition != null) {
      keys.add('boss_disposition:${bossDisposition!.name}');
    }
    if (reliable != null) keys.add('reliable:$reliable');
    for (final tag in tags) {
      keys.add('tag:$tag');
    }
    return keys;
  }

  /// 빈 쿼리인지 (필터 없음).
  bool get isEmpty =>
      floor == null &&
      roomType == null &&
      tags.isEmpty &&
      layer == null &&
      runType == null &&
      bossDisposition == null &&
      reliable == null;
}
