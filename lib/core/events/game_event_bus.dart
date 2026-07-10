import 'dart:async';
import 'dart:collection';

import 'package:soul_dungeon/core/events/game_event.dart';

class GameEventBus {
  final _controller = StreamController<GameEvent>.broadcast();

  static const int _historySize = 50;
  final _history = Queue<GameEvent>();
  List<GameEvent>? _historyCache;

  void emit(GameEvent event) {
    _history.addLast(event);
    if (_history.length > _historySize) {
      _history.removeFirst();
    }
    _historyCache = null; // dirty
    _controller.add(event);
  }

  Stream<T> on<T extends GameEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  List<GameEvent> get history =>
      _historyCache ??= _history.toList(growable: false);

  void dispose() {
    _controller.close();
  }
}
