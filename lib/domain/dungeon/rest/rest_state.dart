import 'package:equatable/equatable.dart';

/// RestBloc 상태 — sealed class (Dart 3 switch exhaustiveness).
sealed class RestState extends Equatable {
  const RestState();
}

/// 초기 상태 — 휴식 미시작.
final class RestInitial extends RestState {
  const RestInitial();

  @override
  List<Object?> get props => [];
}

/// 휴식 준비 완료 — HP 현황 및 선택지 효과 표시.
final class RestReady extends RestState {
  final int currentHp;
  final int maxHp;
  final int healAmount;
  final int upgradeAmount;

  const RestReady({
    required this.currentHp,
    required this.maxHp,
    required this.healAmount,
    required this.upgradeAmount,
  });

  @override
  List<Object?> get props => [currentHp, maxHp, healAmount, upgradeAmount];
}

/// 휴식 종료 — 선택 결과.
final class RestClosed extends RestState {
  final int hpRecovered;
  final int maxHpIncreased;

  const RestClosed({
    required this.hpRecovered,
    required this.maxHpIncreased,
  });

  @override
  List<Object?> get props => [hpRecovered, maxHpIncreased];
}

/// 기억 탐색 중 — 기억 조각 내용 표시 + 복귀용 RestReady 데이터 보존.
final class MemoryExploring extends RestState {
  final String memoryId;
  final String memoryTitle;
  final String memoryDescription;
  // 복귀용 RestReady 데이터
  final int currentHp;
  final int maxHp;
  final int healAmount;
  final int upgradeAmount;

  const MemoryExploring({
    required this.memoryId,
    required this.memoryTitle,
    required this.memoryDescription,
    required this.currentHp,
    required this.maxHp,
    required this.healAmount,
    required this.upgradeAmount,
  });

  @override
  List<Object?> get props => [
        memoryId,
        memoryTitle,
        memoryDescription,
        currentHp,
        maxHp,
        healAmount,
        upgradeAmount,
      ];
}
