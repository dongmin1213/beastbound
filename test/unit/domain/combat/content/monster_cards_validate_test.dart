import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';

void main() {
  test('모든 몬스터 무브풀 id가 실제 카드로 해석됨 (오타 탐지)', () {
    final allMonsters = [
      ...FloorEnemies.floor1Normal, ...FloorEnemies.floor1Elite,
      ...FloorEnemies.floor2Normal, ...FloorEnemies.floor2Elite,
      ...FloorEnemies.floor3Normal, ...FloorEnemies.floor3Elite,
      ...FloorEnemies.floor4Normal, ...FloorEnemies.floor4Elite,
      ...FloorEnemies.floor5Normal, ...FloorEnemies.floor5Elite,
    ];
    final bad = <String>[];
    var withPool = 0;
    for (final m in allMonsters) {
      final ids = MonsterCards.movepoolIds(m.id);
      if (ids.isNotEmpty) withPool++;
      for (final id in ids) {
        if (CardPool.findById(id) == null) bad.add('${m.id} -> $id');
      }
    }
    // ignore: avoid_print
    print('무브풀 보유 몬스터: $withPool / ${allMonsters.length}');
    expect(bad, isEmpty, reason: '해석 안 되는 카드 id: $bad');
  });
}
