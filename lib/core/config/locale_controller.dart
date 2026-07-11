import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 언어(로케일) 컨트롤러 — SharedPreferences 영속.
///
/// 지원 언어: 한국어(ko), 영어(en). null 저장 시 시스템 로케일 따름.
/// MaterialApp.locale에 [locale]을 연결하고, [setLocale]로 전환한다.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController._(super.value);

  static const _key = 'app_locale';
  static const supported = <Locale>[Locale('ko'), Locale('en')];

  static LocaleController? _instance;
  static LocaleController get instance =>
      _instance ??= LocaleController._(null);

  /// 앱 시작 시 저장된 언어를 로드.
  static Future<void> init(SharedPreferences prefs) async {
    final code = prefs.getString(_key);
    instance.value =
        (code == 'ko' || code == 'en') ? Locale(code!) : null; // null=시스템
  }

  /// 언어 전환 + 영속. null → 시스템 언어 따름.
  Future<void> setLocale(Locale? locale) async {
    if (value == locale) return;
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
