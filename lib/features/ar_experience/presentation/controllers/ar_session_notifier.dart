import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../data/repositories/method_channel_ar_repository.dart';
import '../../domain/entities/ar_scene_config.dart';
import '../../domain/entities/ar_session_state.dart';
import '../../domain/repositories/ar_session_repository.dart';

/// Riverpod 3.x NotifierProvider managing the complete lifecycle and state of the AR session.
final arSessionNotifierProvider =
    NotifierProvider<ArSessionNotifier, ArSessionState>(ArSessionNotifier.new);

/// Riverpod 3.x Notifier implementation orchestrating AR interactions, Chroma-Key parameters,
/// and bidirectional communication with the native AR engine.
class ArSessionNotifier extends Notifier<ArSessionState> {
  StreamSubscription<Map<String, dynamic>>? _eventsSubscription;
  late final ArSessionRepository _repository;

  @override
  ArSessionState build() {
    _repository = ref.read(arSessionRepositoryProvider);

    ref.onDispose(() {
      _eventsSubscription?.cancel();
    });

    _listenToRepositoryEvents();

    return const ArSessionState();
  }

  void _listenToRepositoryEvents() {
    _eventsSubscription?.cancel();
    _eventsSubscription = _repository.sessionEventsStream.listen((event) {
      final type = event['type'] as String?;
      switch (type) {
        case 'planeDetected':
          final count = event['count'] as int? ?? 1;
          onPlaneDetected(count);
          break;

        case 'anchorPlaced':
          final x = (event['x'] as num?)?.toDouble() ?? 0.0;
          final y = (event['y'] as num?)?.toDouble() ?? 0.0;
          final z = (event['z'] as num?)?.toDouble() ?? 0.0;
          onAnchorPlaced(x, y, z);
          break;

        case 'trackingChanged':
          final statusStr = event['status'] as String? ?? 'tracking';
          final status = switch (statusStr) {
            'tracking' => ArTrackingStatus.tracking,
            'limited' => ArTrackingStatus.limited,
            'stopped' => ArTrackingStatus.stopped,
            _ => ArTrackingStatus.initializing,
          };
          setTrackingStatus(status);
          break;

        case 'error':
          final msg = event['message'] as String? ?? 'Native AR error occurred';
          setError(msg);
          break;
      }
    });
  }

  /// Called when a native PlatformView (ARCore / ARKit) is mounted and ready.
  Future<void> attachNativeView(int viewId) async {
    try {
      state = state.copyWith(
        trackingStatus: ArTrackingStatus.initializing,
        clearError: true,
      );

      await _repository.initializeSession(viewId);

      // Push initial scene configuration to the native bridge
      await _repository.loadVideo(
        source: state.config.videoPath,
        isAsset: state.config.isLocal,
      );

      await _repository.updateChromaKey(state.config);
      await _repository.setPlaneVisibility(true);

      state = state.copyWith(
        isSessionReady: true,
        trackingStatus: ArTrackingStatus.tracking,
      );
    } catch (e) {
      setError('Failed to attach native AR view: $e');
    }
  }

  /// Updates detected plane counts and transitions to tracking if appropriate.
  void onPlaneDetected(int count) {
    state = state.copyWith(
      planesDetectedCount: count,
      trackingStatus: ArTrackingStatus.tracking,
      clearError: true,
    );
  }

  /// Records an anchor placement and its 3D world coordinates.
  void onAnchorPlaced(double x, double y, double z) {
    state = state.copyWith(
      anchorsCount: state.anchorsCount + 1,
      lastAnchorPosition: Vector3(x, y, z),
      clearError: true,
    );
  }

  /// Updates the full ArSceneConfig and propagates changes to the native shader.
  Future<void> updateSceneConfig(ArSceneConfig newConfig) async {
    state = state.copyWith(config: newConfig);
    try {
      await _repository.updateChromaKey(newConfig);
    } catch (e) {
      setError('Could not update chroma-key config: $e');
    }
  }

  /// Updates the Chroma-Key similarity threshold parameter (0.0 to 1.0).
  Future<void> updateSimilarityThreshold(double threshold) async {
    final updated = state.config.copyWith(similarityThreshold: threshold);
    await updateSceneConfig(updated);
  }

  /// Updates the Chroma-Key edge smoothness parameter (0.0 to 1.0).
  Future<void> updateEdgeSmoothness(double smoothness) async {
    final updated = state.config.copyWith(edgeSmoothness: smoothness);
    await updateSceneConfig(updated);
  }

  /// Updates the bottom contact feathering parameter (0.0 to 0.5) for road blending.
  Future<void> updateBottomFeather(double feather) async {
    final updated = state.config.copyWith(bottomFeather: feather);
    await updateSceneConfig(updated);
  }

  /// Updates the normalized [R, G, B] key color to strip out.
  Future<void> updateKeyColorRgb(List<double> rgb) async {
    final updated = state.config.copyWith(keyColorRgb: rgb);
    await updateSceneConfig(updated);
  }

  /// Toggles Chroma-Keying on or off.
  Future<void> toggleChromaKey() async {
    final updated = state.config.copyWith(enableChromaKey: !state.config.enableChromaKey);
    await updateSceneConfig(updated);
  }

  /// Switches the active video source between local bundled assets and remote CDN streams.
  Future<void> loadVideo(String path, VideoSourceType type) async {
    final updated = state.config.copyWith(
      videoPath: path,
      sourceType: type,
    );
    state = state.copyWith(config: updated);
    try {
      await _repository.loadVideo(
        source: path,
        isAsset: type == VideoSourceType.localAsset,
      );
    } catch (e) {
      setError('Could not switch video source: $e');
    }
  }

  /// Removes all anchored nodes from the 3D scene.
  Future<void> clearAnchors() async {
    state = state.copyWith(
      anchorsCount: 0,
      lastAnchorPosition: null,
    );
    try {
      await _repository.clearAnchors();
    } catch (e) {
      setError('Could not clear anchors: $e');
    }
  }

  /// Sets the AR tracking status.
  void setTrackingStatus(ArTrackingStatus status) {
    state = state.copyWith(trackingStatus: status);
  }

  /// Sets or clears an error message.
  void setError(String? message) {
    state = state.copyWith(
      errorMessage: message,
      clearError: message == null,
    );
  }
}
