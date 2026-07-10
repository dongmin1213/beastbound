import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

/// RunBloc 이벤트 — sealed class (Dart 3 switch exhaustiveness).
sealed class RunEvent {
  const RunEvent();
}

/// 런 초기화 — 최대 HP로 시작.
final class InitializeRun extends RunEvent {
  final int maxHp;
  const InitializeRun({required this.maxHp});
}

/// 골드 획득 — 현재 금화에 amount 추가.
final class GainGold extends RunEvent {
  final int amount;
  const GainGold(this.amount);
}

/// 골드 직접 설정 — 상점/NPC 종료 시 잔여 금화 동기화.
final class SetGold extends RunEvent {
  final int gold;
  const SetGold(this.gold);
}

/// HP 변경 — delta만큼 증감 (양수=회복, 음수=피해). clamp(0, maxHp).
final class ChangeHp extends RunEvent {
  final int delta;
  const ChangeHp(this.delta);
}

/// 최대 HP 증가 — 휴식 방 축복 강화 등.
final class ChangeMaxHp extends RunEvent {
  final int delta;
  const ChangeMaxHp(this.delta);
}

/// 전투 결과 동기화 — CombatBloc의 최종 PlayerRunState에서
/// 전투가 권한을 가진 필드(HP, maxHp, masterDeck, removedCardIds)만 반영.
/// 경제/진행 필드(gold, disposition, blessings, relics, curses, floor 등)는
/// 전투 중 별도 이벤트(GainGold 등)로 이미 RunBloc에 반영되어 있으므로 무시.
final class SyncFromCombat extends RunEvent {
  final PlayerRunState playerRunState;
  const SyncFromCombat(this.playerRunState);
}

/// 전체 상태 직접 설정 — 보스 페이즈 전환, 테스트 헬퍼 등.
final class SetPlayerRunState extends RunEvent {
  final PlayerRunState playerRunState;
  const SetPlayerRunState(this.playerRunState);
}

/// 런 리셋 — 퍼마데스 후 재시작.
final class ResetRun extends RunEvent {
  final int maxHp;
  const ResetRun({required this.maxHp});
}

/// 성향 변경 — 이벤트/엘리트 선택 시 성향 포인트 누적.
final class ChangeDisposition extends RunEvent {
  final Map<DispositionAxis, int> deltas;
  const ChangeDisposition(this.deltas);
}

/// 직업 ID 설정 — 성향 임계치 도달 시 직업 분화.
final class SetJobId extends RunEvent {
  final String jobId;
  const SetJobId(this.jobId);
}

/// 축복 획득 — 상점/NPC 구매 시 축복 ID 추가.
final class AcquireBlessing extends RunEvent {
  final String blessingId;
  const AcquireBlessing(this.blessingId);
}

/// 유물 획득 — 축복+유물 획득 경로 통합.
final class AcquireRelic extends RunEvent {
  final String relicId;
  const AcquireRelic(this.relicId);
}

/// 저주 적용 — 악마의 거래로 저주 ID 추가.
final class ApplyCurse extends RunEvent {
  final String curseId;
  const ApplyCurse(this.curseId);
}

/// 다음 층 진행 — 보스 승리 + 선택 후 currentFloor++ + completedFloors 기록.
/// maxFloor 도달 시 RunCompletedEvent 발행.
final class AdvanceFloor extends RunEvent {
  final int maxFloor;
  const AdvanceFloor({this.maxFloor = 5});
}

/// 보스 선택 기록 — 보스 승리 후 3선택지(처치/해방/공존) 결과 저장.
final class RecordBossChoice extends RunEvent {
  final BossChoice bossChoice;
  const RecordBossChoice(this.bossChoice);
}
