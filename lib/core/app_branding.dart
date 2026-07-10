/// 게임 브랜딩 — 이름/부제/버전을 한 곳에서 관리.
///
/// **작업명(working title).** 정식 이름 확정 시 이 파일의 값만 교체하면
/// 타이틀·메타 화면 등 전역에 반영된다.
class AppBranding {
  AppBranding._();

  /// 게임 이름 (작업명). 몬스터 테이밍 덱빌더.
  static const String title = 'BEASTBOUND';

  /// 부제/태그라인 — 핵심 훅.
  static const String tagline = '싸운 적이 곧 나의 덱이 된다';

  /// 버전 (신규 프로젝트 — 프리릴리즈).
  static const String version = 'v0.1.0';
}
