/// 한국어 조사 처리 유틸리티.
///
/// 받침 유무에 따라 올바른 조사를 선택한다.
class KoreanParticles {
  KoreanParticles._();

  /// 마지막 글자에 받침이 있는지 판별.
  static bool _hasBatchim(String text) {
    if (text.isEmpty) return false;
    final lastChar = text.codeUnitAt(text.length - 1);
    // 한글 유니코드 범위: 0xAC00 ~ 0xD7A3
    if (lastChar < 0xAC00 || lastChar > 0xD7A3) return false;
    // (코드 - 0xAC00) % 28 == 0 이면 받침 없음
    return (lastChar - 0xAC00) % 28 != 0;
  }

  /// "으로" / "로" 선택.
  ///
  /// 받침 있으면 "으로", 없으면 "로".
  /// 단, 받침이 ㄹ이면 "로" (한국어 특수 규칙).
  static String euro(String noun) {
    if (noun.isEmpty) return '으로';
    final lastChar = noun.codeUnitAt(noun.length - 1);
    if (lastChar < 0xAC00 || lastChar > 0xD7A3) return '으로';
    final jongseong = (lastChar - 0xAC00) % 28;
    // 0 = 받침 없음 → "로"
    // 8 = ㄹ 받침 → "로"
    if (jongseong == 0 || jongseong == 8) return '로';
    return '으로';
  }

  /// "을" / "를" 선택.
  static String eulReul(String noun) {
    return _hasBatchim(noun) ? '을' : '를';
  }

  /// "이" / "가" 선택.
  static String iGa(String noun) {
    return _hasBatchim(noun) ? '이' : '가';
  }

  /// "은" / "는" 선택.
  static String eunNeun(String noun) {
    return _hasBatchim(noun) ? '은' : '는';
  }
}
