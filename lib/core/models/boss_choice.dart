/// 보스 전투 후 선택 기록.
/// floor: 해당 층, bossId: 보스 식별자, choiceType: 선택 유형.
class BossChoice {
  final int floor;
  final String bossId;
  final BossChoiceType choiceType;

  const BossChoice({
    required this.floor,
    required this.bossId,
    required this.choiceType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossChoice &&
          floor == other.floor &&
          bossId == other.bossId &&
          choiceType == other.choiceType;

  @override
  int get hashCode => Object.hash(floor, bossId, choiceType);

  @override
  String toString() => 'BossChoice(floor: $floor, bossId: $bossId, '
      'choiceType: $choiceType)';
}

/// 보스 승리 후 6가지 선택지 — 매 보스전 3개 랜덤 표시.
enum BossChoiceType {
  slay('처치'),
  liberate('해방'),
  coexist('공존'),
  study('깨달음을 얻는다'),
  consume('흡수한다'),
  protect('봉인한다');

  final String displayName;
  const BossChoiceType(this.displayName);

  /// 6→3 엔딩 카테고리 매핑.
  /// slay/consume → slay, liberate/protect → liberate, coexist/study → coexist.
  BossChoiceType get endingCategory => switch (this) {
        BossChoiceType.slay || BossChoiceType.consume => BossChoiceType.slay,
        BossChoiceType.liberate ||
        BossChoiceType.protect =>
          BossChoiceType.liberate,
        BossChoiceType.coexist || BossChoiceType.study => BossChoiceType.coexist,
      };

  /// 공격적 선택지 여부 (기세 게이팅 불필요).
  bool get isAggressive => this == slay || this == consume;

  /// 선택지 설명 — 보스 선택 화면에서 표시.
  String get description => switch (this) {
        BossChoiceType.slay => '보스를 완전히 소멸시킨다. 강한 의지가 필요한 길.',
        BossChoiceType.liberate => '보스를 속박에서 풀어준다. 자비의 힘이 깃든다.',
        BossChoiceType.coexist => '보스와 공존의 길을 택한다. 조화의 기운이 흐른다.',
        BossChoiceType.study => '보스에게서 깨달음을 얻는다. 지혜의 길이 열린다.',
        BossChoiceType.consume => '보스의 힘을 흡수한다. 어둠의 힘이 깃든다.',
        BossChoiceType.protect => '보스를 봉인하여 가둔다. 굳건한 의지가 필요하다.',
      };
}
