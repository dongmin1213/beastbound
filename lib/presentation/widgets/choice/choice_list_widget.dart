import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_card_widget.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

class ChoiceListWidget extends StatefulWidget {

  final List<ChoiceData> choices;
  final bool visible;
  final ValueChanged<ChoiceData> onChoiceSelected;
  final bool isCardCombat;
  final int currentFloor;

  const ChoiceListWidget({
    super.key,
    required this.choices,
    required this.visible,
    required this.onChoiceSelected,
    this.isCardCombat = false,
    this.currentFloor = 1,
  });

  @override
  State<ChoiceListWidget> createState() => _ChoiceListWidgetState();
}

class _ChoiceListWidgetState extends State<ChoiceListWidget> {
  String? _selectedId;
  String? _playedId; // 플레이 중인 카드 (exit 애니메이션용)
  // 애니메이션 재트리거를 위한 키
  int _animationGeneration = 0;
  // 스크롤 힌트용
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollHints);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollHints);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollHints() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final newLeft = pos.pixels > 0;
    final newRight = pos.pixels < pos.maxScrollExtent - 1;
    if (newLeft != _canScrollLeft || newRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = newLeft;
        _canScrollRight = newRight;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChoiceListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_choicesMatch(oldWidget.choices, widget.choices)) {
      _selectedId = null;
      // 카드 전투: 개별 카드 ValueKey로 관리 → 전체 재애니메이션 방지
      // 비전투 선택지: 선택지 전체 교체 시 재애니메이션 필요
      if (!widget.isCardCombat) {
        _animationGeneration++;
      }
      // 스크롤 힌트 리셋 (다음 프레임에서 재계산)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollHints();
      });
    }
  }

  /// 선택지 ID+enabled 내용 비교 — 레퍼런스가 달라도 내용이 같으면 재애니메이션 방지.
  static bool _choicesMatch(List<ChoiceData> a, List<ChoiceData> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].enabled != b[i].enabled) return false;
    }
    return true;
  }

  void _onCardTap(ChoiceData choice) {
    if (!choice.enabled) return;
    // 카드 플레이 애니메이션 중 중복 탭 방지
    if (_playedId != null) return;

    if (widget.isCardCombat && choice.isCard) {
      // 카드 전투: 선택 후 확인 인터랙션
      if (_selectedId == choice.id) {
        // 같은 카드 재탭 → 플레이 애니메이션 후 실행
        setState(() {
          _playedId = choice.id;
        });
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          widget.onChoiceSelected(choice);
          setState(() {
            _playedId = null;
          });
        });
      } else {
        // 새 카드 선택 → 시각 피드백만
        setState(() {
          _selectedId = choice.id;
        });
      }
    } else {
      // 비전투 선택지: 즉시 실행 (기존 동작)
      if (_selectedId != null) return;
      setState(() {
        _selectedId = choice.id;
      });
      widget.onChoiceSelected(choice);
    }
  }

  void _onBackgroundTap() {
    if (widget.isCardCombat && _selectedId != null) {
      setState(() {
        _selectedId = null;
      });
    }
  }

  ChoiceCardState _cardState(ChoiceData choice) {
    if (!choice.enabled) return ChoiceCardState.disabled;
    if (_playedId == choice.id) return ChoiceCardState.played;
    if (_selectedId == null) return ChoiceCardState.idle;
    if (choice.id == _selectedId) return ChoiceCardState.selected;
    if (widget.isCardCombat) return ChoiceCardState.idle;
    return ChoiceCardState.disabled;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.choices.isEmpty) {
      return const SizedBox.shrink();
    }

    final isRewardPhase = widget.isCardCombat &&
        widget.choices.any((c) => c.id == 'skip_reward');

    return IgnorePointer(
      ignoring: !widget.visible,
      child: widget.isCardCombat && widget.choices.any((c) => c.isCard)
          ? isRewardPhase
              ? _buildRewardCardHand(context)
              : _buildHorizontalCardHand(context)
          : _buildVerticalList(context),
    );
  }

  // ── 카드 전투: 가로 스크롤 핸드 ──

  Widget _buildHorizontalCardHand(BuildContext context) {
    final cardWidth = ResponsiveScale.scalePadding(context, 100);
    final cardSpacing = 10.0;

    return GestureDetector(
      onTap: _onBackgroundTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: ResponsiveScale.scaleVerticalPadding(context, 125) + 32,
        // 항상 동일한 위젯 트리 (LayoutBuilder > Stack > ListView)
        // — 카드 수 변경 시 Row↔ListView 전환으로 인한 재애니메이션 방지
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth =
                widget.choices.length * (cardWidth + cardSpacing) - cardSpacing;
            final availableWidth = constraints.maxWidth;
            // 카드가 뷰포트에 들어오면 가운데 정렬 패딩, 아니면 기본 16
            final hPadding = totalWidth < availableWidth - 32
                ? math.max(16.0, (availableWidth - totalWidth) / 2)
                : 16.0;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateScrollHints();
            });

            return Stack(
              children: [
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 0),
                    itemCount: widget.choices.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < widget.choices.length - 1
                              ? cardSpacing
                              : 0,
                        ),
                        child: _animateCardEntry(
                          ChoiceCardWidget(
                            key: ValueKey(
                                'card_${widget.choices[index].id}_$_animationGeneration'),
                            choice: widget.choices[index],
                            state: _cardState(widget.choices[index]),
                            onTap: _onCardTap,
                            currentFloor: widget.currentFloor,
                          ),
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
                // 좌측 스크롤 힌트
                if (_canScrollLeft)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: _buildScrollHint(isLeft: true),
                  ),
                // 우측 스크롤 힌트
                if (_canScrollRight)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _buildScrollHint(isLeft: false),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── 카드 보상: 카드 핸드 + 건너뛰기 분리 ──

  Widget _buildRewardCardHand(BuildContext context) {
    final cardChoices = widget.choices.where((c) => c.id != 'skip_reward').toList();
    final skipChoice = widget.choices.where((c) => c.id == 'skip_reward').firstOrNull;

    final cardWidth = ResponsiveScale.scalePadding(context, 100);
    final cardSpacing = 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 카드 핸드 (건너뛰기 제외)
        SizedBox(
          height: ResponsiveScale.scaleVerticalPadding(context, 125) + 32,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth =
                  cardChoices.length * (cardWidth + cardSpacing) - cardSpacing;
              final availableWidth = constraints.maxWidth;
              final hPadding = totalWidth < availableWidth - 32
                  ? math.max(16.0, (availableWidth - totalWidth) / 2)
                  : 16.0;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateScrollHints();
              });

              return Stack(
                children: [
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 0),
                      itemCount: cardChoices.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < cardChoices.length - 1
                                ? cardSpacing
                                : 0,
                          ),
                          child: _animateCardEntry(
                            ChoiceCardWidget(
                              key: ValueKey(
                                  'card_${cardChoices[index].id}_$_animationGeneration'),
                              choice: cardChoices[index],
                              state: _cardState(cardChoices[index]),
                              onTap: _onCardTap,
                              currentFloor: widget.currentFloor,
                            ),
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                  if (_canScrollLeft)
                    Positioned(
                      left: 0, top: 0, bottom: 0,
                      child: _buildScrollHint(isLeft: true),
                    ),
                  if (_canScrollRight)
                    Positioned(
                      right: 0, top: 0, bottom: 0,
                      child: _buildScrollHint(isLeft: false),
                    ),
                ],
              );
            },
          ),
        ),
        // 건너뛰기 버튼 — 턴 종료/도주와 유사한 풀 너비 스타일
        if (skipChoice != null)
          _animateEntry(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                color: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFF4A4A6A)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: InkWell(
                  onTap: () => _onCardTap(skipChoice),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        '건너뛰기',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            index: cardChoices.length,
          ),
      ],
    );
  }

  // ── 스크롤 힌트 화살표 ──

  Widget _buildScrollHint({required bool isLeft}) {
    return IgnorePointer(
      child: Container(
        width: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: const [
              Color(0xCC0A0A14),
              Color(0x000A0A14),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          isLeft ? Icons.chevron_left : Icons.chevron_right,
          color: const Color(0x99FFFFFF),
          size: 18,
        ),
      ),
    );
  }

  /// 텍스트 선택지 진입 애니메이션 (비활성화 가능).
  Widget _animateEntry(Widget child, {required int index}) {
    if (!AppTheme.enableAnimations) return child;
    return child
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 100).ms)
        .slideY(begin: 0.12, end: 0, duration: 250.ms, delay: (index * 100).ms, curve: Curves.easeOut);
  }

  /// 카드 전투 진입 애니메이션 (비활성화 가능).
  Widget _animateCardEntry(Widget child, {required int index}) {
    if (!AppTheme.enableAnimations) return child;
    return child
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 80).ms)
        .slideY(begin: 0.15, end: 0, duration: 300.ms, delay: (index * 80).ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 300.ms, delay: (index * 80).ms, curve: Curves.easeOut);
  }

  // ── 비전투: 기존 세로 리스트 ──

  Widget _buildVerticalList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.choices.length; i++) ...[
          if (i > 0)
            SizedBox(
              height: math.max(
                8,
                ResponsiveScale.scaleVerticalPadding(context, 8),
              ),
            ),
          _animateEntry(
            ChoiceCardWidget(
              key: ValueKey('choice_${widget.choices[i].id}_$_animationGeneration'),
              choice: widget.choices[i],
              state: _cardState(widget.choices[i]),
              onTap: _onCardTap,
              currentFloor: widget.currentFloor,
            ),
            index: i,
          ),
        ],
      ],
    );
  }
}
