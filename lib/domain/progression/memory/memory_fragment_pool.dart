import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';

/// 기억 조각 15장 — 4범주(기원/상실/유대/순환) 콘텐츠 풀.
///
/// META.md: "그 사람" 정체 점진 공개, 휴식 방 "기억 탐색"으로 확인.
/// JSON 에셋(assets/content/memory_fragments.json)에서 로드. 실패 시 기본값 폴백.

/// 기억 조각 범주.
enum MemoryCategory {
  origin('기원'),
  loss('상실'),
  bond('유대'),
  cycle('순환');

  final String displayName;
  const MemoryCategory(this.displayName);
}

/// 개별 기억 조각 데이터.
class MemoryFragment {
  final String id;
  final MemoryCategory category;
  final String title;
  final String description;
  final String unlockCondition;

  const MemoryFragment({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.unlockCondition,
  });

  factory MemoryFragment.fromJson(Map<String, dynamic> json) {
    return MemoryFragment(
      id: json['id'] as String,
      category: MemoryCategory.values.byName(json['category'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      unlockCondition: json['unlock_condition'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'title': title,
        'description': description,
        'unlock_condition': unlockCondition,
      };
}

/// 15장 기억 조각 풀.
class MemoryFragmentPool {
  MemoryFragmentPool._();

  static List<MemoryFragment> _items = _defaults;

  /// 현재 로드된 기억 조각 전체 목록.
  static List<MemoryFragment> get all => _items;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/memory_fragments.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final fragments = (json['fragments'] as List)
          .map((e) => MemoryFragment.fromJson(e as Map<String, dynamic>))
          .toList();
      _items = fragments;
      GameLogger.info(LogSystem.core, 'MemoryFragmentPool loaded: ${_items.length} fragments');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load memory_fragments.json, using defaults', e);
      _items = _defaults;
    }
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _defaults = <MemoryFragment>[
    // ── 기원 (Origin) — 4장 ──
    MemoryFragment(
      id: 'origin_01',
      category: MemoryCategory.origin,
      title: '첫 번째 발걸음',
      description: '이곳에 들어온 이유를 기억한다. '
          '누군가를 찾기 위해... 아니, 무언가를 되찾기 위해.',
      unlockCondition: 'first_run',
    ),
    MemoryFragment(
      id: 'origin_02',
      category: MemoryCategory.origin,
      title: '잊혀진 이름',
      description: '"그 사람"의 이름이 떠오를 듯 말 듯하다. '
          '입술에 맴도는 음절... 하지만 소리가 되지 않는다.',
      unlockCondition: 'reach_floor_2',
    ),
    MemoryFragment(
      id: 'origin_03',
      category: MemoryCategory.origin,
      title: '입구의 기억',
      description: '던전 입구에서 본 비문이 떠오른다. '
          '"되돌릴 수 있다"는 약속... 그것이 시작이었다.',
      unlockCondition: 'reach_floor_3',
    ),
    MemoryFragment(
      id: 'origin_04',
      category: MemoryCategory.origin,
      title: '선택의 무게',
      description: '이 던전에 발을 들인 것은 자신의 의지였다. '
          '누구도 강요하지 않았다. 그래서 더 무겁다.',
      unlockCondition: 'complete_5_runs',
    ),
    // ── 상실 (Loss) — 4장 ──
    MemoryFragment(
      id: 'loss_01',
      category: MemoryCategory.loss,
      title: '빈 자리',
      description: '돌아갈 곳에는 항상 두 개의 의자가 있었다. '
          '이제 하나는 비어 있다. 먼지가 쌓여간다.',
      unlockCondition: 'first_death',
    ),
    MemoryFragment(
      id: 'loss_02',
      category: MemoryCategory.loss,
      title: '마지막 대화',
      description: '"곧 돌아올게." 마지막으로 한 말이 그것이었다. '
          '그 말을 지키지 못한 것은 자신이었을까, 상대였을까.',
      unlockCondition: 'die_3_times',
    ),
    MemoryFragment(
      id: 'loss_03',
      category: MemoryCategory.loss,
      title: '깨진 약속',
      description: '함께 보려 했던 하늘이 있었다. '
          '계절이 바뀌어도 그 약속은 이행되지 않았다.',
      unlockCondition: 'reach_floor_4',
    ),
    MemoryFragment(
      id: 'loss_04',
      category: MemoryCategory.loss,
      title: '사라진 온기',
      description: '손끝에 남아 있던 온기가 서서히 식어간다. '
          '기억만이 그 열기를 간직하고 있다.',
      unlockCondition: 'die_5_times',
    ),
    // ── 유대 (Bond) — 4장 ──
    MemoryFragment(
      id: 'bond_01',
      category: MemoryCategory.bond,
      title: '유령의 미소',
      description: '유령이 처음으로 미소를 지었다. '
          '"당신을 알고 있어요... 예전에도 여기 왔었죠."',
      unlockCondition: 'meet_ghost',
    ),
    MemoryFragment(
      id: 'bond_02',
      category: MemoryCategory.bond,
      title: '보스의 눈물',
      description: '쓰러진 수호자의 눈에서 빛나는 것을 보았다. '
          '적이 아니었다. 그저 자기 자리를 지키고 있었을 뿐.',
      unlockCondition: 'liberate_boss',
    ),
    MemoryFragment(
      id: 'bond_03',
      category: MemoryCategory.bond,
      title: '함께 걸은 길',
      description: '던전의 벽에 새겨진 발자국 두 줄. '
          '한 줄은 자신의 것, 다른 한 줄은... "그 사람"의 것이었다.',
      unlockCondition: 'coexist_boss',
    ),
    MemoryFragment(
      id: 'bond_04',
      category: MemoryCategory.bond,
      title: '이어진 실',
      description: '"그 사람"과 자신을 잇는 보이지 않는 실. '
          '끊어지지 않는다. 이 던전 안에서도, 밖에서도.',
      unlockCondition: 'complete_3_runs',
    ),
    // ── 순환 (Cycle) — 3장 ──
    MemoryFragment(
      id: 'cycle_01',
      category: MemoryCategory.cycle,
      title: '반복의 자각',
      description: '이 복도를 전에도 걸었다. 이 적도 전에도 만났다. '
          '하지만 매번 무언가가 다르다.',
      unlockCondition: 'complete_2_runs',
    ),
    MemoryFragment(
      id: 'cycle_02',
      category: MemoryCategory.cycle,
      title: '던전의 심장',
      description: '던전의 중심에서 고동 소리가 들린다. '
          '이곳은 살아 있다. 그리고 무언가를 기다리고 있다.',
      unlockCondition: 'reach_floor_5',
    ),
    MemoryFragment(
      id: 'cycle_03',
      category: MemoryCategory.cycle,
      title: '끝이자 시작',
      description: '모든 엔딩 너머에 새로운 시작이 있다. '
          '"그 사람"이 남긴 것은 절망이 아니라... 가능성이었다.',
      unlockCondition: 'reach_3_endings',
    ),
  ];

  /// ID로 기억 조각 조회.
  static MemoryFragment? byId(String id) {
    for (final fragment in all) {
      if (fragment.id == id) return fragment;
    }
    return null;
  }

  /// 해금된 기억 조각 목록 반환.
  static List<MemoryFragment> unlockedFragments(Set<String> unlockedIds) {
    return all.where((f) => unlockedIds.contains(f.id)).toList();
  }

  /// 범주별 기억 조각 반환.
  static List<MemoryFragment> byCategory(MemoryCategory category) {
    return all.where((f) => f.category == category).toList();
  }

  /// 총 기억 조각 수.
  static int get totalCount => all.length;
}
