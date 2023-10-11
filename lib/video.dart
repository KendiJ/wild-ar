import 'dart:math' as math;

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:video_player/video_player.dart';

class ARVideo extends StatefulWidget {
  const ARVideo({super.key});

  @override
  State<ARVideo> createState() => _ARVideoState();
}

class _ARVideoState extends State<ARVideo> {
  late ARKitController controller;
  late ARKitMaterialVideo materialVideo;
  late VideoPlayerController videoPlayerController;

  @override
  void dispose() {
    videoPlayerController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Video"),
      ),
      body: ARKitSceneView(
        onARKitViewCreated: (con) => onARKitViewCreated(con),
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) async {
    this.controller = controller;

    materialVideo = ARKitMaterialProperty.video(
        width: 640,
        height: 360,
        // url: 'https://cdn.shuzia.com/assets%2Fmigration1.MP4',
        url: 'https://cdn.shuzia.com/assets%2Fmigration4.MP4'
        // url: 'https://cdn.shuzia.com/assets%2Fmigration3.MP4'
        );
    final material = ARKitMaterial(
      diffuse: materialVideo,
      doubleSided: true,
    );

    final sphere = ARKitSphere(
      radius: 1,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.video(
              width: 480,
              height: 270,
              // url: 'https://cdn.shuzia.com/assets%2Fmigration1.MP4',
              url: 'https://cdn.shuzia.com/assets%2Fmigration4.MP4'
              // url: 'https://cdn.shuzia.com/assets%2Fmigration3.MP4'
              ),
          doubleSided: true,
        ),
      ],
    );

    final node = ARKitNode(geometry: sphere);
    node.eulerAngles = vector.Vector3(0, 0, math.pi);

    this.controller.add(node);
  }
}
