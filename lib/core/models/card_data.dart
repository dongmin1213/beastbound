import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 카드 특수 효과 — 데미지/블록 외 추가 효과.
class CardEffect extends Equatable {
  /// 효과 유형.
  final CardEffectType type;
  final int value;

  /// 조건: null = 무조건, firstTurn, lowHp, highMomentum, hasPoison.
  final String? condition;

  /// 상태 효과 지속 턴 수 (null = 영구 or 해당 없음).
  final int? duration;

  const CardEffect({
    required this.type,
    required this.value,
    this.condition,
    this.duration,
  });

  @override
  List<Object?> get props => [type, value, condition, duration];
}

/// 카드 데이터 — 텍스트 선택지로 표시되는 전투 카드.
class CardData extends Equatable {
  final String id;
  final String name;

  /// null = 공통/무색, "warrior"/"sage"/"assassin" 등.
  final String? jobId;
  final CardType type;
  final int apCost;

  /// 기본 데미지 (null = 데미지 없는 카드).
  final int? damage;

  /// 기본 블록 (null = 블록 없는 카드).
  final int? block;
  final String description;
  final bool upgraded;
  final Set<CardKeyword> keywords;
  final List<CardEffect> effects;

  /// 카드 타겟 유형 — null = single (기본값).
  final CardTargetType? targetType;

  /// 실제 타겟 타입 (null → single 폴백).
  CardTargetType get effectiveTargetType => targetType ?? CardTargetType.single;

  const CardData({
    required this.id,
    required this.name,
    this.jobId,
    required this.type,
    required this.apCost,
    this.damage,
    this.block,
    required this.description,
    this.upgraded = false,
    this.keywords = const {},
    this.effects = const [],
    this.targetType,
  });

  bool get hasKeyword => keywords.isNotEmpty;
  bool get isExhaust => keywords.contains(CardKeyword.exhaust);
  bool get isInnate => keywords.contains(CardKeyword.innate);
  bool get isEthereal => keywords.contains(CardKeyword.ethereal);
  bool get isRetain => keywords.contains(CardKeyword.retain);
  bool get isColorless => jobId == null;

  /// 업그레이드 버전 생성을 위한 copyWith.
  CardData copyWith({
    String? id,
    String? name,
    String? jobId,
    CardType? type,
    int? apCost,
    int? damage,
    int? block,
    String? description,
    bool? upgraded,
    Set<CardKeyword>? keywords,
    List<CardEffect>? effects,
    CardTargetType? targetType,
  }) {
    return CardData(
      id: id ?? this.id,
      name: name ?? this.name,
      jobId: jobId ?? this.jobId,
      type: type ?? this.type,
      apCost: apCost ?? this.apCost,
      damage: damage ?? this.damage,
      block: block ?? this.block,
      description: description ?? this.description,
      upgraded: upgraded ?? this.upgraded,
      keywords: keywords ?? this.keywords,
      effects: effects ?? this.effects,
      targetType: targetType ?? this.targetType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        jobId,
        type,
        apCost,
        damage,
        block,
        description,
        upgraded,
        keywords,
        effects,
        targetType,
      ];
}
