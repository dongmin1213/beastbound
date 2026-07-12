import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_event.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_state.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_bloc.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_event.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_state.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/presentation/screens/game/room_context.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

class RestRoomHandler {
  final RoomContext _ctx;
  final RestConfig restConfig;

  /// 소울 업그레이드 추가 휴식 회복률.
  final double bonusHealRate;

  RestBloc? _restBloc;
  bool _showingRest = false;

  RestBloc? get bloc => _restBloc;
  bool get isShowing => _showingRest;

  RestRoomHandler({
    required RoomContext context,
    required this.restConfig,
    this.bonusHealRate = 0.0,
  }) : _ctx = context;

  void enter(DungeonRoomEntered dState) {
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '따뜻한 빛이 감도는 방이다. 잠시 쉬어갈 수 있을 것 같다.',
      ),
    ]);

    _restBloc?.close();
    _restBloc = RestBloc(
      gameEventBus: _ctx.runController.gameEventBus,
      restConfig: restConfig,
      bonusHealRate: bonusHealRate,
    );
    _restBloc!.add(EnterRest(
      currentHp: _ctx.runController.playerRunState.currentHp,
      maxHp: _ctx.runController.playerRunState.maxHp,
    ));

    _showingRest = true;
    _ctx.notifyStateChanged();

    if (kDebugMode) {
      GameLogger.debug(LogSystem.dungeon,
          'Rest entered: hp=${_ctx.runController.playerRunState.currentHp}/${_ctx.runController.playerRunState.maxHp}');
    }
  }

  void onClosed(RestClosed state) {
    final rc = _ctx.runController;

    // 피드백 텍스트 결정
    final String feedbackText;
    if (state.hpRecovered > 0) {
      feedbackText = '체력이 ${state.hpRecovered} 회복되었다! 야성이 초기화되었다.';
    } else if (state.maxHpIncreased > 0) {
      feedbackText = '최대 체력이 ${state.maxHpIncreased} 증가했다! 야성이 초기화되었다.';
    } else {
      feedbackText = '잠시 쉬어갔다. 야성이 초기화되었다.';
    }

    // HP 회복 (maxHp 초과 방지)
    if (state.hpRecovered > 0) {
      final newHp = (rc.playerRunState.currentHp + state.hpRecovered)
          .clamp(0, rc.playerRunState.maxHp);
      rc.playerRunState = rc.playerRunState.copyWith(currentHp: newHp);
      rc.runBloc.add(ChangeHp(state.hpRecovered));
    }

    // maxHp 강화 (상한 클램프)
    if (state.maxHpIncreased > 0) {
      final newMaxHp =
          (rc.playerRunState.maxHp + state.maxHpIncreased).clamp(1, 9999);
      rc.playerRunState = rc.playerRunState.copyWith(maxHp: newMaxHp);
      rc.runBloc.add(ChangeMaxHp(state.maxHpIncreased));
    }

    _showingRest = false;
    rc.completedBlocks.add(CompletedBlock(text: feedbackText));
    _ctx.notifyStateChanged();

    if (!_ctx.getUserScrolledUp()) {
      _ctx.scrollToBottom();
    }

    _restBloc?.close();
    _restBloc = null;
    _ctx.getDungeonBloc()?.add(const CompleteRoom());
  }

  void enterForTest({int? withHp, int? withMaxHp}) {
    final rc = _ctx.runController;
    if (withHp != null) {
      rc.playerRunState = rc.playerRunState.copyWith(currentHp: withHp);
    }
    if (withMaxHp != null) {
      rc.playerRunState = rc.playerRunState.copyWith(maxHp: withMaxHp);
    }
    rc.syncToRunBloc();
    _ctx.setTextBlockData([
      const TextBlockData(
        text: '따뜻한 빛이 감도는 방이다. 잠시 쉬어갈 수 있을 것 같다.',
      ),
    ]);
    _restBloc?.close();
    _restBloc = RestBloc(
      gameEventBus: rc.gameEventBus,
      restConfig: restConfig,
      bonusHealRate: bonusHealRate,
    );
    _restBloc!.add(EnterRest(
      currentHp: rc.playerRunState.currentHp,
      maxHp: rc.playerRunState.maxHp,
    ));
    _showingRest = true;
    _ctx.notifyStateChanged();
  }

  void dispose() {
    _restBloc?.close();
  }
}
