import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ARKitController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ARKitSceneView(
        onARKitViewCreated: (con) => onArkitViewCreated(con),
      ),
    );
  }

  void onArkitViewCreated(ARKitController c) {
    controller = c;
    final node = ARKitNode(
      // --------**** word of Democles Demo ****-------- stl
      // geometry: ARKitBox(width: 0.1, height: 0.1, length: 0.1, materials: [
      //   ARKitMaterial(fillMode: ARKitFillMode.lines, transparency: 0.5)
      // ]),
      // position: Vector3(0, 0, -0.5),

      // --------**** Sensorama Demo ****-------- stl
      // geometry: ARKitSphere(
      //   radius: 0.1,
      //   materials: [
      //     ARKitMaterial(
      //       diffuse: ARKitMaterialProperty(
      //         image: const AssetImage('assets/images/earth.jpeg'),
      //       ),
      //     ),
      //   ],
      // ),
      // position: Vector3.zero(),

      geometry: ARKitSphere(
        radius: 1,
        materials: [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.video(
              width: 480,
              height: 270,
              // filename: 'assets/videos/migration1.mp4',
              url: 'https://cdn.shuzia.com/assets%2Fmigration1.MP4',
            ),
            doubleSided: true,
          ),
        ],
      ),
      position: Vector3.zero(),
    );
    controller.add(node);
  }
}
