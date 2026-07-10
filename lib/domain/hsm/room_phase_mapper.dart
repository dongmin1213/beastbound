import 'package:soul_dungeon/domain/hsm/states/game_phase.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// RoomType → GamePhase 매핑.
/// combat/elite 모두 CombatPhase로 매핑 (엘리트도 전투 Phase).
class RoomPhaseMapper {
  RoomPhaseMapper._();

  static GamePhase toPhase(RoomType type) => switch (type) {
        RoomType.combat => const CombatPhase(),
        RoomType.elite => const CombatPhase(),
        RoomType.event => const EventPhase(),
        RoomType.shop => const ShopPhase(),
        RoomType.rest => const RestPhase(),
        RoomType.boss => const BossPhase(),
        RoomType.npc => const NpcPhase(),
        RoomType.mystery => const MysteryPhase(),
      };
}
