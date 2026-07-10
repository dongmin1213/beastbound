import 'package:soul_dungeon/core/models/disposition_axis.dart';

/// 직업 경로 — 기본 9직업 + 상위직 9종 + 조합직 5종의 sealed class 정의.
///
/// switch exhaustiveness를 컴파일 타임에 보장.
sealed class JobPath {
  String get id;
  String get displayName;
  String get description;
  DispositionAxis get dominantAxis;
  String get specialActionType;
  bool get isHidden;

  /// 2차 전직 상위직 여부.
  bool get isAdvanced => false;

  /// 2차 전직 조합직 여부.
  bool get isCombination => false;

  /// 상위직: 전제 1차 직업 ID (null = 해당 없음).
  String? get requiredPrimaryJobId => null;

  /// 조합직: 필요한 2개 축 ({primary, secondary}).
  /// null = 해당 없음.
  ({DispositionAxis primary, DispositionAxis secondary})? get requiredAxes =>
      null;

  /// 직업 티어 (1 = 1차 전직, 2 = 2차 전직).
  int get tier => (isAdvanced || isCombination) ? 2 : 1;

  const JobPath();

  /// 모든 직업 경로 목록 (1차 + 2차).
  static const List<JobPath> values = [
    // 1차 전직
    Warrior(),
    Saint(),
    Sage(),
    Assassin(),
    Guardian(),
    Wanderer(),
    Reaper(),
    Illusionist(),
    Harmonist(),
    // 2차 전직 — 상위직
    SwordSaint(),
    HighPriest(),
    Archmage(),
    ShadowLord(),
    IronFortress(),
    FateTraveler(),
    NetherKing(),
    DimensionMage(),
    OneWithAll(),
    // 2차 전직 — 조합직
    SpellBlade(),
    HolyKnight(),
    DarkMage(),
    DarkKnight(),
    Arbiter(),
  ];

  /// 1차 전직 직업만.
  static const List<JobPath> tier1Values = [
    Warrior(),
    Saint(),
    Sage(),
    Assassin(),
    Guardian(),
    Wanderer(),
    Reaper(),
    Illusionist(),
    Harmonist(),
  ];

  /// 2차 전직 직업만.
  static const List<JobPath> tier2Values = [
    SwordSaint(),
    HighPriest(),
    Archmage(),
    ShadowLord(),
    IronFortress(),
    FateTraveler(),
    NetherKing(),
    DimensionMage(),
    OneWithAll(),
    SpellBlade(),
    HolyKnight(),
    DarkMage(),
    DarkKnight(),
    Arbiter(),
  ];

  /// ID 문자열에서 JobPath 인스턴스를 조회한다.
  /// 일치하는 ID가 없으면 null을 반환한다.
  static JobPath? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null) return null;
    for (final job in values) {
      if (job.id == id) return job;
    }
    return null;
  }

  /// 직렬화용. id 기반으로 복원 가능.
  Map<String, dynamic> toJson() => {'id': id};
}

// ═══════════════════════════════════════════════════════════════
// 1차 전직 — 기본 6직업 + 히든 3직업
// ═══════════════════════════════════════════════════════════════

final class Warrior extends JobPath {
  @override
  String get id => 'warrior';
  @override
  String get displayName => '전사';
  @override
  String get description => '강인한 힘으로 적을 압도하는 투쟁의 전사.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.struggle;
  @override
  String get specialActionType => 'powerStrike';
  @override
  bool get isHidden => false;
  const Warrior();
}

final class Saint extends JobPath {
  @override
  String get id => 'saint';
  @override
  String get displayName => '성자';
  @override
  String get description => '자비로운 빛으로 상처를 치유하는 성스러운 존재.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.mercy;
  @override
  String get specialActionType => 'divineHeal';
  @override
  bool get isHidden => false;
  const Saint();
}

final class Sage extends JobPath {
  @override
  String get id => 'sage';
  @override
  String get displayName => '현자';
  @override
  String get description => '깊은 통찰로 진실을 꿰뚫는 지혜의 구도자.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.wisdom;
  @override
  String get specialActionType => 'insight';
  @override
  bool get isHidden => false;
  const Sage();
}

final class Assassin extends JobPath {
  @override
  String get id => 'assassin';
  @override
  String get displayName => '암살자';
  @override
  String get description => '그림자 속에서 치명적인 일격을 가하는 암흑의 칼날.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.shadow;
  @override
  String get specialActionType => 'shadowStrike';
  @override
  bool get isHidden => false;
  const Assassin();
}

final class Guardian extends JobPath {
  @override
  String get id => 'guardian';
  @override
  String get displayName => '수호자';
  @override
  String get description => '굳건한 의지로 모든 것을 지켜내는 방패.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.will;
  @override
  String get specialActionType => 'ironWall';
  @override
  bool get isHidden => false;
  const Guardian();
}

