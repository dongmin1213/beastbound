import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// MomentumBloc 이벤트 (sealed class — switch exhaustiveness 보장)
sealed class MomentumEvent extends Equatable {
  const MomentumEvent();
}

/// 플레이어가 행동을 수행함 → 야성 변동 계산 트리거
final class ActionPerformed extends MomentumEvent {
  final ActionType actionType;

  const ActionPerformed(this.actionType);

  @override
  List<Object?> get props => [actionType];
}

/// 카드 플레이됨 → 카드 전투 야성 변동 (동일 유형 페널티 없음)
final class CardPlayed extends MomentumEvent {
  final CardType cardType;

  const CardPlayed(this.cardType);

  @override
  List<Object?> get props => [cardType];
}

/// 야성 직접 증가 (야성 충전 카드 등)
final class DirectMomentumGain extends MomentumEvent {
  final int amount;

  const DirectMomentumGain(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// 야성 초기화 (전투 시작 시 / 휴식 방 선택 시)
final class MomentumReset extends MomentumEvent {
  const MomentumReset();

  @override
  List<Object?> get props => [];
}

/// 저장된 야성 상태 복원 (이어하기 시)
final class RestoreMomentum extends MomentumEvent {
  final int value;
  final int consecutiveCount;

  const RestoreMomentum({
    required this.value,
    this.consecutiveCount = 0,
  });

  @override
  List<Object?> get props => [value, consecutiveCount];
}
