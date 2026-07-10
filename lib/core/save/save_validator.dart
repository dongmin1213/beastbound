import 'dart:convert';

import 'package:crypto/crypto.dart';

/// SHA-256 체크섬 생성 및 검증.
class SaveValidator {
  SaveValidator._();

  /// 데이터의 SHA-256 체크섬 생성.
  static String checksum(String data) {
    final bytes = utf8.encode(data);
    return sha256.convert(bytes).toString();
  }

  /// 체크섬 검증.
  static bool validate(String data, String expectedChecksum) {
    return checksum(data) == expectedChecksum;
  }
}