final class Wanderer extends JobPath {
  @override
  String get id => 'wanderer';
  @override
  String get displayName => '방랑자';
  @override
  String get description => '어디에도 속하지 않으나 어디서든 적응하는 자유로운 영혼.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.harmony;
  @override
  String get specialActionType => 'adapt';
  @override
  bool get isHidden => false;
  const Wanderer();
}

/// 사신 — HP 소모 + 즉사 + 사망 트리거.
final class Reaper extends JobPath {
  @override
  String get id => 'reaper';
  @override
  String get displayName => '사신';
  @override
  String get description => '생명을 대가로 죽음의 힘을 휘두르는 금단의 존재.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.struggle;
  @override
  String get specialActionType => 'deathReap';
  @override
  bool get isHidden => true;
  const Reaper();
}

/// 환술사 — 카드 복사 + 생성 + 환영.
final class Illusionist extends JobPath {
  @override
  String get id => 'illusionist';
  @override
  String get displayName => '환술사';
  @override
  String get description => '환영과 복제로 적을 농락하는 기만의 마술사.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.shadow;
  @override
  String get specialActionType => 'mirrorImage';
  @override
  bool get isHidden => true;
  const Illusionist();
}

/// 조율사 — 균형 + 적응 + 다속성 시너지.
final class Harmonist extends JobPath {
  @override
  String get id => 'harmonist';
  @override
  String get displayName => '조율사';
  @override
  String get description => '만물의 조화를 이끌어내는 균형의 지배자.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.harmony;
  @override
  String get specialActionType => 'attune';
  @override
  bool get isHidden => true;
  const Harmonist();
}

// ═══════════════════════════════════════════════════════════════
// 2차 전직 — 상위직 9종 (같은 축 심화)
// ═══════════════════════════════════════════════════════════════

/// 검성 — 극한 공격력 + 자해 극대화.
final class SwordSaint extends JobPath {
  @override
  String get id => 'swordSaint';
  @override
  String get displayName => '검성';
  @override
  String get description => '검의 끝에서 진리를 깨달은 극한의 검사. 자신의 피로 칼날을 갈아 모든 것을 베어낸다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.struggle;
  @override
  String get specialActionType => 'swordAura';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'warrior';
  const SwordSaint();
}

/// 대사제 — 무한 재생 + 완전 정화.
final class HighPriest extends JobPath {
  @override
  String get id => 'highPriest';
  @override
  String get displayName => '대사제';
  @override
  String get description => '신성한 빛의 정수를 체득한 최고위 사제. 모든 상처를 치유하고 모든 오염을 정화한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.mercy;
  @override
  String get specialActionType => 'divineLight';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'saint';
  const HighPriest();
}

/// 대현자 — 완전한 손패/덱 컨트롤 + AP 조작.
final class Archmage extends JobPath {
  @override
  String get id => 'archmage';
  @override
  String get displayName => '대현자';
  @override
  String get description => '마법의 근원에 도달한 최고의 마법사. 시간과 공간을 왜곡하여 전장을 지배한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.wisdom;
  @override
  String get specialActionType => 'arcaneWill';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'sage';
  const Archmage();
}

/// 그림자군주 — 최대 독 + 완전 은신.
final class ShadowLord extends JobPath {
  @override
  String get id => 'shadowLord';
  @override
  String get displayName => '그림자군주';
  @override
  String get description => '그림자 그 자체가 된 어둠의 지배자. 독과 암살로 모든 적을 말살한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.shadow;
  @override
  String get specialActionType => 'shadowDomain';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'assassin';
  const ShadowLord();
}

/// 철벽성주 — 100% 블록 유지 + 반사 데미지.
final class IronFortress extends JobPath {
  @override
  String get id => 'ironFortress';
  @override
  String get displayName => '철벽성주';
  @override
  String get description => '절대 무너지지 않는 난공불락의 성벽. 모든 공격을 막아내고 되돌려보낸다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.will;
  @override
  String get specialActionType => 'absoluteDefense';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'guardian';
  const IronFortress();
}

/// 운명의 여행자 — 극한 RNG + 카드 생성.
final class FateTraveler extends JobPath {
  @override
  String get id => 'fateTraveler';
  @override
  String get displayName => '운명의 여행자';
  @override
  String get description => '운명의 실을 손에 쥔 방랑자. 예측불허의 행운으로 불가능을 가능케 한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.harmony;
  @override
  String get specialActionType => 'fateSpin';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'wanderer';
  const FateTraveler();
}

/// 명계왕 — 강화된 즉사 + 극한 HP 드레인.
final class NetherKing extends JobPath {
  @override
  String get id => 'netherKing';
  @override
  String get displayName => '명계왕';
  @override
  String get description => '명계의 왕좌에 앉은 죽음의 군주. 생과 사의 경계를 넘어 모든 영혼을 지배한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.struggle;
  @override
  String get specialActionType => 'netherCommand';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'reaper';
  const NetherKing();
}

