import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/domain/combat/content/monster_passives.dart';
void main() {
  test('보스 15종 무브풀+패시브 유효', () {
    const bosses = ['boss_slime_king','boss_sewer_croc','boss_rat_monarch','boss_spider_lord','boss_warden_chief','boss_ghost_convict','boss_orc_general','boss_crystal_golem','boss_mana_overload','boss_vampire_lord','boss_arch_demon','boss_corrupt_high_priest','boss_dungeon_master','boss_void_sovereign','boss_dimension_collapser'];
    for (final b in bosses) {
      expect(MonsterCards.hasMovepool(b), isTrue, reason: '$b no movepool');
      expect(MonsterPassives.forMonster(b).isNone, isFalse, reason: '$b no passive');
      for (final id in MonsterCards.movepoolIds(b)) {
        expect(CardPool.findById(id), isNotNull, reason: '$b -> $id missing');
      }
    }
  });
}
