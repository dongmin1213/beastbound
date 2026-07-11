import 'package:soul_dungeon/core/text/korean_particles.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';

/// 보스 기믹 텍스트 — 보스 전투 시 기믹 설명 + 턴별 피드백.
class BossGimmickText {
  BossGimmickText._();

  /// 보스 전투 시작 시 기믹 설명 텍스트.
  static String introText(String bossName, BossGimmick gimmick) {
    return switch (gimmick) {
      BossGimmick.none => '',
      BossGimmick.regen =>
        '[$bossName — 재생] 매 턴 HP를 회복한다. 지속적인 화력이 필요하다.',
      BossGimmick.web =>
        '[$bossName — 거미줄] 거미줄이 시야를 가린다. 드로우가 1 감소한다.',
      BossGimmick.rage =>
        '[$bossName — 분노] 공격받을수록 분노하여 강해진다. 힘이 증가한다.',
      BossGimmick.drain =>
        '[$bossName — 흡혈] 공격 데미지의 일부를 흡수하여 회복한다.',
      BossGimmick.formShift =>
        '[$bossName — 형태 변환] 여러 형태로 변신하며 패턴이 바뀐다.',
      BossGimmick.bleed =>
        '[$bossName — 출혈] 적의 공격에 맞으면 화상을 입는다.',
      BossGimmick.shackle =>
        '[$bossName — 속박] 사슬이 행동을 제한한다. 매 턴 AP가 1 감소한다.',
      BossGimmick.reflect =>
        '[$bossName — 반사] 수정 갑옷이 공격을 반사한다. 가한 데미지의 15%를 돌려받는다.',
      BossGimmick.corruption =>
        '[$bossName — 부패] 부패의 기운이 퍼진다. 매 턴 랜덤 디버프를 받는다.',
      BossGimmick.voidGimmick =>
        '[$bossName — 공허] 공허의 힘이 카드를 삼킨다. 매 턴 드로우 -1.',
    };
  }

  /// 보스 전투 시작 시 기믹 힌트 (준비 화면용, 더 간결).
  static String hintText(String bossName, BossGimmick gimmick) {
    return switch (gimmick) {
      BossGimmick.none => '특별한 능력은 없는 것 같다.',
      BossGimmick.regen => '이 적은 재생 능력을 가지고 있다고 한다...',
      BossGimmick.web => '거미줄이 시야를 가려 카드를 찾기 어렵다고 한다...',
      BossGimmick.rage =>
        '공격하면 할수록 분노하여 강해진다고 한다... 신중하게.',
      BossGimmick.drain => '적의 공격에 맞으면 생명력을 흡수당한다고 한다...',
      BossGimmick.formShift => '여러 형태로 변신하는 능력이 있다고 한다...',
      BossGimmick.bleed => '이빨이 날카로워 피가 멈추지 않는다고 한다...',
      BossGimmick.shackle => '강력한 사슬로 행동을 제약한다고 한다...',
      BossGimmick.reflect => '단단한 표면이 공격을 반사한다고 한다...',
      BossGimmick.corruption => '부패의 기운이 몸을 좀먹는다고 한다...',
      BossGimmick.voidGimmick => '공허의 힘이 모든 것을 삼킨다고 한다...',
    };
  }

  /// 기믹 발동 시 턴별 피드백 텍스트.
  static String triggerText(String bossName, BossGimmick gimmick, {
    int healAmount = 0,
    int drainAmount = 0,
    int strengthGain = 0,
    bool regenBlocked = false,
    int reflectDamage = 0,
    String debuffName = '',
  }) {
    return switch (gimmick) {
      BossGimmick.none => '',
      BossGimmick.regen => regenBlocked
          ? '♻ $bossName의 재생이 차단되었다!'
          : healAmount > 0
              ? '♻ $bossName${KoreanParticles.iGa(bossName)} $healAmount HP를 재생했다!'
              : '',
      BossGimmick.web =>
        '🕸 거미줄이 시야를 가린다! 드로우 -1',
      BossGimmick.rage => strengthGain > 0
          ? '🔥 $bossName${KoreanParticles.iGa(bossName)} 분노한다! 힘 +$strengthGain'
          : '',
      BossGimmick.drain => drainAmount > 0
          ? '🩸 $bossName${KoreanParticles.iGa(bossName)} $drainAmount HP를 흡수했다!'
          : '',
      BossGimmick.formShift => '',
      BossGimmick.bleed =>
        '🩸 $bossName의 공격에 출혈이 발생했다! 화상 2',
      BossGimmick.shackle =>
        '⛓ 사슬이 행동을 제한한다! AP -1',
      BossGimmick.reflect => reflectDamage > 0
          ? '💎 $bossName${KoreanParticles.iGa(bossName)} $reflectDamage 데미지를 반사했다!'
          : '',
      BossGimmick.corruption => debuffName.isNotEmpty
          ? '☠ 부패의 기운이 퍼진다! $debuffName 부여'
          : '☠ 부패의 기운이 퍼진다!',
      BossGimmick.voidGimmick =>
        '🌀 공허의 힘이 드로우를 억제한다! 드로우 -1',
    };
  }

