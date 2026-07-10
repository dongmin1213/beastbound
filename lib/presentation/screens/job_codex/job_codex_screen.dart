import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_state.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/job_codex/job_codex_widget.dart';

/// 직업 도감 화면 — 타이틀에서 진입하는 독립 라우트.
///
/// ProgressionBloc에서 해금된 히든 직업 ID를 읽어 JobCodexWidget에 전달한다.
class JobCodexScreen extends StatelessWidget {
  final VoidCallback onBack;

  const JobCodexScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Theme(
        data: AppTheme.dark,
        child: Scaffold(
          backgroundColor: AppTheme.screenBackground,
          body: SafeArea(
            child: BlocBuilder<ProgressionBloc, ProgressionState>(
              builder: (context, state) {
                final unlockedIds = state is ProgressionLoaded
                    ? state.unlockedHiddenJobIds
                    : <String>{};

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: JobCodexWidget(
                    unlockedHiddenJobIds: unlockedIds,
                    onClose: onBack,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
