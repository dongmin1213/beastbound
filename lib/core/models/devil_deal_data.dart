/// 악마의 거래 — 축복+저주 페어링.
///
/// 강력한 축복을 얻는 대신 저주를 받는 거래 구조.
/// cost=0이면 무료(저주가 대가), 양수면 추가 골드 비용.
class DevilDealData {
  final String id;
  final String blessingId;
  final String curseId;
  final int cost;
  final String flavorText;

  const DevilDealData({
    required this.id,
    required this.blessingId,
    required this.curseId,
    this.cost = 0,
    required this.flavorText,
  });

  factory DevilDealData.fromJson(Map<String, dynamic> json) {
    return DevilDealData(
      id: json['id'] as String,
      blessingId: json['blessing_id'] as String,
      curseId: json['curse_id'] as String,
      cost: json['cost'] as int? ?? 0,
      flavorText: json['flavor_text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'blessing_id': blessingId,
        'curse_id': curseId,
        'cost': cost,
        'flavor_text': flavorText,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DevilDealData && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
