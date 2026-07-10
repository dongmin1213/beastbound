import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

/// 직업별 이벤트 추가 선택지 오버레이.
///
/// 기존 12 이벤트에 직업별 추가 선택지를 제공.
/// 매칭 없으면 null → 기본 이벤트 유지.
class JobEventVariants {
  JobEventVariants._();

  /// 이벤트 제목 + 직업 ID로 변형 선택지 조회.
  static EventChoice? getVariant(String eventTitle, String? jobId) {
    if (jobId == null) return null;
    final key = '${eventTitle}_$jobId';
    return _variants[key];
  }

  static final _variants = <String, EventChoice>{
    // 전사 → "전사의 유령": 전용 전투 결과
    '전사의 유령_warrior': const EventChoice(
      label: '전사의 긍지로 맞선다',
      outcomeText: '유령이 당신의 투지를 인정한다. 검의 무게가 가벼워진 기분이다.',
      goldChange: 0,
      hpChange: -3,
      upgradeRandomCard: true,
      dispositionRewards: {
        DispositionAxis.struggle: 2,
      },
    ),
    // 현자 → "수정 동굴": 지혜 기반
    '수정 동굴_sage': const EventChoice(
      label: '수정의 공명을 분석한다',
      outcomeText: '현자의 통찰로 수정의 비밀을 풀었다. 마력이 몸에 스며든다.',
      goldChange: 15,
      hpChange: 5,
      dispositionRewards: {
        DispositionAxis.wisdom: 2,
      },
    ),
    // 암살자 → "수상한 상인": 그림자 기반
    '수상한 상인_assassin': const EventChoice(
      label: '그림자 속에서 뒤를 잡는다',
      outcomeText: '상인의 뒤를 잡았다. 숨겨둔 진짜 상품을 손에 넣었다.',
      goldChange: 20,
      hpChange: 0,
      dispositionRewards: {
        DispositionAxis.shadow: 3,
      },
    ),
    // 성자 → "깨진 제단": 자비 기반
    '깨진 제단_saint': const EventChoice(
      label: '신성한 기도를 올린다',
      outcomeText: '성자의 기도에 제단이 반응한다. 따뜻한 빛이 상처를 치유한다.',
      goldChange: 0,
      hpChange: 15,
      dispositionRewards: {
        DispositionAxis.mercy: 3,
      },
    ),
    // 수호자 → "잊혀진 보물상자": 보호 기반
    '잊혀진 보물상자_guardian': const EventChoice(
      label: '방패로 함정을 막는다',
      outcomeText: '수호자의 방패가 함정을 완벽히 막았다. 보물을 온전히 가져간다.',
      goldChange: 25,
      hpChange: 0,
      dispositionRewards: {
        DispositionAxis.will: 2,
      },
    ),
    // 방랑자 → "이상한 거래": 카오스 기반
    '이상한 거래_wanderer': const EventChoice(
      label: '운에 맡기고 눈을 감는다',
      outcomeText: '랜덤의 신이 미소 짓는다. 예상치 못한 보상이 쏟아진다.',
      goldChange: 10,
      hpChange: 10,
      cardRewardId: 'colorless_random',
      dispositionRewards: {
        DispositionAxis.harmony: 2,
      },
    ),
  };
}
