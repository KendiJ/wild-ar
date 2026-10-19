import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wild_ar/core/constants/asset_paths.dart';
import 'package:wild_ar/features/ar_experience/data/repositories/method_channel_ar_repository.dart';
import 'package:wild_ar/features/ar_experience/domain/entities/ar_scene_config.dart';
import 'package:wild_ar/features/ar_experience/domain/entities/ar_session_state.dart';
import 'package:wild_ar/features/ar_experience/domain/repositories/ar_session_repository.dart';
import 'package:wild_ar/features/ar_experience/presentation/controllers/ar_session_notifier.dart';

/// Fake implementation of [ArSessionRepository] for unit testing.
class FakeArSessionRepository implements ArSessionRepository {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  int? initializedViewId;
  String? lastVideoSource;
  bool? lastIsAsset;
  ArSceneConfig? lastSceneConfig;
  bool? lastPlaneVisibility;
  int clearAnchorsCallCount = 0;

  @override
  Stream<Map<String, dynamic>> get sessionEventsStream => _controller.stream;

  void emitEvent(Map<String, dynamic> event) {
    _controller.add(event);
  }

  @override
  Future<void> initializeSession(int viewId) async {
    initializedViewId = viewId;
  }

  @override
  Future<void> loadVideo({
    required String source,
    required bool isAsset,
  }) async {
    lastVideoSource = source;
    lastIsAsset = isAsset;
  }

  @override
  Future<void> updateChromaKey(ArSceneConfig config) async {
    lastSceneConfig = config;
  }

  @override
  Future<void> setPlaneVisibility(bool visible) async {
    lastPlaneVisibility = visible;
  }

  @override
  Future<void> clearAnchors() async {
    clearAnchorsCallCount++;
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  late FakeArSessionRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeArSessionRepository();
    container = ProviderContainer(
      overrides: [
        arSessionRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state has default configuration and no planes', () {
    final state = container.read(arSessionNotifierProvider);
    expect(state.planesDetectedCount, 0);
    expect(state.anchorsCount, 0);
    expect(state.trackingStatus, ArTrackingStatus.initializing);
    expect(state.config.videoPath, 'assets/videos/migration1.mp4');
    expect(state.config.enableChromaKey, isTrue);
  });

  test('onPlaneDetected increments plane count and sets tracking', () {
    final notifier = container.read(arSessionNotifierProvider.notifier);
    notifier.onPlaneDetected(2);

    final state = container.read(arSessionNotifierProvider);
    expect(state.planesDetectedCount, 2);
    expect(state.trackingStatus, ArTrackingStatus.tracking);
    expect(state.hasDetectedPlanes, isTrue);
  });

  test('onAnchorPlaced updates anchor count and coordinates', () {
    final notifier = container.read(arSessionNotifierProvider.notifier);
    notifier.onAnchorPlaced(1.0, 0.0, -2.5);

    final state = container.read(arSessionNotifierProvider);
    expect(state.anchorsCount, 1);
    expect(state.lastAnchorPosition?.x, 1.0);
    expect(state.lastAnchorPosition?.y, 0.0);
    expect(state.lastAnchorPosition?.z, -2.5);
    expect(state.hasPlacedAnchors, isTrue);
  });

  test('updateSimilarityThreshold updates state and invokes repository', () async {
    final notifier = container.read(arSessionNotifierProvider.notifier);
    await notifier.updateSimilarityThreshold(0.42);

    final state = container.read(arSessionNotifierProvider);
    expect(state.config.similarityThreshold, 0.42);
    expect(fakeRepository.lastSceneConfig?.similarityThreshold, 0.42);
  });

  test('updateBottomFeather updates state and invokes repository', () async {
    final notifier = container.read(arSessionNotifierProvider.notifier);
    await notifier.updateBottomFeather(0.35);

    final state = container.read(arSessionNotifierProvider);
    expect(state.config.bottomFeather, 0.35);
    expect(fakeRepository.lastSceneConfig?.bottomFeather, 0.35);
  });

  test('loadVideo switches video source and notifies repository', () async {
    final notifier = container.read(arSessionNotifierProvider.notifier);
    await notifier.loadVideo(AssetPaths.cdnMigration1, VideoSourceType.remoteCdn);

    final state = container.read(arSessionNotifierProvider);
    expect(state.config.videoPath, AssetPaths.cdnMigration1);
    expect(state.config.sourceType, VideoSourceType.remoteCdn);
    expect(fakeRepository.lastVideoSource, AssetPaths.cdnMigration1);
    expect(fakeRepository.lastIsAsset, isFalse);
  });

  test('clearAnchors resets anchors count and triggers repository', () async {
    final notifier = container.read(arSessionNotifierProvider.notifier);
    notifier.onAnchorPlaced(0.0, 0.0, -1.0);
    expect(container.read(arSessionNotifierProvider).anchorsCount, 1);

    await notifier.clearAnchors();
    final state = container.read(arSessionNotifierProvider);
    expect(state.anchorsCount, 0);
    expect(state.lastAnchorPosition, isNull);
    expect(fakeRepository.clearAnchorsCallCount, 1);
  });

  test('attachNativeView sends initial configuration to repository', () async {
    final notifier = container.read(arSessionNotifierProvider.notifier);
    await notifier.attachNativeView(42);

    expect(fakeRepository.initializedViewId, 42);
    expect(fakeRepository.lastVideoSource, 'assets/videos/migration1.mp4');
    expect(fakeRepository.lastIsAsset, isTrue);
    expect(fakeRepository.lastPlaneVisibility, isTrue);
    expect(container.read(arSessionNotifierProvider).isSessionReady, isTrue);
  });
}
