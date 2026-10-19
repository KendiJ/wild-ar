import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provider for accessing the [CameraPermissionService].
final cameraPermissionServiceProvider =
    Provider<CameraPermissionService>((ref) {
  return const CameraPermissionService();
});

/// Service responsible for managing camera permissions required by ARCore and ARKit.
class CameraPermissionService {
  const CameraPermissionService();

  /// Checks the current status of the camera permission.
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Prompts the user to grant camera access if not already granted.
  Future<bool> requestCameraPermission() async {
    final currentStatus = await Permission.camera.status;
    if (currentStatus.isGranted) {
      return true;
    }

    final newStatus = await Permission.camera.request();
    return newStatus.isGranted;
  }

  /// Opens the device app settings if permission was permanently denied.
  Future<bool> openAppSettings() async {
    return openAppSettings();
  }
}
