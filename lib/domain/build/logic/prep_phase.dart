
/// 준비 페이즈 출발 선택 — 런 시작 전 보너스 선택 로직.
///
/// 순수 데이터: presentation에서 선택지 렌더링, domain에서 보너스 적용.
class PrepChoice {
  final String id;
  final String name;
  final String description;
  final PrepBonusType bonusType;
  final int bonusValue;
  final String? blessingId;
  final String? relicId;

  /// balanced 타입 보조값 (HP 보너스).
  final int secondaryValue;

  const PrepChoice({
    required this.id,
    required this.name,
    required this.description,
    required this.bonusType,
    this.bonusValue = 0,
    this.blessingId,
    this.relicId,
    this.secondaryValue = 0,
  });
}

enum PrepBonusType {
  gold,
  hp,
  blessing,
  relic,
  balanced,
}

/// 준비 페이즈 선택지 정의 — balance.json에서 수치 로드.
class PrepPhaseData {
  PrepPhaseData._();

  static const introText =
      '야수들이 도사린 심층의 초입에 섰다. 파트너와 함께 내려가기 전, 마지막 채비를 갖춘다.';
  static const choicePromptText = '무엇을 챙기겠는가?';

  static List<PrepChoice> getChoices({
    int startingGoldBonus = 20,
    int startingHpBonus = 15,
    String startingBlessingId = 'blessing_001',
    String startingRelicId = 'relic_001',
    int mercyHpBonus = 10,
    int balancedGold = 10,
    int balancedHp = 8,
  }) {
    return [
      PrepChoice(
        id: 'prep_gold',
        name: '노련한 탐험가의 주머니',
        description: '시작 골드 +$startingGoldBonus',
        bonusType: PrepBonusType.gold,
        bonusValue: startingGoldBonus,
      ),
      PrepChoice(
        id: 'prep_hp',
        name: '생명력의 부적',
        description: '시작 HP +$startingHpBonus',
        bonusType: PrepBonusType.hp,
        bonusValue: startingHpBonus,
      ),
      PrepChoice(
        id: 'prep_blessing',
        name: '선대 모험가의 축복',
        description: '시작 축복 1개 획득',
        bonusType: PrepBonusType.blessing,
        blessingId: startingBlessingId,
      ),
      PrepChoice(
        id: 'prep_relic',
        name: '고대의 유물',
        description: '유물 1개 획득',
        bonusType: PrepBonusType.relic,
        relicId: startingRelicId,
      ),
      PrepChoice(
        id: 'prep_mercy',
        name: '치유사의 기도',
        description: '시작 HP +$mercyHpBonus',
        bonusType: PrepBonusType.hp,
        bonusValue: mercyHpBonus,
      ),
      PrepChoice(
        id: 'prep_balanced',
        name: '방랑자의 배낭',
        description: '골드 +$balancedGold & HP +$balancedHp',
        bonusType: PrepBonusType.balanced,
        bonusValue: balancedGold,
        secondaryValue: balancedHp,
      ),
    ];
  }
}
