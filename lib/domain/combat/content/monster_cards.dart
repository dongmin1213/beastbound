import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';

/// 몬스터 무브풀 — 몬스터 id → 길들이면 드래프트 가능한 카드 id 목록.
///
/// "네가 싸운 적이, 네 덱이 된다"의 **데이터 백본**.
/// 몬스터를 길들이면 이 무브풀에서 카드를 뽑아 덱에 넣는다(장착 풀).
/// 콘텐츠 교체는 원칙적으로 이 파일 하나만 수정한다(에셋 swap 구조와 동일 철학).
///
/// 현재는 원작의 기존 카드(직업/무색)를 테마별로 재활용. 신규 카드 도입 시
/// 여기 매핑만 갈아끼우면 된다.
class MonsterCards {
  MonsterCards._();

  /// 몬스터 id → 무브풀 카드 id. (1층 8종 — 테마별)
  static const Map<String, List<String>> _movepool = {
    // 쥐 — 빠른 연타.
    'enemy_rat': [
      'colorless_focused_strike',
      'colorless_double_strike',
      'colorless_sprint',
      'warrior_charge',
      'colorless_critical_strike',
    ],
    // 슬라임 — 방어/점착.
    'enemy_slime': [
      'guardian_iron_guard',
      'guardian_shield_bash',
      'colorless_endurance',
      'guardian_thorn_armor',
      'colorless_patience',
    ],
    // 고블린 — 기본 근접 공격.
    'enemy_goblin': [
      'warrior_heavy_strike',
      'warrior_crush',
      'warrior_charge',
      'colorless_focused_strike',
      'warrior_spin_slash',
    ],
    // 고블린 두목 — 근접 + 버프.
    'enemy_goblin_chief': [
      'warrior_war_cry',
      'warrior_onslaught',
      'warrior_rage_shout',
      'warrior_heavy_strike',
      'colorless_expose_weakness',
    ],
    // 독두꺼비 — 독/도트.
    'enemy_poison_toad': [
      'assassin_poison_blade',
      'assassin_poison_cloud',
      'colorless_poison_jar',
      'assassin_poison_burst',
      'assassin_ambush',
    ],
    // 박쥐 떼 — 다단히트/속공.
    'enemy_bat_swarm': [
      'assassin_chain_strike',
      'colorless_double_strike',
      'colorless_sprint',
      'assassin_shadow_step',
      'whirlwind',
    ],
    // 하수구 거인 — 강타/중량.
    'enemy_sewer_giant': [
      'warrior_execute',
      'warrior_crush',
      'guardian_wall_charge',
      'warrior_berserker',
      'colorless_last_stand',
    ],
    // 독두꺼비 여왕 — 독 강화.
    'enemy_poison_toad_queen': [
      'assassin_poison_burst',
      'assassin_poison_cloud',
      'colorless_poison_jar',
      'assassin_assassination',
      'assassin_poison_blade',
    ],
  };

  /// 몬스터 id → 무브풀 카드 id 목록 (없으면 빈 리스트).
  static List<String> movepoolIds(String monsterId) =>
      _movepool[monsterId] ?? const [];

  /// 몬스터 id → 실제 CardData 목록 (레지스트리에 없는 id는 자동 스킵).
  static List<CardData> movepool(String monsterId) => movepoolIds(monsterId)
      .map(CardPool.findById)
      .whereType<CardData>()
      .toList();

  /// 무브풀 정의 여부.
  static bool hasMovepool(String monsterId) =>
      _movepool.containsKey(monsterId);
}
