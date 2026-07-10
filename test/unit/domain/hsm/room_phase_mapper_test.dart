import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/hsm/room_phase_mapper.dart';
import 'package:soul_dungeon/domain/hsm/states/game_phase.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('RoomPhaseMapper', () {
    test('8개 RoomType 전체 매핑 검증', () {
      expect(RoomPhaseMapper.toPhase(RoomType.combat), isA<CombatPhase>());
      expect(RoomPhaseMapper.toPhase(RoomType.elite), isA<CombatPhase>());
      expect(RoomPhaseMapper.toPhase(RoomType.event), isA<EventPhase>());
      expect(RoomPhaseMapper.toPhase(RoomType.shop), isA<ShopPhase>());
      expect(RoomPhaseMapper.toPhase(RoomType.rest), isA<RestPhase>());
      expect(RoomPhaseMapper.toPhase(RoomType.boss), isA<BossPhase>());
      expect(RoomPhaseMapper.toPhase(RoomType.npc), isA<NpcPhase>());
      expect(RoomPhaseMapper.toPhase(RoomType.mystery), isA<MysteryPhase>());
    });

    test('elite → CombatPhase 확인 (엘리트도 전투 Phase)', () {
      final phase = RoomPhaseMapper.toPhase(RoomType.elite);
      expect(phase, isA<CombatPhase>());
      expect(phase, equals(const CombatPhase()));
    });
  });
}
