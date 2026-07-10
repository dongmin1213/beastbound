import 'package:equatable/equatable.dart';

/// 유령 NPC 데이터 — 사망한 플레이어의 기억이 남긴 NPC.
class GhostNpcData extends Equatable {
  /// 사망한 층.
  final int deathFloor;

  /// 사망 시 직업 ID.
  final String jobId;

  /// 사망 시 성향 스냅샷 (6축).
  final Map<String, int> dispositionSnapshot;

  /// 런 번호 (몇 번째 런에서 사망했는지).
  final int runNumber;

  const GhostNpcData({
    required this.deathFloor,
    required this.jobId,
    required this.dispositionSnapshot,
    required this.runNumber,
  });

  factory GhostNpcData.fromJson(Map<String, dynamic> json) => GhostNpcData(
        deathFloor: json['deathFloor'] as int,
        jobId: json['jobId'] as String,
        dispositionSnapshot:
            Map<String, int>.from(json['dispositionSnapshot'] as Map),
        runNumber: json['runNumber'] as int,
      );

  Map<String, dynamic> toJson() => {
        'deathFloor': deathFloor,
        'jobId': jobId,
        'dispositionSnapshot': dispositionSnapshot,
        'runNumber': runNumber,
      };

  /// MetaSaveData.ghostNpcPoolRaw → `List<GhostNpcData>` 변환.
  static List<GhostNpcData> fromRawList(List<Map<String, dynamic>> raw) =>
      raw.map(GhostNpcData.fromJson).toList();

  @override
  List<Object?> get props => [deathFloor, jobId, dispositionSnapshot, runNumber];
}
