import 'dart:math';

import 'package:soul_dungeon/domain/build/data/curse_pool.dart';
import 'package:soul_dungeon/core/models/devil_deal_data.dart';

/// 악마의 거래 생성기 — 층별 확률 기반 거래 제공.
///
/// 시드 기반 결정론적 생성 (같은 시드 → 같은 결과).
class DevilDealGenerator {
  DevilDealGenerator._();

  /// 현재 층에서 악마의 거래를 제공할지 여부.
  ///
  /// [floor]: 현재 층 (1~5)
  /// [floorStart]: 거래가 시작되는 최소 층 (기본 2)
  /// [probability]: 거래 확률 (0.0~1.0, 기본 0.15)
  /// [seed]: 결정론적 난수 시드
  static bool shouldOffer({
    required int floor,
    int floorStart = 2,
    double probability = 0.15,
    required int seed,
  }) {
    if (floor < floorStart) return false;
    final rng = Random(seed);
    return rng.nextDouble() < probability;
  }

  /// 악마의 거래 1개 선택. 이미 보유한 축복은 제외.
  ///
  /// [ownedBlessingIds]: 이미 보유한 축복 ID 목록
  /// [seed]: 결정론적 난수 시드
  /// 반환: 거래 데이터 (모든 거래가 제외되면 null)
  static DevilDealData? generateDeal({
    List<String> ownedBlessingIds = const [],
    required int seed,
  }) {
    final available = CursePool.deals
        .where((d) => !ownedBlessingIds.contains(d.blessingId))
        .toList();
    if (available.isEmpty) return null;

    final rng = Random(seed);
    return available[rng.nextInt(available.length)];
  }
}
