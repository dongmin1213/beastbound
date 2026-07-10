import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

void main() {
  group('JobPath', () {
    test('has exactly 23 job paths (6 basic + 3 hidden + 9 advanced + 5 combo)', () {
      expect(JobPath.values.length, 23);
    });

    test('20 jobs are not hidden (6 basic + 9 advanced + 5 combo)', () {
      final visibleJobs =
          JobPath.values.where((job) => !job.isHidden).toList();
      expect(visibleJobs.length, 20);
    });

    test('3 hidden jobs are hidden', () {
      final hiddenJobs =
          JobPath.values.where((job) => job.isHidden).toList();
      expect(hiddenJobs.length, 3);
    });

    test('each basic job has a unique dominant axis', () {
      final basicJobs =
          JobPath.values.where((job) => !job.isHidden).toList();
      final axes = basicJobs.map((job) => job.dominantAxis).toSet();
      expect(axes.length, 6);
      expect(axes, containsAll(DispositionAxis.values));
    });

    test('each job has a unique id', () {
      final ids = JobPath.values.map((job) => job.id).toSet();
      expect(ids.length, 23);
    });

    test('Warrior properties are correct', () {
      const warrior = Warrior();
      expect(warrior.id, 'warrior');
      expect(warrior.displayName, '전사');
      expect(warrior.dominantAxis, DispositionAxis.struggle);
      expect(warrior.specialActionType, 'powerStrike');
      expect(warrior.isHidden, isFalse);
    });

    test('Saint properties are correct', () {
      const saint = Saint();
      expect(saint.id, 'saint');
      expect(saint.displayName, '성자');
      expect(saint.dominantAxis, DispositionAxis.mercy);
    });

    test('Sage properties are correct', () {
      const sage = Sage();
      expect(sage.id, 'sage');
      expect(sage.dominantAxis, DispositionAxis.wisdom);
    });

    test('Assassin properties are correct', () {
      const assassin = Assassin();
      expect(assassin.id, 'assassin');
      expect(assassin.dominantAxis, DispositionAxis.shadow);
    });

    test('Guardian properties are correct', () {
      const guardian = Guardian();
      expect(guardian.id, 'guardian');
      expect(guardian.dominantAxis, DispositionAxis.will);
    });

    test('Wanderer properties are correct', () {
      const wanderer = Wanderer();
      expect(wanderer.id, 'wanderer');
      expect(wanderer.dominantAxis, DispositionAxis.harmony);
    });

    test('hidden jobs have real display names', () {
      const reaper = Reaper();
      const illusionist = Illusionist();
      const harmonist = Harmonist();
      expect(reaper.displayName, '사신');
      expect(illusionist.displayName, '환술사');
      expect(harmonist.displayName, '조율사');
    });

    test('switch exhaustiveness covers all 23 subclasses', () {
      for (final job in JobPath.values) {
        final result = switch (job) {
          // 1차 기본 (6)
          Warrior() => 'warrior',
          Saint() => 'saint',
          Sage() => 'sage',
          Assassin() => 'assassin',
          Guardian() => 'guardian',
          Wanderer() => 'wanderer',
          // 히든 (3)
          Reaper() => 'reaper',
          Illusionist() => 'illusionist',
          Harmonist() => 'harmonist',
          // 2차 상위직 (9)
          SwordSaint() => 'swordSaint',
          HighPriest() => 'highPriest',
          Archmage() => 'archmage',
          ShadowLord() => 'shadowLord',
          IronFortress() => 'ironFortress',
          FateTraveler() => 'fateTraveler',
          NetherKing() => 'netherKing',
          DimensionMage() => 'dimensionMage',
          OneWithAll() => 'oneWithAll',
          // 2차 조합직 (5)
          SpellBlade() => 'spellBlade',
          HolyKnight() => 'holyKnight',
          DarkMage() => 'darkMage',
          DarkKnight() => 'darkKnight',
          Arbiter() => 'arbiter',
        };
        expect(result, isNotEmpty);
      }
    });

    test('const constructors work', () {
      const a = Warrior();
      const b = Warrior();
      expect(identical(a, b), isTrue);
    });

    test('toJson returns id-based map', () {
      const warrior = Warrior();
      expect(warrior.toJson(), {'id': 'warrior'});
    });

    test('fromJson/toJson roundtrip for all jobs', () {
      for (final job in JobPath.values) {
        final json = job.toJson();
        final restored = JobPath.fromJson(json);
        expect(restored, isNotNull);
        expect(restored!.id, job.id);
        expect(identical(restored, job), isTrue);
      }
    });

    test('fromJson with unknown id returns null', () {
      expect(JobPath.fromJson({'id': 'nonexistent'}), isNull);
    });

    test('fromJson with missing id returns null', () {
      expect(JobPath.fromJson(<String, dynamic>{}), isNull);
    });
  });
}
