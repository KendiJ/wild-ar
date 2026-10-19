import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ar_scene_config.dart';
import '../../domain/repositories/ar_session_repository.dart';

/// Provider exposing the concrete MethodChannel implementation of [ArSessionRepository].
final arSessionRepositoryProvider = Provider<ArSessionRepository>((ref) {
  final repo = MethodChannelArRepository();
  ref.onDispose(() {
    repo.dispose();
  });
  return repo;
});

/// Data-layer repository that connects Flutter to native ARCore / SceneView via Platform MethodChannels.
class MethodChannelArRepository implements ArSessionRepository {
  MethodChannel? _channel;
  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get sessionEventsStream =>
      _eventsController.stream;

  @override
  Future<void> initializeSession(int viewId) async {
    _channel = MethodChannel('com.example.wild_ar/ar_channel_$viewId');
    _channel?.setMethodCallHandler(_handleNativeCall);
    await _channel?.invokeMethod('initialize');
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onPlaneDetected':
        final count = call.arguments as int? ?? 1;
        _eventsController.add({
          'type': 'planeDetected',
          'count': count,
        });
        break;

      case 'onAnchorPlaced':
        final map = Map<String, dynamic>.from(call.arguments as Map);
        _eventsController.add({
          'type': 'anchorPlaced',
          'x': map['x'],
          'y': map['y'],
          'z': map['z'],
        });
        break;

      case 'onTrackingChanged':
        final state = call.arguments as String? ?? 'tracking';
        _eventsController.add({
          'type': 'trackingChanged',
          'status': state,
        });
        break;

      case 'onError':
        final message = call.arguments as String? ?? 'Unknown AR error';
        _eventsController.add({
          'type': 'error',
          'message': message,
        });
        break;
    }
  }

  @override
  Future<void> loadVideo({
    required String source,
    required bool isAsset,
  }) async {
    await _channel?.invokeMethod('loadVideo', {
      'source': source,
      'isAsset': isAsset,
    });
  }

  @override
  Future<void> updateChromaKey(ArSceneConfig config) async {
    await _channel?.invokeMethod('updateChromaKey', config.toMap());
  }

  @override
  Future<void> setPlaneVisibility(bool visible) async {
    await _channel?.invokeMethod('setPlaneVisibility', {
      'visible': visible,
    });
  }

  @override
  Future<void> clearAnchors() async {
    await _channel?.invokeMethod('clearAnchors');
  }

  @override
  Future<void> dispose() async {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    await _eventsController.close();
  }
}
