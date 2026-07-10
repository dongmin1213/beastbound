import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/save/save_encryptor.dart';

void main() {
  group('SaveEncryptor', () {
    const deviceKey = 'test-device-001';

    test('encrypt → decrypt 왕복: 짧은 문자열', () {
      const plaintext = 'hello world';
      final encrypted = SaveEncryptor.encrypt(plaintext, deviceKey);
      final result = SaveEncryptor.decrypt(encrypted, deviceKey);
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, plaintext);
    });

    test('encrypt → decrypt 왕복: JSON 데이터', () {
      const plaintext = '{"name":"player","hp":80,"gold":100}';
      final encrypted = SaveEncryptor.encrypt(plaintext, deviceKey);
      final result = SaveEncryptor.decrypt(encrypted, deviceKey);
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, plaintext);
    });

    test('encrypt → decrypt 왕복: 특수문자 포함', () {
      const plaintext = 'Special: 한글, \u{1F3AE}, \n\t, "quotes", \'apostrophe\'';
      final encrypted = SaveEncryptor.encrypt(plaintext, deviceKey);
      final result = SaveEncryptor.decrypt(encrypted, deviceKey);
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, plaintext);
    });

    test('isEncrypted: 암호문은 true', () {
      const plaintext = 'test data';
      final encrypted = SaveEncryptor.encrypt(plaintext, deviceKey);
      expect(SaveEncryptor.isEncrypted(encrypted), isTrue);
      expect(encrypted.startsWith('ENC:'), isTrue);
    });

    test('isEncrypted: 평문은 false', () {
      const plaintext = '{"data":"not encrypted"}';
      expect(SaveEncryptor.isEncrypted(plaintext), isFalse);
    });

    test('다른 deviceKey는 다른 암호문 생성', () {
      const plaintext = 'same plaintext';
      final encrypted1 = SaveEncryptor.encrypt(plaintext, 'device-A');
      final encrypted2 = SaveEncryptor.encrypt(plaintext, 'device-B');

      expect(encrypted1, isNot(equals(encrypted2)));

      // 각자 올바른 키로 복호화
      final result1 = SaveEncryptor.decrypt(encrypted1, 'device-A');
      final result2 = SaveEncryptor.decrypt(encrypted2, 'device-B');
      expect(result1, isA<Success<String>>());
      expect((result1 as Success<String>).data, plaintext);
      expect(result2, isA<Success<String>>());
      expect((result2 as Success<String>).data, plaintext);
    });

    test('잘못된 deviceKey로 복호화 시 Failure', () {
      const plaintext = 'secret data';
      final encrypted = SaveEncryptor.encrypt(plaintext, 'correct-key');

      final result = SaveEncryptor.decrypt(encrypted, 'wrong-key');
      expect(result, isA<Failure<String>>());
      expect(
        (result as Failure<String>).error.message,
        contains('Decryption failed'),
      );
    });

    test('평문을 decrypt 시도 시 Failure', () {
      const plaintext = 'not encrypted data';
      final result = SaveEncryptor.decrypt(plaintext, deviceKey);
      expect(result, isA<Failure<String>>());
      expect(
        (result as Failure<String>).error.message,
        'Data is not encrypted',
      );
    });

    test('빈 문자열 암호화 시 예외 발생', () {
      const plaintext = '';
      // AES-CBC PKCS7 패딩으로 빈 문자열 암호화는 실패할 수 있음
      expect(
        () => SaveEncryptor.encrypt(plaintext, deviceKey),
        throwsA(isA<RangeError>()),
      );
    });

    test('긴 문자열(1000+ chars) 암호화 및 복호화', () {
      final plaintext = 'A' * 1234;
      final encrypted = SaveEncryptor.encrypt(plaintext, deviceKey);
      final result = SaveEncryptor.decrypt(encrypted, deviceKey);
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, plaintext);
      expect(encrypted.length, greaterThan(100)); // 암호화로 길이 증가 확인
    });

    test('동일 평문을 여러 번 암호화 시 다른 IV로 다른 암호문 생성', () {
      const plaintext = 'same content';
      final encrypted1 = SaveEncryptor.encrypt(plaintext, deviceKey);
      final encrypted2 = SaveEncryptor.encrypt(plaintext, deviceKey);

      // IV가 매번 랜덤 생성되므로 암호문이 달라야 함
      expect(encrypted1, isNot(equals(encrypted2)));

      // 둘 다 복호화 가능
      final result1 = SaveEncryptor.decrypt(encrypted1, deviceKey);
      final result2 = SaveEncryptor.decrypt(encrypted2, deviceKey);
      expect(result1, isA<Success<String>>());
      expect((result1 as Success<String>).data, plaintext);
      expect(result2, isA<Success<String>>());
      expect((result2 as Success<String>).data, plaintext);
    });

    test('잘못된 암호문 형식 (구분자 없음) → Failure', () {
      // ENC: 접두사는 있지만 IV:data 구분자가 없는 경우
      final result = SaveEncryptor.decrypt('ENC:nodataformat', deviceKey);
      expect(result, isA<Failure<String>>());
      expect(
        (result as Failure<String>).error.message,
        'Invalid encrypted format',
      );
    });
  });
}
