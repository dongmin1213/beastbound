/// 5가지 엔딩 유형.
enum EndingType {
  slay('처치', '비극적 결말'),
  liberate('해방', '희망의 결말'),
  coexist('공존', '온기의 결말'),
  hidden('히든', '해방의 결말'),
  transcend('초월', '근원의 결말');

  final String displayName;
  final String toneDescription;
  const EndingType(this.displayName, this.toneDescription);
}
