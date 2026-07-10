/// 세이브 데이터 저장소 추상 인터페이스 — 테스트용 교체 가능.
abstract class SaveStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// 인메모리 구현 — 테스트용.
class InMemorySaveStorage implements SaveStorage {
  final _data = <String, String>{};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}
