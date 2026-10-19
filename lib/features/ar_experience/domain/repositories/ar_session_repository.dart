import 'dart:async';
import '../entities/ar_scene_config.dart';

/// Contract for communicating with the platform-native AR engine (ARCore / ARKit).
abstract class ArSessionRepository {
  /// Initializes the bridge to the native AR view identified by [viewId].
  Future<void> initializeSession(int viewId);

  /// Changes the media source being projected on the AR plane.
  Future<void> loadVideo({
    required String source,
    required bool isAsset,
  });

  /// Updates the Chroma-Key extraction and feathering parameters on the active shader.
  Future<void> updateChromaKey(ArSceneConfig config);

  /// Toggles visibility of the detected horizontal road/ground planes grid.
  Future<void> setPlaneVisibility(bool visible);

  /// Clears all existing 3D road anchors and video quads from the scene.
  Future<void> clearAnchors();

  /// Stream of asynchronous events emitted by the native AR engine
  /// (e.g. plane detected, anchor placed, tracking state changed, errors).
  Stream<Map<String, dynamic>> get sessionEventsStream;

  /// Releases resources allocated by the bridge.
  Future<void> dispose();
}
