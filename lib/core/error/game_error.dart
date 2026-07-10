enum ErrorSeverity {
  critical,
  recoverable,
  warning,
}

class GameError {
  final String message;
  final ErrorSeverity severity;
  final String? system;
  final Object? cause;

  const GameError({
    required this.message,
    this.severity = ErrorSeverity.recoverable,
    this.system,
    this.cause,
  });

  @override
  String toString() => '[$severity] ${system != null ? '($system) ' : ''}$message';
}
