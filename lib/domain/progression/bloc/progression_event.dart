import 'package:equatable/equatable.dart';

/// ProgressionBloc 이벤트 — 메타 진행 상태 변경 요청.
sealed class ProgressionEvent extends Equatable {
  const ProgressionEvent();
}

/// 메타 세이브 데이터 로드.
final class LoadProgression extends ProgressionEvent {
  const LoadProgression();

  @override
  List<Object?> get props => [];
}

/// 소울 획득 (사망/클리어 보상).
final class GainSoul extends ProgressionEvent {
  final int amount;
  const GainSoul(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// 소울 업그레이드 구매.
final class PurchaseUpgrade extends ProgressionEvent {
  final String upgradeId;
  const PurchaseUpgrade(this.upgradeId);

  @override
  List<Object?> get props => [upgradeId];
}

/// 사망 기록 (deathCount + totalRuns 증가 + 유령 풀 등록).
final class RecordDeath extends ProgressionEvent {
  final int floorReached;

  /// 유령 풀에 추가할 사망 캐릭터 데이터 (raw JSON).
  /// core는 domain(GhostNpcData)에 의존할 수 없으므로 Map으로 저장.
  final Map<String, dynamic>? ghostDataRaw;

  const RecordDeath({required this.floorReached, this.ghostDataRaw});

  @override
  List<Object?> get props => [floorReached, ghostDataRaw];
}

/// 런 완료 기록 (엔딩 + totalRuns + clearCount 증가).
final class RecordRunCompletion extends ProgressionEvent {
  final String endingName;

  /// 런 완료 시점의 직업 ID (null = 미분화).
  final String? jobId;

  const RecordRunCompletion({required this.endingName, this.jobId});

  @override
  List<Object?> get props => [endingName, jobId];
}

/// 기억 조각 해금.
final class UnlockMemory extends ProgressionEvent {
  final String memoryId;
  const UnlockMemory(this.memoryId);

  @override
  List<Object?> get props => [memoryId];
}

/// 완전 초기화 — 모든 메타 진행 데이터(소울, 업그레이드, 해금 등) 삭제.
final class ResetAllProgression extends ProgressionEvent {
  const ResetAllProgression();

  @override
  List<Object?> get props => [];
}
