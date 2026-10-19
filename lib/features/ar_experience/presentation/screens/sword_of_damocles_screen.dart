import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Sword of Damocles spatial wireframe box primitive.
/// Compatible with iOS ARKit SceneView, with an adaptive fallback on Android.
class SwordOfDamoclesScreen extends StatelessWidget {
  const SwordOfDamoclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sword of Damocles'),
        backgroundColor: const Color(0xFF161624),
      ),
      body: isIOS
          ? ARKitSceneView(
              onARKitViewCreated: (controller) {
                final node = ARKitNode(
                  geometry: ARKitBox(
                    width: 0.1,
                    height: 0.1,
                    length: 0.1,
                    materials: [
                      ARKitMaterial(
                        fillMode: ARKitFillMode.lines,
                      ),
                    ],
                  ),
                  position: Vector3(0, 0, -0.5),
                );
                controller.add(node);
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.view_in_ar,
                      size: 72,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sword of Damocles Wireframe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This spatial wireframe primitive uses Apple ARKit (iOS). For Android devices, launch "AR Road Wildlife" from the home screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Return to Home'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