  /// 기믹 아이콘 태그 (EnemyAreaWidget 뱃지용).
  static String gimmickTag(BossGimmick gimmick) {
    return switch (gimmick) {
      BossGimmick.none => '',
      BossGimmick.regen => '[재생]',
      BossGimmick.web => '[거미줄]',
      BossGimmick.rage => '[분노]',
      BossGimmick.drain => '[흡혈]',
      BossGimmick.formShift => '[변신]',
      BossGimmick.bleed => '[출혈]',
      BossGimmick.shackle => '[속박]',
      BossGimmick.reflect => '[반사]',
      BossGimmick.corruption => '[부패]',
      BossGimmick.voidGimmick => '[공허]',
    };
  }

  /// 보스별 첫 등장 서술.
  static String bossIntroNarration(String bossId) {
    return switch (bossId) {
      'boss_slime_king' =>
        '거대한 슬라임이 진동하며 형태를 갖추어 간다. 왕관 같은 돌기가 솟아오른다.',
      'boss_sewer_croc' =>
        '어두운 수로에서 거대한 턱이 드러난다. 수면 위로 노란 눈이 빛난다.',
      'boss_rat_monarch' =>
        '수천 마리의 쥐가 하나로 뭉쳐 인간의 형상을 이룬다. 부패의 왕관이 빛난다.',
      'boss_spider_lord' =>
        '무수한 거미줄 너머로 거대한 그림자가 다가온다. 여덟 개의 눈이 빛난다.',
      'boss_warden_chief' =>
        '철제 열쇠가 덜컹거린다. 거대한 간수장이 쇠사슬을 끌며 다가온다.',
      'boss_ghost_convict' =>
        '처형장의 핏자국 위에 형체가 피어오른다. 원한에 찬 비명이 울린다.',
      'boss_orc_general' =>
        '전장의 포효가 벽을 울린다. 거대한 오크가 전투 도끼를 들어올린다.',
      'boss_crystal_golem' =>
        '수정 벽에서 거대한 형체가 분리되어 나온다. 빛이 굴절되며 눈부시게 빛난다.',
      'boss_mana_overload' =>
        '폭주하는 마나가 실체를 형성한다. 불안정한 에너지가 사방으로 방출된다.',
      'boss_vampire_lord' =>
        '어둠 속에서 창백한 얼굴이 드러난다. 핏빛 눈동자가 탐욕스럽게 빛난다.',
      'boss_arch_demon' =>
        '지옥의 문이 열리며 뜨거운 바람이 불어온다. 거대한 뿔이 어둠을 가른다.',
      'boss_corrupt_high_priest' =>
        '제단 위에서 타락한 기도문이 울려퍼진다. 성스러운 빛이 검게 물든다.',
      'boss_dungeon_master' =>
        '심층의 가장 깊은 곳. 이곳의 주인이 천천히 눈을 뜬다. 공간 자체가 긴장한다.',
      'boss_void_sovereign' =>
        '공허의 왕좌에서 형태 없는 존재가 일어선다. 주변 공간이 일그러진다.',
      'boss_dimension_collapser' =>
        '차원의 균열에서 불가해한 존재가 나타난다. 현실 자체가 비명을 지른다.',
      _ => '강대한 적이 길을 가로막는다.',
    };
  }
}
