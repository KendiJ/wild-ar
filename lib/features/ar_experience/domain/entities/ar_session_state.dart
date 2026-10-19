import 'package:vector_math/vector_math_64.dart';
import 'ar_scene_config.dart';

/// Tracking status of the underlying ARCore or ARKit session.
enum ArTrackingStatus {
  initializing,
  tracking,
  limited,
  stopped;

  bool get isTracking => this == ArTrackingStatus.tracking;
}

/// Immutable state representing the active AR session and scene graph.
class ArSessionState {
  final ArTrackingStatus trackingStatus;
  final int planesDetectedCount;
  final int anchorsCount;
  final Vector3? lastAnchorPosition;
  final bool isSessionReady;
  final String? errorMessage;
  final ArSceneConfig config;

  const ArSessionState({
    this.trackingStatus = ArTrackingStatus.initializing,
    this.planesDetectedCount = 0,
    this.anchorsCount = 0,
    this.lastAnchorPosition,
    this.isSessionReady = false,
    this.errorMessage,
    this.config = const ArSceneConfig(),
  });

  bool get hasDetectedPlanes => planesDetectedCount > 0;
  bool get hasPlacedAnchors => anchorsCount > 0;

  /// User-friendly coaching guidance based on AR tracking state and plane detection.
  String get coachingMessage {
    if (errorMessage != null) {
      return 'Error: $errorMessage';
    }
    switch (trackingStatus) {
      case ArTrackingStatus.initializing:
        return 'Initializing AR engine... Point your camera at the road.';
      case ArTrackingStatus.limited:
        return 'Slow down or add more light to detect the road surface.';
      case ArTrackingStatus.stopped:
        return 'AR session paused.';
      case ArTrackingStatus.tracking:
        if (hasPlacedAnchors) {
          return 'Wildlife anchored to the road. Tap again to reposition.';
        } else if (hasDetectedPlanes) {
          return 'Road surface detected! Tap anywhere on the road to anchor wildlife.';
        } else {
          return 'Move your phone slowly over the road surface to detect the ground.';
        }
    }
  }

  ArSessionState copyWith({
    ArTrackingStatus? trackingStatus,
    int? planesDetectedCount,
    int? anchorsCount,
    Vector3? lastAnchorPosition,
    bool? isSessionReady,
    String? errorMessage,
    bool clearError = false,
    ArSceneConfig? config,
  }) {
    return ArSessionState(
      trackingStatus: trackingStatus ?? this.trackingStatus,
      planesDetectedCount: planesDetectedCount ?? this.planesDetectedCount,
      anchorsCount: anchorsCount ?? this.anchorsCount,
      lastAnchorPosition: lastAnchorPosition ?? this.lastAnchorPosition,
      isSessionReady: isSessionReady ?? this.isSessionReady,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      config: config ?? this.config,
    );
  }
}
