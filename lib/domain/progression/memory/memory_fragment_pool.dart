import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';

/// 기억 조각 15장 — 4범주(기원/상실/유대/순환) 콘텐츠 풀.
///
/// BEASTBOUND 메타 서사: 첫 유대(잃어버린 첫 파트너)에 집착하던 테이머가,
/// 여러 유대를 죄책감 없이 순환시키는 법을 배워가는 여정. 휴식 방 "기억 탐색"으로 확인.
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
    // ── 기원 (Origin) — 4장: 첫 유대, 내려온 이유 ──
    MemoryFragment(
      id: 'origin_01',
      category: MemoryCategory.origin,
      title: '첫 번째 발걸음',
      description: '심층으로 내려온 이유를 기억한다. '
          '처음 함께한 야수를 잃은 뒤, 그가 남긴 길을 따라 여기까지 왔다.',
      unlockCondition: 'first_run',
    ),
    MemoryFragment(
      id: 'origin_02',
      category: MemoryCategory.origin,
      title: '이름 대신 온기',
      description: '첫 파트너의 이름은 흐릿해졌지만, '
          '곁에 웅크리던 온기만은 또렷하다. 그 하나로 여기까지 왔다.',
      unlockCondition: 'reach_floor_2',
    ),
    MemoryFragment(
      id: 'origin_03',
      category: MemoryCategory.origin,
      title: '서로가 서로를 골랐다',
      description: '그때 내가 그를 고른 게 아니었다. '
          '눈이 마주친 순간, 서로가 서로를 골랐다. 시작은 늘 그렇게 조용했다.',
      unlockCondition: 'reach_floor_3',
    ),
    MemoryFragment(
      id: 'origin_04',
      category: MemoryCategory.origin,
      title: '스스로 택한 길',
      description: '누구도 등을 떠밀지 않았다. '
          '심층으로 내려가기로 한 건 나 자신이었다. 그래서 이 여정은 온전히 내 몫이다.',
      unlockCondition: 'complete_5_runs',
    ),
    // ── 상실 (Loss) — 4장: 첫 파트너를 잃음/놓아줌 ──
    MemoryFragment(
      id: 'loss_01',
      category: MemoryCategory.loss,
      title: '빈 자리',
      description: '곁에는 늘 한 자리가 비어 있다. 처음 함께 걷던 그 자리. '
          '새 동료가 들어서도 그 모양만은 지워지지 않는다.',
      unlockCondition: 'first_death',
    ),
    MemoryFragment(
      id: 'loss_02',
      category: MemoryCategory.loss,
      title: '의존이라는 이름',
      description: '그가 너무 강해서, 나는 자라지 못했다. '
          '그를 잃고서야 처음으로 내 발로 섰다. 상실은 뒤늦게 찾아온 성장통이었다.',
      unlockCondition: 'die_3_times',
    ),
    MemoryFragment(
      id: 'loss_03',
      category: MemoryCategory.loss,
      title: '지키지 못한 말',
      description: "'곧 돌아올게.' 마지막으로 건넨 말이었다. "
          '지키지 못한 게 나였는지 그였는지, 아직도 모른다.',
      unlockCondition: 'reach_floor_4',
    ),
    MemoryFragment(
      id: 'loss_04',
      category: MemoryCategory.loss,
      title: '식어가는 온기',
      description: '손끝에 남은 온기가 천천히 식어간다. '
          '이제 그 열기는 기억 속에만 있다. 그래도 기억은 식지 않는다.',
      unlockCondition: 'die_5_times',
    ),
    // ── 유대 (Bond) — 4장: 새 동료와의 유대 ──
    MemoryFragment(
      id: 'bond_01',
      category: MemoryCategory.bond,
      title: '명령이 아니라',
      description: "언젠가 나는 길들임을 명령으로 착각했다. "
          "'좋은 파트너'를 '말 잘 듣는 도구'로 바꿔버린 밤들. 다시는 그러지 않기로 한다.",
      unlockCondition: 'meet_ghost',
    ),
    MemoryFragment(
      id: 'bond_02',
      category: MemoryCategory.bond,
      title: '주인의 눈',
      description: '쓰러진 영역의 주인, 그 눈에 적의는 없었다. '
          '제 자리를 지키던 상처 입은 짐승이었을 뿐. 나와 다르지 않았다.',
      unlockCondition: 'liberate_boss',
    ),
    MemoryFragment(
      id: 'bond_03',
      category: MemoryCategory.bond,
      title: '함께 걸은 발자국',
      description: '바위에 두 줄의 발자국. 한 줄은 나의 것, 다른 한 줄은 지금 곁을 걷는 동료의 것. '
          '첫 파트너의 자리를 이제 다른 온기가 채운다.',
      unlockCondition: 'coexist_boss',
    ),
    MemoryFragment(
      id: 'bond_04',
      category: MemoryCategory.bond,
      title: '끊어지지 않는 실',
      description: '나와 동료들을 잇는 보이지 않는 실. '
          '장착을 풀어도, 도감 깊이 잠들어도, 그 실은 끊어지지 않는다.',
      unlockCondition: 'complete_3_runs',
    ),
    // ── 순환 (Cycle) — 3장: 여러 유대를 순환시키는 법 ──
    MemoryFragment(
      id: 'cycle_01',
      category: MemoryCategory.cycle,
      title: '반복 속의 차이',
      description: '이 길을 전에도 걸었다. 이 주인도 전에 만났다. '
          '하지만 곁에 선 동료가 다르면, 같은 길도 전혀 다른 길이 된다.',
      unlockCondition: 'complete_2_runs',
    ),
    MemoryFragment(
      id: 'cycle_02',
      category: MemoryCategory.cycle,
      title: '심층의 고동',
      description: '심층 깊은 곳에서 고동이 들린다. 이 야생은 살아 있고, 무언가를 기다린다. '
          '어쩌면 나를, 어쩌면 내가 놓아준 그를.',
      unlockCondition: 'reach_floor_5',
    ),
    MemoryFragment(
      id: 'cycle_03',
      category: MemoryCategory.cycle,
      title: '맹세를 내려놓다',
      description: '첫 파트너와의 맹세가 실은 서로를 옭아맨 족쇄였음을 이제 안다. '
          '하나를 영원히 붙잡는 대신 매번 다른 셋과 걷는 법을 배운다. '
          '그것이 그가 남긴 마지막 유대의 방식이었다.',
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
