import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Sensorama 360-degree Earth projection sphere view.
/// Compatible with iOS ARKit SceneView, with an adaptive fallback on Android.
class SensoramaScreen extends StatelessWidget {
  const SensoramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensorama'),
        backgroundColor: const Color(0xFF161624),
      ),
      body: isIOS
          ? ARKitSceneView(
              onARKitViewCreated: (controller) {
                final node = ARKitNode(
                  geometry: ARKitSphere(
                    materials: [
                      ARKitMaterial(
                        diffuse: const ARKitMaterialImage('assets/images/earth.jpeg'),
                        doubleSided: true,
                      ),
                    ],
                  ),
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
                    const Icon(Icons.public, size: 72, color: Color(0xFF00BFA5)),
                    const SizedBox(height: 20),
                    const Text(
                      'Sensorama Earth Sphere',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This 360° projection experience uses Apple ARKit (iOS). For Android devices, launch "AR Road Wildlife" from the home screen.',
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
