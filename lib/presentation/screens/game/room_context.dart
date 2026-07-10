import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/dungeon/bloc/dungeon_bloc.dart';
import 'package:soul_dungeon/presentation/screens/game/game_run_controller.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 5종 Room Handler의 공통 의존성 컨테이너.
///
/// 함수 참조(`getDungeonBloc`, `getUserScrolledUp`)를 사용하는 이유:
/// RoomContext는 initState에서 한 번 생성되지만, DungeonBloc은 nullable이고
/// 조건부 생성되므로 생성 시점에 값이 확정되지 않음. 함수 참조로 지연 평가하여
/// 호출 시점의 최신 값을 반환. 직접 참조로 변경하면 null 참조 버그 발생 위험.
class RoomContext {
  final GameRunController runController;
  final void Function(List<TextBlockData>, {bool endCombat}) setTextBlockData;
  final VoidCallback notifyStateChanged;
  final DungeonBloc? Function() getDungeonBloc;
  final bool Function() getUserScrolledUp;
  final VoidCallback scrollToBottom;

  const RoomContext({
    required this.runController,
    required this.setTextBlockData,
    required this.notifyStateChanged,
    required this.getDungeonBloc,
    required this.getUserScrolledUp,
    required this.scrollToBottom,
  });
}
