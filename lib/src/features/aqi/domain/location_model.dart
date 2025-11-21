import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

/// Location model for geocoding results
@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel({
    required String name,
    required double latitude,
    required double longitude,
    String? country,
    String? admin1, // State/Province
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
}

/// Location state for persistence
@freezed
class LocationState with _$LocationState {
  const factory LocationState({
    required String name,
    required double latitude,
    required double longitude,
    String? country,
  }) = _LocationState;

  factory LocationState.fromJson(Map<String, dynamic> json) =>
      _$LocationStateFromJson(json);
}
