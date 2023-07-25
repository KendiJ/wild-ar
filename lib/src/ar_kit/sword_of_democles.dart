import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class SwordOfDemocles extends StatelessWidget {
  const SwordOfDemocles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARKitSceneView(onARKitViewCreated: (c) {
        final node = ARKitNode(
          geometry: ARKitBox(
            width: 0.1,
            height: 0.1,
            length: 0.1,
            materials: [
              ARKitMaterial(
                fillMode: ARKitFillMode.lines
              )
            ]
          ),
          position: Vector3(0, 0, -0.5),
        );
        c.add(node);
      }),
    );
  }
}
