import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../controllers/ar_session_notifier.dart';

/// iOS ARKit implementation preserving compatibility with arkit_plugin.
/// Eliminates legacy uninitialized videoPlayerController.dispose() crashes and anchors
/// vertical video quads directly onto detected horizontal planes.
class IosArKitView extends ConsumerStatefulWidget {
  const IosArKitView({super.key});

  @override
  ConsumerState<IosArKitView> createState() => _IosArKitViewState();
}

class _IosArKitViewState extends ConsumerState<IosArKitView> {
  ARKitController? _arkitController;
  final List<String> _anchoredNodeNames = [];
  int _nodeIndex = 0;

  @override
  void dispose() {
    _arkitController?.dispose();
    _arkitController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ARKitSceneView(
      planeDetection: ARPlaneDetection.horizontal,
      showFeaturePoints: false,
      enableTapRecognizer: true,
      onARKitViewCreated: _onARKitViewCreated,
    );
  }

  void _onARKitViewCreated(ARKitController controller) {
    _arkitController = controller;
    final notifier = ref.read(arSessionNotifierProvider.notifier);

    // Plane detection callbacks
    controller.onAddNodeForAnchor = (ARKitAnchor anchor) {
      if (anchor is ARKitPlaneAnchor) {
        notifier.onPlaneDetected(1);
      }
    };

    // Tap to anchor video quad onto detected ground plane
    controller.onARTap = (List<ARKitTestResult> hits) {
      final planeHit = hits.cast<ARKitTestResult?>().firstWhere(
            (hit) =>
                hit?.type ==
                    ARKitHitTestResultType.existingPlaneUsingExtent ||
                hit?.type == ARKitHitTestResultType.estimatedHorizontalPlane,
            orElse: () => null,
          );

      if (planeHit != null) {
        final transform = planeHit.worldTransform;
        final x = transform.getColumn(3).x;
        final y = transform.getColumn(3).y;
        final z = transform.getColumn(3).z;

        _anchorVideoQuad(x, y, z);
      }
    };
  }

  void _anchorVideoQuad(double x, double y, double z) {
    final controller = _arkitController;
    if (controller == null) return;

    final config = ref.read(arSessionNotifierProvider).config;
    final nodeName = 'wildlife_quad_${_nodeIndex++}';

    final width = 2.4 * config.scale;
    final height = 1.35 * config.scale;
    final halfHeight = height / 2.0;

    ARKitMaterialProperty materialProperty;
    if (config.isLocal) {
      materialProperty = ARKitMaterialProperty.video(
        filename: config.videoPath,
        width: 1280,
        height: 720,
      );
    } else {
      materialProperty = ARKitMaterialProperty.video(
        url: config.videoPath,
        width: 1280,
        height: 720,
      );
    }

    final videoMaterial = ARKitMaterial(
      diffuse: materialProperty,
      doubleSided: true,
    );

    final planeGeometry = ARKitPlane(
      width: width,
      height: height,
      materials: [videoMaterial],
    );

    // Position node with its base at ground level (y + halfHeight)
    final node = ARKitNode(
      name: nodeName,
      geometry: planeGeometry,
      position: vector.Vector3(x, y + halfHeight, z),
      // Rotate 90 degrees around X to make plane vertical instead of flat
      eulerAngles: vector.Vector3(-1.5707963, 0, 0),
    );

    controller.add(node);
    _anchoredNodeNames.add(nodeName);

    ref.read(arSessionNotifierProvider.notifier).onAnchorPlaced(x, y, z);
  }
}
