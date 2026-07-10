import 'package:soul_dungeon/core/models/game_enums.dart';

/// RoomType별 감각 단서 텍스트 생성기.
///
/// 미니맵 대신 텍스트 선택지로 경로를 선택할 때,
/// 각 방 타입에 맞는 분위기 묘사를 제공한다.
/// nodeId.hashCode 시드로 동일 노드 = 동일 설명 보장.
class PathDescriptionGenerator {
  const PathDescriptionGenerator._();

  static const _descriptions = <RoomType, List<String>>{
    RoomType.combat: [
      '무기 부딪히는 소리가 들려오는 통로',
      '피비린내가 희미하게 나는 어두운 길',
      '낮은 으르렁거림이 울려 퍼지는 방향',
      '긁히는 발톱 소리가 메아리치는 복도',
      '날카로운 금속 냄새가 코를 찌르는 길',
      '부서진 방패가 나뒹구는 통로',
      '거친 숨소리가 어둠 속에서 새어 나오는 방향',
      '핏자국이 바닥에 이어지는 길',
      '쇠사슬이 부딪히는 둔탁한 소리가 나는 통로',
      '누군가의 신음 소리가 희미하게 들리는 방향',
    ],
    RoomType.elite: [
      '⚠ 살기가 느껴지는 어두운 통로',
      '⚠ 강렬한 적의가 감도는 위험한 길',
      '⚠ 뼈가 흩어진 으스스한 방향',
      '⚠ 벽에 깊은 할퀸 자국이 새겨진 통로',
      '⚠ 공기 자체가 무겁게 짓누르는 길',
      '⚠ 으스러진 갑옷 조각이 널린 방향',
      '⚠ 어둠 속에서 빛나는 눈이 보이는 통로',
      '⚠ 바닥이 검게 그을린 위험한 길',
      '⚠ 주변의 횃불이 두려움에 떨듯 흔들리는 방향',
      '⚠ 선명한 파괴의 흔적이 남아있는 통로',
    ],
    RoomType.shop: [
      '딸랑이는 소리가 들리는 문',
      '따뜻한 등불이 비치는 통로',
      '무언가를 거래하는 속삭임이 들리는 방향',
      '동전 소리가 경쾌하게 울리는 길',
      '진열된 물건들의 윤기가 빛나는 방향',
      '향긋한 약초 냄새가 풍기는 통로',
      '가죽과 금속 냄새가 섞여 나오는 문',
      '정돈된 선반이 보이는 밝은 방향',
      '흥정하는 목소리가 어렴풋이 들리는 길',
      '유리병이 부딪히는 맑은 소리가 나는 통로',
    ],
    RoomType.rest: [
      '잔잔한 물소리가 들리는 방향',
      '부드러운 빛이 새어 나오는 통로',
      '고요하고 평화로운 기운이 감도는 길',
      '깨끗한 공기가 흘러나오는 방향',
      '작은 모닥불의 온기가 느껴지는 통로',
      '이끼 낀 바위 사이로 샘물이 흐르는 길',
      '은은한 꽃향기가 퍼지는 고요한 방향',
      '새의 지저귐이 아득히 들려오는 통로',
      '바람이 부드럽게 스치는 안온한 길',
      '촛불이 조용히 타오르는 따스한 방향',
    ],
    RoomType.event: [
      '기이한 기운이 감도는 통로',
      '무언가 특별한 일이 일어날 것 같은 방향',
      '미지의 에너지가 느껴지는 길',
      '벽에 의미를 알 수 없는 문양이 새겨진 통로',
      '공기가 미세하게 진동하는 이상한 방향',
      '발밑에서 희미한 빛이 맥동하는 길',
      '시간이 느리게 흐르는 듯한 기묘한 통로',
      '어딘가에서 종소리가 울려 퍼지는 방향',
      '바닥의 돌이 규칙적으로 빛나는 길',
      '낯선 향이 감도는 수상한 통로',
    ],
    RoomType.mystery: [
      '안개가 자욱한 신비로운 통로',
      '호기심을 자극하는 이상한 기운의 길',
      '보랏빛 빛이 깜빡이는 방향',
      '현실이 왜곡된 듯 흔들리는 통로',
      '벽면이 거울처럼 반짝이는 기이한 길',
      '발소리가 메아리 없이 사라지는 방향',
      '무지개빛 입자가 떠다니는 통로',
      '차원의 균열 같은 빛줄기가 새어 나오는 길',
      '눈앞의 공간이 일그러져 보이는 방향',
      '설명할 수 없는 끌림이 느껴지는 통로',
    ],
    RoomType.npc: [
      '누군가의 기척이 느껴지는 방향',
      '조용한 발소리가 들리는 통로',
      '사람의 온기가 느껴지는 길',
      '작은 기침 소리가 들려오는 방향',
      '누군가 노래를 흥얼거리는 통로',
      '옷자락이 스치는 소리가 나는 길',
      '대화 소리가 멀리서 들리는 방향',
      '익숙한 인기척이 감도는 통로',
      '그림자가 벽에 비치는 길',
      '누군가 기다리고 있는 듯한 방향',
    ],
    RoomType.boss: [
      '⚠ 압도적인 위압감이 느껴지는 거대한 문',
      '⚠ 모든 길이 이끄는 마지막 방향',
      '⚠ 어둠의 심장부로 이어지는 통로',
      '⚠ 대지가 미세하게 떨리는 거대한 길',
      '⚠ 주변의 빛마저 삼키는 칠흑의 방향',
      '⚠ 되돌아갈 수 없을 것 같은 웅장한 문',
      '⚠ 숨 막히는 압박감이 온몸을 짓누르는 통로',
      '⚠ 벽의 균열에서 붉은 빛이 새어 나오는 방향',
      '⚠ 절대적인 존재의 기운이 감도는 길',
      '⚠ 운명의 끝자락이 느껴지는 마지막 통로',
    ],
  };

