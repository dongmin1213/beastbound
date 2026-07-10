import 'package:equatable/equatable.dart';

/// 방 환경 단서 — 서술 텍스트에 포함되어 관찰 시 전술 힌트를 제공.
/// 크로스도메인 타입: narrative가 제공, combat이 활용 (Story 2-5).
class EnvironmentClue extends Equatable {
  final String id;
  final String description;
  final String actionHint;

  const EnvironmentClue({
    required this.id,
    required this.description,
    required this.actionHint,
  });

  @override
  List<Object?> get props => [id, description, actionHint];
}
