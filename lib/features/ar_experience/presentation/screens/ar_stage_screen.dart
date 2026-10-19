import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/permissions/camera_permission_service.dart';
import '../controllers/ar_session_notifier.dart';
import '../widgets/wild_ar_viewport.dart';

/// Full-screen, minimal AR experience stage screen.
class ArStageScreen extends ConsumerStatefulWidget {
  const ArStageScreen({super.key});

  @override
  ConsumerState<ArStageScreen> createState() => _ArStageScreenState();
}

class _ArStageScreenState extends ConsumerState<ArStageScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final permissionService = ref.read(cameraPermissionServiceProvider);
    final granted = await permissionService.isCameraPermissionGranted();
    if (!granted && mounted) {
      final requested = await permissionService.requestCameraPermission();
      if (mounted) {
        setState(() {
          _hasPermission = requested;
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() {
        _hasPermission = granted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: const Color(0xFF14141E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 72,
                  color: Colors.amberAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Camera Access Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Wild AR needs camera access to display live wildlife on the road.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _checkPermission,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Grant Camera Permission'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen Native Camera + OpenGL Wildlife View
          const WildArViewport(),

          // 2. Minimal Top Bar: Back Button + Single Instruction Pill
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Tap on the road to place wildlife',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balances the row
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 3. Single Reset Button in Bottom-Right
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        tooltip: 'Clear Road Wildlife',
        onPressed: () {
          ref.read(arSessionNotifierProvider.notifier).clearAnchors();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}