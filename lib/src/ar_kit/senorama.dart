import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';

class SensoramaView extends StatelessWidget {
  const SensoramaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARKitSceneView(
        onARKitViewCreated: (c) {
          final node = ARKitNode(
            geometry: 
            ARKitSphere(
              materials: [
                ARKitMaterial(
                 diffuse: const ARKitMaterialImage('assets/images/earth.jpeg'),
                 doubleSided: true,
                ),
              ]
            ),
            // position: Vector3.zero(),
          );
          c.add(node);
        },
      ),
    );
  }
}
