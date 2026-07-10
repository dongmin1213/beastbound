import 'package:soul_dungeon/core/models/boss_choice.dart';

/// 보스 3선택지 결과 텍스트 변형.
///
/// 5보스 × 3선택지 기본 텍스트 + 직업별 변형.
class BossTextVariants {
  BossTextVariants._();

  /// 보스 선택 결과 텍스트.
  /// [bossId] = 보스 ID (boss_slime_king 등).
  /// [choiceType] = 선택 유형.
  /// [jobId] = 플레이어 직업 (null → generic).
  static String choiceResultText(
    String bossId,
    BossChoiceType choiceType, {
    String? jobId,
  }) {
    // 직업별 변형 우선 조회
    if (jobId != null) {
      final jobText = _jobVariant(bossId, choiceType, jobId);
      if (jobText != null) return jobText;
    }
    // Generic 텍스트
    return _genericText(bossId, choiceType);
  }

  static String _genericText(String bossId, BossChoiceType choiceType) {
    final key = '${bossId}_${choiceType.name}';
    return _genericTexts[key] ?? _defaultText(choiceType);
  }

  static String? _jobVariant(
    String bossId,
    BossChoiceType choiceType,
    String jobId,
  ) {
    final key = '${bossId}_${choiceType.name}_$jobId';
    return _jobTexts[key];
  }

  static String _defaultText(BossChoiceType choiceType) =>
      switch (choiceType) {
        BossChoiceType.slay => '보스를 처치했다. 잔재가 흩어진다.',
        BossChoiceType.liberate =>
          '보스를 해방했다. 구속에서 풀려난 영혼이 감사를 전한다.',
        BossChoiceType.coexist =>
          '보스와 공존을 택했다. 서로의 존재를 인정하며 길을 열어준다.',
        BossChoiceType.study =>
          '보스의 본질을 꿰뚫었다. 깨달음이 마음속에 새겨진다.',
        BossChoiceType.consume =>
          '보스의 힘을 흡수했다. 어둠의 잔향이 몸에 스며든다.',
        BossChoiceType.protect =>
          '보스를 봉인했다. 단단한 결계 너머로 고요가 찾아온다.',
      };

