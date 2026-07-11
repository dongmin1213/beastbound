import 'package:soul_dungeon/core/models/boss_choice.dart';

/// 보스(영역의 주인) 처치 후 선택 결과 텍스트.
///
/// BEASTBOUND 세계관: 각 영역의 보스는 그곳을 다스리는 **상처 입은 주인**(강대한
/// 야수)이다. 처치/해방/공존/관찰/흡수/보호 선택에 따른 결말 서술.
/// (원작의 소울·구원 서사는 폐기 — 직업 변형도 제거.)
class BossTextVariants {
  BossTextVariants._();

  /// 보스 선택 결과 텍스트.
  /// [bossId] = 보스 ID (boss_slime_king 등).
  /// [choiceType] = 선택 유형.
  /// [jobId] = (미사용) 직업 개념 폐기 — 하위 호환용 파라미터.
  static String choiceResultText(
    String bossId,
    BossChoiceType choiceType, {
    String? jobId,
  }) {
    return _genericText(bossId, choiceType);
  }

  static String _genericText(String bossId, BossChoiceType choiceType) {
    final key = '${bossId}_${choiceType.name}';
    return _genericTexts[key] ?? _defaultText(choiceType);
  }

  static String _defaultText(BossChoiceType choiceType) =>
      switch (choiceType) {
        BossChoiceType.slay => '영역의 주인을 완전히 쓰러뜨렸다. 사방에 정적이 내린다.',
        BossChoiceType.liberate => '주인을 풀어준다. 굴복한 짐승이 조용히 물러난다.',
        BossChoiceType.coexist => '주인과 나란히 선다. 거대한 짐승이 너를 인정한다.',
        BossChoiceType.study => '주인의 습성을 꿰뚫었다. 그 움직임이 몸에 새겨진다.',
        BossChoiceType.consume => '주인의 힘을 받아들인다. 야성이 핏줄을 타고 흐른다.',
        BossChoiceType.protect => '상처 입은 주인을 감싼다. 짐승이 경계를 풀고 숨을 고른다.',
      };

  static const _genericTexts = <String, String>{
    // 1층 — 슬라임 왕
    'boss_slime_king_slay':
        '슬라임 왕이 분해된다. 거대한 점액이 힘없이 바닥으로 퍼진다.',
    'boss_slime_king_liberate':
        '슬라임 왕이 몸을 낮춘다. 굴복한 거체가 습지 깊은 곳으로 물러난다.',
    'boss_slime_king_coexist':
        '슬라임 왕이 몸을 웅크려 자리를 내어준다. 거대한 점액이 네 곁에 머문다.',
    'boss_slime_king_study':
        '슬라임 왕의 점착과 분열을 눈에 담는다. 그 성질이 네 것이 된다.',
    'boss_slime_king_consume':
        '슬라임 왕의 핵을 삼킨다. 끈적한 생명력이 몸에 스며든다.',
    'boss_slime_king_protect':
        '상처 입은 슬라임 왕을 감싼다. 떨리던 거체가 천천히 가라앉는다.',
    // 2층 — 거미 군주
    'boss_spider_lord_slay':
        '거미 군주의 실이 끊어진다. 거미줄로 이루어진 왕국이 무너져 내린다.',
    'boss_spider_lord_liberate':
        '거미 군주가 여덟 다리를 접는다. 굴복한 사냥꾼이 어둠 속으로 물러난다.',
    'boss_spider_lord_coexist':
        '거미 군주가 실로 다리를 놓아준다. 거대한 사냥꾼이 네 뒤를 따른다.',
    'boss_spider_lord_study':
        '거미줄에 새겨진 사냥의 패턴을 읽어낸다. 그 기술이 몸에 스민다.',
    'boss_spider_lord_consume':
        '거미 군주의 독과 실을 흡수한다. 사냥꾼의 본능이 손끝에 깃든다.',
    'boss_spider_lord_protect':
        '지친 거미 군주를 실로 감싸 눕힌다. 여덟 개의 눈이 서서히 감긴다.',
    // 3층 — 오크 대장군
    'boss_orc_general_slay':
        '오크 대장군의 포효가 꺼진다. 거대한 몸이 무릎을 꿇으며 전장이 고요해진다.',
    'boss_orc_general_liberate':
        '대장군이 도끼를 내린다. 굴복한 맹수가 전장을 떠난다.',
    'boss_orc_general_coexist':
        '대장군이 무기를 거두고 네 옆에 선다. 거대한 힘이 함께 걷는다.',
    'boss_orc_general_study':
        '대장군의 맹공에서 전투의 본능을 배운다. 그 기세가 몸에 새겨진다.',
    'boss_orc_general_consume':
        '대장군의 분노를 받아들인다. 억누를 수 없는 힘이 맥동한다.',
    'boss_orc_general_protect':
        '상처 입은 대장군을 부축한다. 거친 숨이 서서히 잦아든다.',
    // 4층 — 뱀파이어 군주
    'boss_vampire_lord_slay':
        '뱀파이어 군주가 재로 흩어진다. 핏빛 눈동자의 빛이 꺼진다.',
    'boss_vampire_lord_liberate':
        '군주가 고개를 숙인다. 굴복한 밤의 지배자가 어둠 속으로 물러난다.',
    'boss_vampire_lord_coexist':
        '군주가 손을 내민다. 영원한 밤의 사냥꾼이 네 곁을 지킨다.',
    'boss_vampire_lord_study':
        '군주의 흡혈과 유혹의 수를 간파한다. 그 기술이 몸에 스민다.',
    'boss_vampire_lord_consume':
        '군주의 피를 받아들인다. 밤의 굶주림이 핏줄을 타고 퍼진다.',
    'boss_vampire_lord_protect':
        '지친 군주를 어둠으로 감싼다. 핏빛 눈동자가 천천히 감긴다.',
    // 5층 — 태초의 주인
    'boss_dungeon_master_slay':
        '태초의 주인이 무너진다. 심층 전체가 무겁게 가라앉는다.',
    'boss_dungeon_master_liberate':
        '태초의 주인이 눈을 감는다. 굴복한 지배자가 심연으로 물러난다.',
    'boss_dungeon_master_coexist':
        '태초의 주인이 자리를 내어준다. 심층의 지배자가 너와 함께 걷기로 한다.',
    'boss_dungeon_master_study':
        '태초의 주인의 근원을 이해한다. 심층의 본질이 몸에 새겨진다.',
    'boss_dungeon_master_consume':
        '태초의 주인의 힘을 받아들인다. 심연의 야성이 몸 깊이 각인된다.',
    'boss_dungeon_master_protect':
        '상처 입은 태초의 주인을 감싼다. 오랜 짐승이 깊은 숨을 고른다.',
  };
}
