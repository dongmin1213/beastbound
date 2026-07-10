import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/logic/special_action_resolver.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('SpecialActionResolver', () {
    group('전사 — powerStrike', () {
      test('vs attack → effective', () {
        expect(
          SpecialActionResolver.getResult('powerStrike', EnemyActionType.attack),
          ActionResult.effective,
        );
      });

      test('vs defend → neutral', () {
        expect(
          SpecialActionResolver.getResult('powerStrike', EnemyActionType.defend),
          ActionResult.neutral,
        );
      });

      test('vs observe → effective', () {
        expect(
          SpecialActionResolver.getResult(
              'powerStrike', EnemyActionType.observe),
          ActionResult.effective,
        );
      });
    });

    group('성자 — divineHeal', () {
      test('vs attack → effective', () {
        expect(
          SpecialActionResolver.getResult(
              'divineHeal', EnemyActionType.attack),
          ActionResult.effective,
        );
      });

      test('vs defend → neutral', () {
        expect(
          SpecialActionResolver.getResult(
              'divineHeal', EnemyActionType.defend),
          ActionResult.neutral,
        );
      });

      test('vs observe → effective', () {
        expect(
          SpecialActionResolver.getResult(
              'divineHeal', EnemyActionType.observe),
          ActionResult.effective,
        );
      });
    });

    group('현자 — insight', () {
      test('vs attack → neutral', () {
        expect(
          SpecialActionResolver.getResult('insight', EnemyActionType.attack),
          ActionResult.neutral,
        );
      });

      test('vs defend → effective', () {
        expect(
          SpecialActionResolver.getResult('insight', EnemyActionType.defend),
          ActionResult.effective,
        );
      });

      test('vs observe → effective', () {
        expect(
          SpecialActionResolver.getResult('insight', EnemyActionType.observe),
          ActionResult.effective,
        );
      });
    });

    group('암살자 — shadowStrike', () {
      test('vs attack → effective', () {
        expect(
          SpecialActionResolver.getResult(
              'shadowStrike', EnemyActionType.attack),
          ActionResult.effective,
        );
      });

      test('vs defend → effective (방어 관통)', () {
        expect(
          SpecialActionResolver.getResult(
              'shadowStrike', EnemyActionType.defend),
          ActionResult.effective,
        );
      });

      test('vs observe → ineffective (간파당함)', () {
        expect(
          SpecialActionResolver.getResult(
              'shadowStrike', EnemyActionType.observe),
          ActionResult.ineffective,
        );
      });
    });

    group('수호자 — ironWall', () {
      test('vs attack → effective', () {
        expect(
          SpecialActionResolver.getResult('ironWall', EnemyActionType.attack),
          ActionResult.effective,
        );
      });

      test('vs defend → effective', () {
        expect(
          SpecialActionResolver.getResult('ironWall', EnemyActionType.defend),
          ActionResult.effective,
        );
      });

      test('vs observe → neutral', () {
        expect(
          SpecialActionResolver.getResult('ironWall', EnemyActionType.observe),
          ActionResult.neutral,
        );
      });
    });

    group('방랑자 — adapt', () {
      test('vs attack → effective', () {
        expect(
          SpecialActionResolver.getResult('adapt', EnemyActionType.attack),
          ActionResult.effective,
        );
      });

      test('vs defend → neutral', () {
        expect(
          SpecialActionResolver.getResult('adapt', EnemyActionType.defend),
          ActionResult.neutral,
        );
      });

      test('vs observe → effective', () {
        expect(
          SpecialActionResolver.getResult('adapt', EnemyActionType.observe),
          ActionResult.effective,
        );
      });
    });

    group('미등록 specialActionType', () {
      test('unknown → neutral 폴백', () {
        expect(
          SpecialActionResolver.getResult('unknown', EnemyActionType.attack),
          ActionResult.neutral,
        );
      });
    });

    group('getDisplayName', () {
      test('6개 직업 표시 이름', () {
        expect(SpecialActionResolver.getDisplayName('powerStrike'), '강타');
        expect(SpecialActionResolver.getDisplayName('divineHeal'), '신성한 치유');
        expect(SpecialActionResolver.getDisplayName('insight'), '통찰');
        expect(SpecialActionResolver.getDisplayName('shadowStrike'), '그림자 일격');
        expect(SpecialActionResolver.getDisplayName('ironWall'), '철벽');
        expect(SpecialActionResolver.getDisplayName('adapt'), '적응');
      });

      test('미등록 → "특수" 폴백', () {
        expect(SpecialActionResolver.getDisplayName('unknown'), '특수');
      });
    });

    group('getPrefix', () {
      test('6개 직업 접두사', () {
        expect(SpecialActionResolver.getPrefix('powerStrike'), '⚡ ');
        expect(SpecialActionResolver.getPrefix('divineHeal'), '✨ ');
        expect(SpecialActionResolver.getPrefix('insight'), '🔮 ');
        expect(SpecialActionResolver.getPrefix('shadowStrike'), '🗡 ');
        expect(SpecialActionResolver.getPrefix('ironWall'), '🛡 ');
        expect(SpecialActionResolver.getPrefix('adapt'), '🔄 ');
      });

      test('미등록 → "★ " 폴백', () {
        expect(SpecialActionResolver.getPrefix('unknown'), '★ ');
      });
    });

    group('getResultText', () {
      test('각 직업별 effective 텍스트', () {
        final text = SpecialActionResolver.getResultText(
            'powerStrike', EnemyActionType.observe);
        expect(text, contains('강타'));
      });

      test('미등록 specialActionType 폴백 텍스트', () {
        final text = SpecialActionResolver.getResultText(
            'unknown', EnemyActionType.attack);
        expect(text, '특수 행동을 사용했다.');
      });
    });
  });
}