  /// 방 타입 → 한글 라벨 매핑.
  static const _typeLabels = <RoomType, String>{
    RoomType.combat: '전투',
    RoomType.elite: '정예',
    RoomType.event: '이벤트',
    RoomType.mystery: '미스터리',
    RoomType.shop: '상점',
    RoomType.npc: 'NPC',
    RoomType.rest: '휴식',
    RoomType.boss: '보스',
  };

  /// [nodeId].hashCode를 시드로 사용 → 동일 노드는 항상 같은 설명.
  static String describe(RoomType type, String nodeId) {
    final pool = _descriptions[type] ?? ['알 수 없는 통로'];
    final index = nodeId.hashCode.abs() % pool.length;
    final label = _typeLabels[type] ?? '???';
    return '[$label] ${pool[index]}';
  }

  /// 같은 타입의 노드가 여러 개일 때 중복 없이 설명을 배정.
  ///
  /// [(type, nodeId)] 목록을 받아 {nodeId: description} 맵을 반환.
  /// 같은 타입끼리 겹치지 않도록 이미 사용된 인덱스를 건너뛴다.
  static Map<String, String> describeAll(
    List<(RoomType type, String nodeId)> nodes,
  ) {
    final result = <String, String>{};
    // 타입별로 이미 사용된 인덱스 추적
    final usedIndices = <RoomType, Set<int>>{};

    for (final (type, nodeId) in nodes) {
      final pool = _descriptions[type] ?? ['알 수 없는 통로'];
      final used = usedIndices.putIfAbsent(type, () => <int>{});

      var index = nodeId.hashCode.abs() % pool.length;

      // 이미 사용된 인덱스면 다음 빈 인덱스 탐색
      if (used.contains(index)) {
        for (var i = 0; i < pool.length; i++) {
          final candidate = (index + i) % pool.length;
          if (!used.contains(candidate)) {
            index = candidate;
            break;
          }
        }
      }

      used.add(index);
      final label = _typeLabels[type] ?? '???';
      result[nodeId] = '[$label] ${pool[index]}';
    }

    return result;
  }
}
