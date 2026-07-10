import 'package:flutter/material.dart';

/// 카드 전투 3단 레이아웃 컨테이너.
///
/// [enemyArea] (상단) — 적 정보 + 의도 + 상태효과
/// [combatLog] (중앙, Expanded) — 전투 텍스트 로그
/// [playerArea] (하단) — 플레이어 HP/AP/덱 카운터 + 상태효과
/// [cardHand] (하단) — 카드 선택지
/// [actionButtons] (최하단) — 턴 종료/도주 버튼
class CombatLayoutWidget extends StatelessWidget {
  final Widget enemyArea;
  final Widget combatLog;
  final Widget playerArea;
  final Widget cardHand;
  final Widget? actionButtons;

  const CombatLayoutWidget({
    super.key,
    required this.enemyArea,
    required this.combatLog,
    required this.playerArea,
    required this.cardHand,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단: 적 영역
        enemyArea,
        // 중앙: 전투 로그 (확장)
        Expanded(child: combatLog),
        // 하단: 플레이어 상태
        playerArea,
        // 카드 핸드
        cardHand,
        // 액션 버튼
        ?actionButtons,
      ],
    );
  }
}
