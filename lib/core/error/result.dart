import 'package:soul_dungeon/core/error/game_error.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final GameError error;
  const Failure(this.error);
}
