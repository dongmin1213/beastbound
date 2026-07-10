/// 유령 NPC 반응 레벨 — 현재 플레이어와의 유사도에 따라 결정.
enum GhostReactionLevel {
  /// 높은 유사도 — 친밀한 반응.
  familiar,

  /// 중간 유사도 — 관심 있는 반응.
  curious,

  /// 낮은 유사도 — 냉담한 반응.
  distant;

  String get displayName => switch (this) {
        GhostReactionLevel.familiar => '익숙함',
        GhostReactionLevel.curious => '호기심',
        GhostReactionLevel.distant => '무관심',
      };
}
