import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/ar_session_notifier.dart';

/// Android Native PlatformView using standard AndroidView composition.
/// Works reliably with Camera2 TextureView + EGL Chroma-Key TextureView on Samsung A12.
class AndroidArCoreView extends ConsumerWidget {
  const AndroidArCoreView({super.key});

  static const String viewType = 'com.example.wild_ar/ar_core_view';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref.read so state updates don't destroy/recreate the native camera view
    final initialConfig = ref.read(arSessionNotifierProvider).config;

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: initialConfig.toMap(),
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
      onPlatformViewCreated: (int id) {
        ref.read(arSessionNotifierProvider.notifier).attachNativeView(id);
      },
    );
  }
}