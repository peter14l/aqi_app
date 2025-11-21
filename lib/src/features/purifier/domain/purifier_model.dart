import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'purifier_model.freezed.dart';
part 'purifier_model.g.dart';

@freezed
@HiveType(typeId: 0)
class PurifierState with _$PurifierState {
  @HiveField(0)
  const factory PurifierState({
    @HiveField(1) required String id,
    @HiveField(2) required String name,
    @HiveField(3) required String status,
    @HiveField(4) required String mode,
    @HiveField(5) required int fanSpeed,
    @HiveField(6) required bool isConnected,
    @HiveField(7) required DateTime lastUpdated,
    @HiveField(8) int? currentAqi,
    @HiveField(9) String? location,
    @HiveField(10) double? filterLifeRemaining,
    @HiveField(11) @Default(false) bool isAutoAdjust,
  }) = _PurifierState;

  factory PurifierState.fromJson(Map<String, dynamic> json) => _$PurifierStateFromJson(json);

  // Default instance
  static final empty = PurifierState(
    id: '',
    name: 'Air Purifier',
    status: 'off',
    mode: 'auto',
    fanSpeed: 0,
    isConnected: false,
    lastUpdated: DateTime.now(),
  );
}

enum PurifierMode {
  auto('Auto', 'assets/icons/auto_mode.svg'),
  manual('Manual', 'assets/icons/fan_speed.svg'),
  sleep('Sleep', 'assets/icons/sleep_mode.svg'),
  turbo('Turbo', 'assets/icons/turbo_mode.svg');

  final String label;
  final String iconPath;
  const PurifierMode(this.label, this.iconPath);
}

@HiveType(typeId: 1)
enum PurifierStatus {
  @HiveField(0)
  on('On', 'assets/icons/power_on.svg'),
  @HiveField(1)
  off('Off', 'assets/icons/power_off.svg'),
  @HiveField(2)
  error('Error', 'assets/icons/error.svg');

  final String label;
  final String iconPath;
  const PurifierStatus(this.label, this.iconPath);
}
