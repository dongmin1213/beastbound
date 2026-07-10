import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

/// 한 캐릭터의 상태별 스프라이트 경로 묶음.
///
/// [idle]만 있으면 나머지 상태는 트랜스폼 연출로 대체된다(현재 방식).
/// 나중에 AI로 [attack]/[hurt]/[death] 프레임을 그려 채우면
/// `CombatActor`가 자동으로 상태별 스프라이트를 사용한다 — 씬 코드 불변.
class ActorSprites {
  /// 대기 프레임 (필수 기준). null이면 실루엣.
  final String? idle;

  /// 공격 프레임. null이면 idle + 런지 트랜스폼.
  final String? attack;

  /// 피격 프레임. null이면 idle + 붉은 플래시.
  final String? hurt;

  /// 사망 프레임. null이면 idle + 디졸브.
  final String? death;

  const ActorSprites({this.idle, this.attack, this.hurt, this.death});

  /// 현재 등록된 프레임 경로 목록 (프리로드용).
  List<String> get allPaths =>
      [idle, attack, hurt, death].whereType<String>().toList();
}

/// 전투 씬 스프라이트 해석의 **유일한 교체 지점(swap point)**.
///
/// AI로 새 아트를 만든 뒤에는 이 클래스의 경로 규칙과 `assets/`만 바꾸면
/// 씬/액터/브릿지 코드는 전혀 손대지 않아도 된다.
///
/// 교체 절차는 `docs/에셋_교체_가이드.md` 참조.
class CombatSprites {
  const CombatSprites._();

  /// 적/보스 id → 스프라이트 세트.
  ///
  /// 현재는 원작의 단일 초상화(`assets/pixel_art/...`)를 idle로 재활용.
  /// 새 아트 도입 시 이 메서드만 확장한다 (예: `_v2/enemies/$id/attack.png`).
  static ActorSprites enemy(String id) {
    return ActorSprites(
      idle: PixelArtAssets.enemySprite(id) ?? PixelArtAssets.bossSprite(id),
      // attack: _v2('enemies/$id/attack'),  ← AI 아트 도입 시 주석 해제
      // hurt:   _v2('enemies/$id/hurt'),
      // death:  _v2('enemies/$id/death'),
    );
  }

  /// 직업 id → 플레이어 스프라이트 세트.
  static ActorSprites job(String? jobId) {
    return ActorSprites(
      idle: jobId != null ? PixelArtAssets.jobSprite(jobId) : null,
    );
  }

  // 새 아트 디렉토리 규칙 (도입 시 사용):
  // static String _v2(String rel) => 'assets/pixel_art_v2/$rel.png';
}
