/// 층(floor) ↔ 지역(region) 매핑.
///
/// BEASTBOUND은 5개 감정 영역(폐허/동굴/감옥/사원/심연)이 각각 2개 층에 걸친다.
/// 서사·바이옴은 5지역 단위(변하지 않음), 구조·플레이타임은 10층 단위.
///
/// - 층 1·2 → 지역 1 (폐허), 3·4 → 지역 2 (동굴), …, 9·10 → 지역 5 (심연)
/// - 각 지역의 **첫 층**(홀수)은 탐색+하위 주인(정예 보스), **둘째 층**(짝수)은 지역의 주인(보스).
class FloorRegion {
  FloorRegion._();

  /// 총 층 수 (5지역 × 2층).
  static const int totalFloors = 10;

  /// 지역 수.
  static const int regionCount = 5;

  /// 층 → 지역 번호 (1~5). 범위 밖은 1~5로 클램프.
  static int of(int floor) {
    final r = ((floor - 1) ~/ 2) + 1;
    return r < 1 ? 1 : (r > regionCount ? regionCount : r);
  }

  /// 지역 내 몇 번째 층인가 (1 = 첫 층/정예, 2 = 둘째 층/주인).
  static int stageInRegion(int floor) => ((floor - 1) % 2) + 1;

  /// 이 층이 지역의 '주인'(메인 보스) 층인가 (짝수층).
  static bool isRegionLord(int floor) => floor % 2 == 0;

  /// 이 층이 최종 층인가 (심연의 주인).
  static bool isFinalFloor(int floor) => floor >= totalFloors;
}
