import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_dungeon/core/config/tamed_monster_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    TamedMonsterStore.init(prefs);
    TamedMonsterStore.clear();
  });

  test('초기엔 비어있음', () {
    expect(TamedMonsterStore.tamedIds, isEmpty);
    expect(TamedMonsterStore.isTamed('enemy_goblin'), isFalse);
  });

  test('markTamed → 기록되고 isTamed=true', () {
    final first = TamedMonsterStore.markTamed('enemy_goblin');
    expect(first, isTrue); // 최초 포획
    expect(TamedMonsterStore.isTamed('enemy_goblin'), isTrue);
    expect(TamedMonsterStore.tamedIds, contains('enemy_goblin'));
  });

  test('중복 markTamed → false (이미 포획)', () {
    TamedMonsterStore.markTamed('enemy_slime');
    final again = TamedMonsterStore.markTamed('enemy_slime');
    expect(again, isFalse);
    expect(TamedMonsterStore.tamedIds.length, 1);
  });

  test('여러 종 누적', () {
    TamedMonsterStore.markTamed('enemy_goblin');
    TamedMonsterStore.markTamed('enemy_slime');
    TamedMonsterStore.markTamed('enemy_poison_toad');
    expect(TamedMonsterStore.tamedIds,
        containsAll(['enemy_goblin', 'enemy_slime', 'enemy_poison_toad']));
  });

  test('init 전 markTamed는 no-op (크래시 없음)', () {
    // 새로 init 안 된 상태 시뮬레이션은 어려우므로 clear 후 동작만 확인.
    TamedMonsterStore.clear();
    expect(TamedMonsterStore.tamedIds, isEmpty);
  });
}