  static const _genericTexts = <String, String>{
    // 1층: 슬라임 왕
    'boss_slime_king_slay':
        '슬라임 왕이 분해된다. 끈적한 잔해가 바닥에 흩어지며 떨리는 속삭임이 사라진다.',
    'boss_slime_king_liberate':
        '슬라임 왕의 핵에서 빛이 터져 나온다. 실패한 구원자의 영혼이 마침내 자유를 찾는다.',
    'boss_slime_king_coexist':
        '슬라임 왕이 몸을 웅크리며 길을 내어준다. 떨리는 말줄임표가 고요해진다.',
    // 2층: 거미 군주
    'boss_spider_lord_slay':
        '거미 군주의 실이 끊어진다. 거미줄로 이루어진 왕국이 무너져 내린다.',
    'boss_spider_lord_liberate':
        '거미 군주의 눈에서 눈물이 흐른다. 잊힌 기억이 되돌아오며 실이 풀려간다.',
    'boss_spider_lord_coexist':
        '거미 군주가 거미줄로 다리를 놓아준다. 잊힌 구원자의 메아리가 온기를 띤다.',
    // 3층: 오크 대장군
    'boss_orc_general_slay':
        '오크 대장군의 분노가 꺼진다. 거대한 몸이 무릎을 꿇으며 전장이 고요해진다.',
    'boss_orc_general_liberate':
        '대장군의 눈에 이성이 돌아온다. 분노에 가려져 있던 후회가 드러난다.',
    'boss_orc_general_coexist':
        '대장군이 무기를 내려놓는다. 함께 걸으며 전쟁의 무의미를 나눈다.',
    // 4층: 뱀파이어 군주
    'boss_vampire_lord_slay':
        '뱀파이어 군주의 유려한 말솜씨가 끊긴다. 재로 흩어지며 설득의 독이 사라진다.',
    'boss_vampire_lord_liberate':
        '군주의 가면이 벗겨진다. 포기했던 구원의 길을 다시 볼 수 있게 되었다.',
    'boss_vampire_lord_coexist':
        '군주가 손을 내민다. 영원한 밤 속에서 서로의 온기를 나누기로 한다.',
    // 5층: 던전 마스터
    'boss_dungeon_master_slay':
        '던전 마스터가 무너진다. 최초 구원자의 형체가 흩어지며 던전에 침묵이 내린다.',
    'boss_dungeon_master_liberate':
        '던전 마스터의 눈에서 빛이 돌아온다. 최초의 기억이 해방되며 던전이 깨어난다.',
    'boss_dungeon_master_coexist':
        '던전 마스터가 미소 짓는다. 오랜 침묵이 끝나고 함께 걸어가기로 한다.',
    // ── 신규 선택지: study (깨달음) ──
    'boss_slime_king_study':
        '슬라임 왕의 떨림 속에 숨겨진 의미를 읽어낸다. 실패한 구원자의 진심이 지혜로 전해진다.',
    'boss_spider_lord_study':
        '거미줄에 새겨진 패턴이 눈앞에서 풀린다. 거미 군주의 기억이 지식이 되어 스며든다.',
    'boss_orc_general_study':
        '대장군의 분노 이면에 감춰진 전술을 꿰뚫는다. 전쟁의 교훈이 깨달음으로 남는다.',
    'boss_vampire_lord_study':
        '군주의 유려한 말 속에 감춰진 진실을 간파한다. 영원의 비밀이 지혜로 결실 맺는다.',
    'boss_dungeon_master_study':
        '최초 구원자의 근원을 이해한다. 던전의 본질이 깨달음으로 마음에 새겨진다.',
    // ── 신규 선택지: consume (흡수) ──
    'boss_slime_king_consume':
        '슬라임 왕의 핵을 삼킨다. 끈적한 힘이 그림자처럼 몸에 스며든다.',
    'boss_spider_lord_consume':
        '거미 군주의 실을 자신의 것으로 만든다. 거미줄의 어둠이 손끝에서 피어난다.',
    'boss_orc_general_consume':
        '대장군의 분노를 흡수한다. 억누를 수 없는 힘이 그림자 속에서 맥동한다.',
    'boss_vampire_lord_consume':
        '군주의 피를 빨아들인다. 영원의 어둠이 핏줄을 타고 퍼져간다.',
    'boss_dungeon_master_consume':
        '던전 마스터의 힘을 빨아들인다. 근원의 그림자가 영혼 깊이 각인된다.',
    // ── 신규 선택지: protect (봉인) ──
    'boss_slime_king_protect':
        '슬라임 왕을 결계로 감싼다. 떨리는 속삭임이 봉인 속에서 잦아든다.',
    'boss_spider_lord_protect':
        '거미 군주를 봉인의 실로 묶는다. 잊힌 기억이 결계 속에서 안식을 찾는다.',
    'boss_orc_general_protect':
        '대장군을 굳건한 봉인으로 감싼다. 끝없는 분노가 결계 안에서 잠든다.',
    'boss_vampire_lord_protect':
        '군주를 영원한 봉인에 가둔다. 설득의 독이 결계 너머로 사라진다.',
    'boss_dungeon_master_protect':
        '던전 마스터를 봉인한다. 근원의 힘이 결계 속에서 영원히 잠든다.',
  };

  static const _jobTexts = <String, String>{
    // 전사 변형
    'boss_slime_king_slay_warrior':
        '전사의 일격이 슬라임 왕을 관통한다. 검에 묻은 끈적한 잔해가 당신의 힘을 증명한다.',
    'boss_orc_general_slay_warrior':
        '전사 대 전사. 대장군의 분노를 넘어선 투쟁의 의지가 승리를 거머쥔다.',
    'boss_dungeon_master_slay_warrior':
        '순수한 힘으로 최초 구원자를 쓰러뜨렸다. 투쟁의 끝에 남은 건 적막뿐이다.',
    // 현자 변형
    'boss_spider_lord_liberate_sage':
        '현자의 분석이 거미 군주의 잊힌 기억을 되찾아준다. 지혜가 구원의 열쇠였다.',
    'boss_vampire_lord_liberate_sage':
        '군주의 설득을 논리로 꿰뚫었다. 진실 앞에 가면은 무의미하다.',
    'boss_dungeon_master_liberate_sage':
        '지혜로 근원의 비밀을 풀었다. 최초 구원자의 기억이 마침내 자유를 찾는다.',
    // 암살자 변형
    'boss_slime_king_slay_assassin':
        '독이 슬라임 왕의 핵을 녹인다. 그림자 속에서 마무리한 깔끔한 처치다.',
    'boss_orc_general_coexist_assassin':
        '암살자가 대장군과 나란히 선다. 그림자와 힘의 공존은 예상치 못한 균형이다.',
    'boss_dungeon_master_coexist_assassin':
        '어둠 속의 존재끼리 이해한다. 그림자가 침묵과 나란히 걷는다.',
  };
}
