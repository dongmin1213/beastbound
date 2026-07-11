import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

/// 몬스터 id → 표시용 이름/스프라이트 (일반 적 + 보스 통합).
///
/// 동료/도감 화면이 적·보스 구분 없이 몬스터를 표시하기 위한 헬퍼.
class MonsterDisplay {
  MonsterDisplay._();

  static const Map<String, String> _bossNames = {
    'boss_slime_king': '슬라임 왕',
    'boss_sewer_croc': '하수도 악어',
    'boss_rat_monarch': '쥐 군주',
    'boss_spider_lord': '거미 군주',
    'boss_warden_chief': '간수장',
    'boss_ghost_convict': '원혼 사형수',
    'boss_orc_general': '오크 대장군',
    'boss_crystal_golem': '수정 골렘',
    'boss_mana_overload': '마나 폭주체',
    'boss_vampire_lord': '뱀파이어 군주',
    'boss_arch_demon': '대악마',
    'boss_corrupt_high_priest': '타락 대사제',
    'boss_dungeon_master': '던전 마스터',
    'boss_void_sovereign': '공허의 군주',
    'boss_dimension_collapser': '차원 붕괴자',
  };

  /// id → 이름 (없으면 id 그대로).
  static String name(String id) {
    if (_bossNames.containsKey(id)) return _bossNames[id]!;
    for (final e in _allEnemies) {
      if (e.id == id) return e.name;
    }
    return id;
  }

  /// id → 스프라이트 경로 (적 우선, 없으면 보스). 없으면 null.
  static String? sprite(String id) =>
      PixelArtAssets.enemySprite(id) ?? PixelArtAssets.bossSprite(id);

  /// 보스 여부.
  static bool isBoss(String id) => _bossNames.containsKey(id);

  static final _allEnemies = [
    ...FloorEnemies.floor1Normal, ...FloorEnemies.floor1Elite,
    ...FloorEnemies.floor2Normal, ...FloorEnemies.floor2Elite,
    ...FloorEnemies.floor3Normal, ...FloorEnemies.floor3Elite,
    ...FloorEnemies.floor4Normal, ...FloorEnemies.floor4Elite,
    ...FloorEnemies.floor5Normal, ...FloorEnemies.floor5Elite,
  ];
}
