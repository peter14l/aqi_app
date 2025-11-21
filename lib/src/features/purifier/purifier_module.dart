// lib/src/features/purifier/purifier_module.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aqi_app/src/features/purifier/data/adapters/purifier_adapter.dart';
import 'package:aqi_app/src/features/purifier/data/datasources/purifier_local_data_source.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';
import 'package:aqi_app/src/features/purifier/domain/repositories/purifier_repository_interface.dart';
import 'package:aqi_app/src/features/purifier/data/repositories/purifier_repository_impl.dart';

final purifierModuleProvider = Provider<PurifierModule>((ref) {
  throw UnimplementedError('PurifierModule not initialized');
});

class PurifierModule {
  final PurifierLocalDataSource localDataSource;
  final PurifierRepository repository;

  PurifierRepository get purifierRepository => repository;

  PurifierModule._({
    required this.localDataSource,
    required this.repository,
  });

  static Future<PurifierModule> initialize() async {
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PurifierAdapter());
    }

    // Initialize Hive box
    await Hive.openBox<PurifierState>('purifiers');
    final localDataSource = PurifierLocalDataSource();
    final repository = PurifierRepositoryImpl(localDataSource: localDataSource);

    return PurifierModule._(
      localDataSource: localDataSource,
      repository: repository,
    );
  }

  Future<void> dispose() async {
    await localDataSource.close();
  }
}