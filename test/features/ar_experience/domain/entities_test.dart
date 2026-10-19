import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:wild_ar/core/constants/asset_paths.dart';
import 'package:wild_ar/features/ar_experience/domain/entities/ar_scene_config.dart';
import 'package:wild_ar/features/ar_experience/domain/entities/ar_session_state.dart';

void main() {
  group('ArSceneConfig Entity', () {
    test('default configuration sets expected production values', () {
      const config = ArSceneConfig();
      expect(config.mode, ArExperienceMode.roadWildlifeVideo);
      expect(config.sourceType, VideoSourceType.localAsset);
      expect(config.videoPath, 'assets/videos/migration1.mp4');
      expect(config.enableChromaKey, isTrue);
      expect(config.keyColorRgb, const [0.55, 0.68, 0.78]);
      expect(config.similarityThreshold, 0.28);
      expect(config.edgeSmoothness, 0.12);
      expect(config.scale, 1.0);
      expect(config.bottomFeather, 0.20);
      expect(config.isLocal, isTrue);
    });

    test('copyWith accurately updates target properties', () {
      const original = ArSceneConfig();
      final updated = original.copyWith(
        similarityThreshold: 0.35,
        bottomFeather: 0.25,
        sourceType: VideoSourceType.remoteCdn,
        videoPath: AssetPaths.cdnMigration1,
      );

      expect(updated.similarityThreshold, 0.35);
      expect(updated.bottomFeather, 0.25);
      expect(updated.sourceType, VideoSourceType.remoteCdn);
      expect(updated.videoPath, AssetPaths.cdnMigration1);
      expect(updated.isLocal, isFalse);
      expect(updated.edgeSmoothness, 0.12); // Unchanged
    });

    test('toMap and fromMap serialize and deserialize properly', () {
      const original = ArSceneConfig(
        similarityThreshold: 0.32,
        edgeSmoothness: 0.15,
        bottomFeather: 0.22,
        videoPath: AssetPaths.migration2Video,
      );

      final map = original.toMap();
      expect(map['isLocal'], isTrue);
      expect(map['videoPath'], AssetPaths.migration2Video);

      final restored = ArSceneConfig.fromMap(map);
      expect(restored.similarityThreshold, 0.32);
      expect(restored.edgeSmoothness, 0.15);
      expect(restored.bottomFeather, 0.22);
      expect(restored.videoPath, AssetPaths.migration2Video);
    });
  });

  group('ArSessionState Entity', () {
    test('initial coaching message guides user to point camera at road', () {
      const state = ArSessionState();
      expect(state.hasDetectedPlanes, isFalse);
      expect(state.hasPlacedAnchors, isFalse);
      expect(
        state.coachingMessage,
        contains('Initializing AR engine'),
      );
    });

    test('tracking with detected planes guides user to tap on road', () {
      const state = ArSessionState(
        trackingStatus: ArTrackingStatus.tracking,
        planesDetectedCount: 2,
      );
      expect(state.hasDetectedPlanes, isTrue);
      expect(
        state.coachingMessage,
        contains('Road surface detected! Tap anywhere on the road'),
      );
    });

    test('anchored state confirms wildlife placement and invites repositioning', () {
      final state = ArSessionState(
        trackingStatus: ArTrackingStatus.tracking,
        planesDetectedCount: 2,
        anchorsCount: 1,
        lastAnchorPosition: Vector3(0.5, 0.0, -1.2),
      );
      expect(state.hasPlacedAnchors, isTrue);
      expect(state.lastAnchorPosition?.x, 0.5);
      expect(
        state.coachingMessage,
        contains('Wildlife anchored to the road'),
      );
    });
  });
}
