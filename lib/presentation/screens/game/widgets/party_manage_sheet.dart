import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/config/tamed_monster_store.dart';
import 'package:soul_dungeon/domain/combat/content/monster_passives.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/monster_display.dart';

/// 동료(장착 몬스터) 관리 시트.
///
/// 길들인 몬스터(도감) 중 최대 [maxSlots]마리를 장착한다. 장착한 동료만
/// 카드 풀 + 패시브(+ 타입 친화)에 기여한다. 변경은 다음 전투부터 반영.
class PartyManageSheet extends StatefulWidget {
  final List<String> equipped;
  final int maxSlots;
  final void Function(List<String> newEquipped) onChanged;

  const PartyManageSheet({
    super.key,
    required this.equipped,
    required this.maxSlots,
    required this.onChanged,
  });

  @override
  State<PartyManageSheet> createState() => _PartyManageSheetState();
}

class _PartyManageSheetState extends State<PartyManageSheet> {
  late List<String> _equipped;

  @override
  void initState() {
    super.initState();
    _equipped = List.of(widget.equipped);
  }

  void _toggle(String id) {
    setState(() {
      if (_equipped.contains(id)) {
        _equipped.remove(id);
      } else if (_equipped.length < widget.maxSlots) {
        _equipped.add(id);
      }
    });
    widget.onChanged(List.of(_equipped));
  }

  @override
  Widget build(BuildContext context) {
    // 도감(장착 가능) = 길들인 몬스터 ∪ 현재 장착(스타터 등).
    final rosterIds = {...TamedMonsterStore.tamedIds, ..._equipped}.toList();
    // 타입 친화 요약.
    final aff = MonsterPassives.affinity(_equipped);

    return Dialog(
      backgroundColor: const Color(0xFF15101F),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Row(
                children: [
                  Text(
                    '동료 관리',
                    style: TextStyle(
                      color: AppTheme.titleGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_equipped.length}/${widget.maxSlots}',
                    style: const TextStyle(
                        color: Color(0xFF9A8AC0),
                        fontSize: 13,
                        fontFamily: 'monospace'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFB0A8C0)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 타입 친화 요약
            if (aff.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Wrap(
                  spacing: 6,
                  children: aff.entries.map((e) {
                    final bonus = MonsterPassives.affinityBonus(e.value);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2140),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${e.key.label} ×${e.value}${bonus > 0 ? ' (+$bonus)' : ''}',
                        style: TextStyle(
                          color: bonus > 0
                              ? const Color(0xFF8FE0A0)
                              : const Color(0xFF9A8AC0),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Text(
                '길들인 몬스터 중 최대 슬롯만큼 장착. 변경은 다음 전투부터.',
                style: TextStyle(
                    color: Color(0xFF6A6280),
                    fontSize: 11,
                    fontFamily: 'monospace'),
              ),
            ),
            // 로스터 목록
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                itemCount: rosterIds.length,
                itemBuilder: (context, i) {
                  final id = rosterIds[i];
                  return _RosterRow(
                    id: id,
                    equipped: _equipped.contains(id),
                    canEquip: _equipped.length < widget.maxSlots,
                    onTap: () => _toggle(id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RosterRow extends StatelessWidget {
  final String id;
  final bool equipped;
  final bool canEquip;
  final VoidCallback onTap;

  const _RosterRow({
    required this.id,
    required this.equipped,
    required this.canEquip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = MonsterDisplay.name(id);
    final spritePath = MonsterDisplay.sprite(id);
    final type = MonsterPassives.typeOf(id);
    final passive = MonsterPassives.forMonster(id);
    final tappable = equipped || canEquip;

    return Opacity(
      opacity: tappable ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: tappable ? onTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: equipped ? const Color(0xFF243A24) : const Color(0xFF1C1530),
            border: Border.all(
              color: equipped
                  ? const Color(0xFF6FCF6F)
                  : const Color(0xFF3A3352),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: spritePath == null
                    ? const Icon(Icons.pets, color: Color(0xFF554C6A))
                    : Image.asset(spritePath,
                        width: 36, height: 36, filterQuality: FilterQuality.none),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name,
                            style: const TextStyle(
                                color: Color(0xFFEDE6F5),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace')),
                        const SizedBox(width: 6),
                        Text('[${type.label}]',
                            style: const TextStyle(
                                color: Color(0xFF9A8AC0),
                                fontSize: 10,
                                fontFamily: 'monospace')),
                      ],
                    ),
                    if (!passive.isNone)
                      Text('✦ ${passive.label}',
                          style: const TextStyle(
                              color: Color(0xFF8FB0E0),
                              fontSize: 10,
                              fontFamily: 'monospace')),
                  ],
                ),
              ),
              Icon(
                equipped ? Icons.check_circle : Icons.add_circle_outline,
                color: equipped
                    ? const Color(0xFF6FCF6F)
                    : (canEquip
                        ? const Color(0xFF9A8AC0)
                        : const Color(0xFF4A4460)),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
