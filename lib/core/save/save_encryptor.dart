import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import 'package:soul_dungeon/core/error/game_error.dart';
import 'package:soul_dungeon/core/error/result.dart';

/// AES-256-CBC 세이브 암호화/복호화.
///
/// 형식: `ENC:<IV-base64>:<ciphertext-base64>`
/// 키: 앱 시크릿 + 디바이스 키 → SHA-256 → 32바이트.
/// IV: 저장마다 랜덤 생성.
class SaveEncryptor {
  SaveEncryptor._();

  static const _marker = 'ENC:';

  /// 런타임 조합 — APK 정적 분석 대비 기본 난독화.
  /// 보안 모델: 오프라인 게임 세이브 변조 방지 수준 (군사급 보안 불필요).
  static String get _appSecret {
    const parts = ['soul_dun', 'geon_sa', 've_2024', '_v1_key'];
    return parts.join();
  }

  /// 평문 암호화. [deviceKey]는 디바이스 고유 ID.
  static String encrypt(String plaintext, String deviceKey) {
    final key = _deriveKey(deviceKey);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '$_marker${iv.base64}:${encrypted.base64}';
  }

  /// 암호문 복호화. [deviceKey]는 암호화 시 사용한 동일 키.
  static Result<String> decrypt(String ciphertext, String deviceKey) {
    if (!isEncrypted(ciphertext)) {
      return Failure(const GameError(
        message: 'Data is not encrypted',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }
    final payload = ciphertext.substring(_marker.length);
    final separatorIndex = payload.indexOf(':');
    if (separatorIndex < 0) {
      return Failure(const GameError(
        message: 'Invalid encrypted format',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }
    final ivBase64 = payload.substring(0, separatorIndex);
    final dataBase64 = payload.substring(separatorIndex + 1);

    try {
      final key = _deriveKey(deviceKey);
      final iv = IV.fromBase64(ivBase64);
      final encrypted = Encrypted.fromBase64(dataBase64);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      return Success(encrypter.decrypt(encrypted, iv: iv));
    } catch (e) {
      return Failure(GameError(
        message: 'Decryption failed: $e',
        severity: ErrorSeverity.recoverable,
        system: 'save',
        cause: e,
      ));
    }
  }

  /// 암호화 여부 판별 (`ENC:` 접두사).
  static bool isEncrypted(String data) => data.startsWith(_marker);

  /// 앱 시크릿 + 디바이스 키 → AES-256 키 파생 (SHA-256 = 32바이트 = 256비트).
  static Key _deriveKey(String deviceKey) {
    final combined = '$_appSecret:$deviceKey';
    final hash = sha256.convert(utf8.encode(combined));
    return Key(Uint8List.fromList(hash.bytes));
  }
}
