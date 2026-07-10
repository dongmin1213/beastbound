import 'package:soul_dungeon/core/logging/game_logger.dart';

/// balance.json 값 검증 공유 유틸리티 (double).
/// 범위 밖이면 fallback 반환 + 경고 로그.
/// [fieldName]은 로그 메시지에 포함되어 어떤 필드가 잘못됐는지 식별.
double clampDouble(
  dynamic value,
  double min,
  double max,
  double fallback,
  String fieldName,
) {
  if (value is num && value >= min && value <= max) return value.toDouble();
  GameLogger.warning(
    LogSystem.core,
    'Invalid $fieldName: $value (range $min~$max), using fallback: $fallback',
  );
  return fallback;
}

/// balance.json 값 검증 공유 유틸리티 (int).
/// 범위 밖이면 fallback 반환 + 경고 로그.
/// [fieldName]은 로그 메시지에 포함되어 어떤 필드가 잘못됐는지 식별.
int clampInt(
  dynamic value,
  int min,
  int max,
  int fallback,
  String fieldName,
) {
  if (value is int && value >= min && value <= max) return value;
  GameLogger.warning(
    LogSystem.core,
    'Invalid $fieldName: $value (range $min~$max), using fallback: $fallback',
  );
  return fallback;
}
