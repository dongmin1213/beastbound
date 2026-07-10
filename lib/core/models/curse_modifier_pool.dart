import 'package:soul_dungeon/core/models/curse_modifier_data.dart';

/// 저주 모디파이어 풀 — E9 4종 저주 정적 레지스트리.
///
/// 클리어 횟수에 따라 저주 레벨이 결정되며,
/// 레벨별 효과 수치는 [CurseModifierResolver]에서 처리.
class CurseModifierPool {
  CurseModifierPool._();

  /// 전투 저주: 매 전투 시작 시 적 힘 보너스.
  static const combatCurse = CurseModifierData(
    id: 'curse_mod_combat',
    name: '전투의 저주',
    description: '적이 더 강해집니다. 매 전투 시작 시 적의 힘이 증가합니다.',
    curseType: CurseModifierType.combat,
  );

  /// 덱 저주: 카드 보상 감소 + 상점 가격 증가.
  static const deckCurse = CurseModifierData(
    id: 'curse_mod_deck',
    name: '덱의 저주',
    description: '카드 보상이 줄고 상점 가격이 올라갑니다.',
    curseType: CurseModifierType.deck,
  );

  /// 카드 저주: 시작 덱에 저주 카드 추가.
  static const cardCurse = CurseModifierData(
    id: 'curse_mod_card',
    name: '카드의 저주',
    description: '덱에 쓸모없는 저주 카드가 섞여 있습니다.',
    curseType: CurseModifierType.card,
  );

  /// 서술자 저주: 왜곡 조기 시작.
  static const narratorCurse = CurseModifierData(
    id: 'curse_mod_narrator',
    name: '서술자의 저주',
    description: '서술자가 더 일찍부터 거짓을 말합니다.',
    curseType: CurseModifierType.narrator,
  );

  /// 전체 저주 목록.
  static const List<CurseModifierData> all = [
    combatCurse,
    deckCurse,
    cardCurse,
    narratorCurse,
  ];

  /// ID로 저주 검색. 없으면 null.
  static CurseModifierData? findById(String id) {
    for (final curse in all) {
      if (curse.id == id) return curse;
    }
    return null;
  }

  /// ID 목록 → CurseModifierData 목록 (레벨 포함).
  /// [activeCurseIds] 형식: 'curse_mod_combat:2' (id:level).
  static List<CurseModifierData> resolveIds(List<String> activeCurseIds) {
    final result = <CurseModifierData>[];
    for (final entry in activeCurseIds) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      final id = parts[0];
      final level = int.tryParse(parts[1]) ?? 0;
      final base = findById(id);
      if (base != null && level > 0) {
        result.add(base.withLevel(level));
      }
    }
    return result;
  }
}
