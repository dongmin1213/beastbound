/// 한글 자모 분해/조합기
///
/// Unicode Hangul Syllables (0xAC00~0xD7A3) 범위의 글자를
/// 초성→초성+중성→초성+중성+종성 순서로 분해하여 타자기 효과에 사용.
class JamoDecomposer {
  static const int _sBase = 0xAC00; // '가'
  static const int _lBase = 0x1100; // 초성 ㄱ
  static const int _lCount = 19;
  static const int _vCount = 21;
  static const int _tCount = 28; // 0 = 종성 없음
  static const int _nCount = _vCount * _tCount; // 588
  static const int _sCount = _lCount * _nCount; // 11172

  /// 순방향 조합: "각" → [ㄱ, 가, 각]
  /// 비한글 문자는 [char] 그대로 반환.
  List<String> decompose(String char) {
    if (char.isEmpty) return [];
    final code = char.codeUnitAt(0);
    if (!_isSyllable(code)) return [char];

    final sIndex = code - _sBase;
    final lIndex = sIndex ~/ _nCount;
    final vIndex = (sIndex % _nCount) ~/ _tCount;
    final tIndex = sIndex % _tCount;

    final steps = <String>[];

    // 1) 초성만
    steps.add(String.fromCharCode(_lBase + lIndex));

    // 2) 초성 + 중성 (종성 없는 음절)
    final lv = _sBase + (lIndex * _nCount) + (vIndex * _tCount);
    steps.add(String.fromCharCode(lv));

    // 3) 초성 + 중성 + 종성 (종성이 있는 경우만)
    if (tIndex > 0) {
      steps.add(String.fromCharCode(lv + tIndex));
    }

    return steps;
  }

  /// 역분해: "각" → [각, 가, ㄱ] (E8 dissolve 연출 대비)
  List<String> reverse(String char) {
    return decompose(char).reversed.toList();
  }

  bool _isSyllable(int code) {
    return code >= _sBase && code < _sBase + _sCount;
  }
}
