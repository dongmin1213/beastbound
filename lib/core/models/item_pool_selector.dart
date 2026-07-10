import 'dart:math';

/// 아이템 풀에서 중복 방지 선택 유틸리티.
///
/// NpcGenerator / ShopItemGenerator 공통 로직 추출.
class ItemPoolSelector {
  ItemPoolSelector._();

  /// [pool]에서 중복 방지하며 항목 선택.
  ///
  /// [usedIndices]: 이미 선택된 인덱스 집합 (선택 시 자동 추가).
  /// [rng]: PRNG.
  /// 풀 소진 시 중복 허용 폴백.
  static T selectFromPool<T>(
    List<T> pool,
    Set<int> usedIndices,
    Random rng,
  ) {
    final availableIndices = <int>[
      for (var i = 0; i < pool.length; i++)
        if (!usedIndices.contains(i)) i,
    ];
    if (availableIndices.isEmpty) {
      if (pool.isEmpty) {
        throw StateError('ItemPoolSelector: pool must not be empty');
      }
      return pool[rng.nextInt(pool.length)];
    }
    final idx = availableIndices[rng.nextInt(availableIndices.length)];
    usedIndices.add(idx);
    return pool[idx];
  }
}
