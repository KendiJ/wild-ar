import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// Image Recognition AR scene tracking reference images.
/// Compatible with iOS ARKit SceneView, with an adaptive fallback on Android.
class ImageRecognitionScreen extends StatelessWidget {
  const ImageRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Recognition'),
        backgroundColor: const Color(0xFF161624),
      ),
      body: isIOS
          ? ARKitSceneView(
              detectionImagesGroupName: 'AR Resources',
              onARKitViewCreated: (controller) {
                controller.onAddNodeForAnchor = (anchor) {
                  final earthPosition = Vector3(
                    anchor.transform.getColumn(3).x,
                    anchor.transform.getColumn(3).y,
                    anchor.transform.getColumn(3).z,
                  );
                  final node = ARKitNode(
                    geometry: ARKitSphere(
                      materials: [
                        ARKitMaterial(
                          diffuse: ARKitMaterialProperty.image(
                            'assets/images/globe.jpeg',
                          ),
                        ),
                      ],
                      radius: 0.06,
                    ),
                    position: earthPosition,
                  );
                  controller.add(node);
                };
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.image_search,
                      size: 72,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Image Target Recognition',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This reference image tracking experience uses Apple ARKit (iOS). For Android devices, launch "AR Road Wildlife" from the home screen.',
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
