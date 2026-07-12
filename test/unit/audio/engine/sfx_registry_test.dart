import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/audio/engine/sfx_registry.dart';

void main() {
  group('SfxRegistry', () {
    group('pathFor', () {
      test('registered ID returns asset path', () {
        expect(
          SfxRegistry.pathFor('card_attack'),
          'assets/audio/sfx/card_attack.ogg',
        );
        expect(
          SfxRegistry.pathFor('combat_victory'),
          'assets/audio/sfx/combat_victory.ogg',
        );
      });

      test('unregistered ID returns null', () {
        expect(SfxRegistry.pathFor('nonexistent'), isNull);
        expect(SfxRegistry.pathFor(''), isNull);
      });
    });

    group('sfxForCardType', () {
      test('attack -> card_attack', () {
        expect(SfxRegistry.sfxForCardType('attack'), 'card_attack');
      });

      test('skill -> card_skill', () {
        expect(SfxRegistry.sfxForCardType('skill'), 'card_skill');
      });

      test('power -> card_power', () {
        expect(SfxRegistry.sfxForCardType('power'), 'card_power');
      });

      test('unknown -> card_skill (default)', () {
        expect(SfxRegistry.sfxForCardType('unknown'), 'card_skill');
        expect(SfxRegistry.sfxForCardType(''), 'card_skill');
      });
    });

    group('sfxForStatusEffect', () {
      test('poison -> status_poison', () {
        expect(SfxRegistry.sfxForStatusEffect('poison'), 'status_poison');
      });

      test('burn -> status_burn', () {
        expect(SfxRegistry.sfxForStatusEffect('burn'), 'status_burn');
      });

      test('strength -> status_buff', () {
        expect(SfxRegistry.sfxForStatusEffect('strength'), 'status_buff');
      });

      test('dexterity -> status_buff', () {
        expect(SfxRegistry.sfxForStatusEffect('dexterity'), 'status_buff');
      });

      test('thorn -> status_buff', () {
        expect(SfxRegistry.sfxForStatusEffect('thorn'), 'status_buff');
      });

      test('regenerate -> status_buff', () {
        expect(SfxRegistry.sfxForStatusEffect('regenerate'), 'status_buff');
      });

      test('weak -> status_debuff', () {
        expect(SfxRegistry.sfxForStatusEffect('weak'), 'status_debuff');
      });

      test('vulnerable -> status_debuff', () {
        expect(SfxRegistry.sfxForStatusEffect('vulnerable'), 'status_debuff');
      });

      test('unknown -> status_debuff (default)', () {
        expect(SfxRegistry.sfxForStatusEffect('unknown'), 'status_debuff');
      });
    });

    group('sfxForCombatMilestone', () {
      test('sfxForCombatMilestone maps correctly', () {
        expect(SfxRegistry.sfxForCombatMilestone('hit'), 'combat_hit');
        expect(SfxRegistry.sfxForCombatMilestone('block'), 'combat_block');
        expect(SfxRegistry.sfxForCombatMilestone('victory'), 'combat_victory');
        expect(SfxRegistry.sfxForCombatMilestone('defeat'), 'combat_defeat');
        expect(SfxRegistry.sfxForCombatMilestone('unknown'), 'combat_hit');
      });
    });

    group('sfxForNarratorEvent', () {
      test('sfxForNarratorEvent maps correctly', () {
        expect(SfxRegistry.sfxForNarratorEvent('distortion'), 'narrator_distortion');
        expect(SfxRegistry.sfxForNarratorEvent('truth_reveal'), 'narrator_truth_reveal');
        expect(SfxRegistry.sfxForNarratorEvent('silence'), 'narrator_silence');
        expect(SfxRegistry.sfxForNarratorEvent('unknown'), 'narrator_distortion');
      });
    });

    group('narrator SFX registration', () {
      test('narrator SFX IDs are registered', () {
        expect(SfxRegistry.pathFor('narrator_distortion'), isNotNull);
        expect(SfxRegistry.pathFor('narrator_truth_reveal'), isNotNull);
        expect(SfxRegistry.pathFor('narrator_silence'), isNotNull);
      });
    });

    group('allIds', () {
      test('returns at least 16 IDs', () {
        expect(SfxRegistry.allIds.length, greaterThanOrEqualTo(16));
      });

      test('contains expected IDs', () {
        final ids = SfxRegistry.allIds;
        expect(ids, contains('card_attack'));
        expect(ids, contains('card_skill'));
        expect(ids, contains('card_power'));
        expect(ids, contains('deck_shuffle'));
        expect(ids, contains('combat_victory'));
        expect(ids, contains('ui_select'));
      });
    });

    group('count', () {
      test('total registry count includes narrator', () {
        expect(SfxRegistry.count, 31); // 28 + 3 narrator
      });

      test('matches allIds length', () {
        expect(SfxRegistry.count, SfxRegistry.allIds.length);
      });
    });
  });
}
