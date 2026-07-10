import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/save/save_validator.dart';

void main() {
  group('SaveValidator', () {
    test('checksum 일관성 — 같은 데이터 → 같은 해시', () {
      const data = '{"hp":100,"gold":50}';
      final hash1 = SaveValidator.checksum(data);
      final hash2 = SaveValidator.checksum(data);
      expect(hash1, hash2);
    });

    test('checksum — 다른 데이터 → 다른 해시', () {
      final hash1 = SaveValidator.checksum('data_a');
      final hash2 = SaveValidator.checksum('data_b');
      expect(hash1, isNot(hash2));
    });

    test('validate — 올바른 체크섬 → true', () {
      const data = '{"test":"value"}';
      final hash = SaveValidator.checksum(data);
      expect(SaveValidator.validate(data, hash), isTrue);
    });

    test('validate — 틀린 체크섬 → false', () {
      expect(SaveValidator.validate('data', 'wrong_hash'), isFalse);
    });

    test('validate — 변조된 데이터 → false', () {
      const original = '{"hp":100}';
      final hash = SaveValidator.checksum(original);
      const tampered = '{"hp":999}';
      expect(SaveValidator.validate(tampered, hash), isFalse);
    });

    test('checksum — 빈 문자열', () {
      final hash = SaveValidator.checksum('');
      expect(hash, isNotEmpty);
      expect(hash.length, 64); // SHA-256 = 64 hex chars
    });

    test('checksum — 한글 데이터', () {
      final hash = SaveValidator.checksum('소울 던전 세이브');
      expect(hash.length, 64);
      expect(SaveValidator.validate('소울 던전 세이브', hash), isTrue);
    });
  });
}