/// 차원술사 — 무한 복제 + 적 행동 복사.
final class DimensionMage extends JobPath {
  @override
  String get id => 'dimensionMage';
  @override
  String get displayName => '차원술사';
  @override
  String get description => '차원의 틈새를 자유자재로 넘나드는 마술사. 현실을 복제하고 왜곡하여 전장을 장악한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.shadow;
  @override
  String get specialActionType => 'dimensionRift';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'illusionist';
  const DimensionMage();
}

/// 만물일체 — 전 스탯 동기화 + 완벽한 균형.
final class OneWithAll extends JobPath {
  @override
  String get id => 'oneWithAll';
  @override
  String get displayName => '만물일체';
  @override
  String get description => '만물과 하나가 된 궁극의 조율자. 모든 힘을 하나로 합쳐 초월적인 경지에 이른다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.harmony;
  @override
  String get specialActionType => 'transcend';
  @override
  bool get isHidden => false;
  @override
  bool get isAdvanced => true;
  @override
  String? get requiredPrimaryJobId => 'harmonist';
  const OneWithAll();
}

// ═══════════════════════════════════════════════════════════════
// 2차 전직 — 조합직 5종 (서로 다른 두 축 조합)
// ═══════════════════════════════════════════════════════════════

/// 마검사 — 마법 강화 물리 공격.
final class SpellBlade extends JobPath {
  @override
  String get id => 'spellBlade';
  @override
  String get displayName => '마검사';
  @override
  String get description => '검과 마법을 하나로 녹여낸 전사. 마력으로 강화된 검격이 모든 방어를 관통한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.struggle;
  @override
  String get specialActionType => 'arcaneSlash';
  @override
  bool get isHidden => false;
  @override
  bool get isCombination => true;
  @override
  ({DispositionAxis primary, DispositionAxis secondary})? get requiredAxes =>
      (primary: DispositionAxis.struggle, secondary: DispositionAxis.wisdom);
  const SpellBlade();
}

/// 성기사 — 공격과 치유를 동시에.
final class HolyKnight extends JobPath {
  @override
  String get id => 'holyKnight';
  @override
  String get displayName => '성기사';
  @override
  String get description => '성스러운 빛을 검에 깃들인 기사. 적을 베는 동시에 스스로를 치유한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.struggle;
  @override
  String get specialActionType => 'holyStrike';
  @override
  bool get isHidden => false;
  @override
  bool get isCombination => true;
  @override
  ({DispositionAxis primary, DispositionAxis secondary})? get requiredAxes =>
      (primary: DispositionAxis.struggle, secondary: DispositionAxis.mercy);
  const HolyKnight();
}

/// 흑마법사 — 저주 + 손패 조작.
final class DarkMage extends JobPath {
  @override
  String get id => 'darkMage';
  @override
  String get displayName => '흑마법사';
  @override
  String get description => '금단의 마법에 빠진 마도사. 저주와 어둠의 힘으로 적을 잠식한다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.wisdom;
  @override
  String get specialActionType => 'curseWave';
  @override
  bool get isHidden => false;
  @override
  bool get isCombination => true;
  @override
  ({DispositionAxis primary, DispositionAxis secondary})? get requiredAxes =>
      (primary: DispositionAxis.wisdom, secondary: DispositionAxis.shadow);
  const DarkMage();
}

/// 암흑기사 — 은신 + 반격.
final class DarkKnight extends JobPath {
  @override
  String get id => 'darkKnight';
  @override
  String get displayName => '암흑기사';
  @override
  String get description => '그림자와 철벽을 하나로 합친 암흑의 기사. 어둠 속에서 반격의 칼날을 휘두른다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.shadow;
  @override
  String get specialActionType => 'darkCounter';
  @override
  bool get isHidden => false;
  @override
  bool get isCombination => true;
  @override
  ({DispositionAxis primary, DispositionAxis secondary})? get requiredAxes =>
      (primary: DispositionAxis.shadow, secondary: DispositionAxis.will);
  const DarkKnight();
}

/// 심판자 — 정화 + 독 전환.
final class Arbiter extends JobPath {
  @override
  String get id => 'arbiter';
  @override
  String get displayName => '심판자';
  @override
  String get description => '정의와 어둠 사이에서 심판을 내리는 자. 오염을 정화하고 그 힘을 되돌려준다.';
  @override
  DispositionAxis get dominantAxis => DispositionAxis.mercy;
  @override
  String get specialActionType => 'divineJudgment';
  @override
  bool get isHidden => false;
  @override
  bool get isCombination => true;
  @override
  ({DispositionAxis primary, DispositionAxis secondary})? get requiredAxes =>
      (primary: DispositionAxis.mercy, secondary: DispositionAxis.shadow);
  const Arbiter();
}
