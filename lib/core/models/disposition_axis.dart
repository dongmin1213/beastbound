/// 6축 성향 시스템 — 캐릭터 빌드와 직업 분화의 기반.
enum DispositionAxis {
  struggle('투쟁'),
  mercy('자비'),
  wisdom('지혜'),
  shadow('그림자'),
  will('의지'),
  harmony('조화');

  final String displayName;
  const DispositionAxis(this.displayName);
}
