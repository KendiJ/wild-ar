import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../domain/entities/ar_scene_config.dart';
import '../controllers/ar_session_notifier.dart';
import 'ar_stage_screen.dart';
import 'image_recognition_screen.dart';
import 'sensorama_screen.dart';
import 'sword_of_damocles_screen.dart';

/// Clean, minimal Home Screen for Wild AR with 4 direct navigation options.
class ArDashboardScreen extends ConsumerWidget {
  const ArDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F17),
      appBar: AppBar(
        title: const Text(
          'Wild AR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161624),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMenuButton(
                  context: context,
                  icon: Icons.camera_alt,
                  title: 'AR Road Wildlife (Live Camera)',
                  subtitle: 'Ground-anchored unboxed wildlife',
                  isPrimary: true,
                  onTap: () {
                    // Ensure default local asset is loaded
                    ref.read(arSessionNotifierProvider.notifier).loadVideo(
                          AssetPaths.migration1Video,
                          VideoSourceType.localAsset,
                        );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ArStageScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _buildMenuButton(
                  context: context,
                  icon: Icons.public,
                  title: 'Sensorama',
                  subtitle: '360° Earth projection sphere',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SensoramaScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _buildMenuButton(
                  context: context,
                  icon: Icons.image_search,
                  title: 'Image Recognition',
                  subtitle: 'Reference target tracking',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ImageRecognitionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _buildMenuButton(
                  context: context,
                  icon: Icons.view_in_ar,
                  title: 'Sword of Damocles',
                  subtitle: 'Wireframe spatial primitive',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SwordOfDamoclesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          foregroundColor: const Color(0xFF0A1917),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF0A1917)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E3A34),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF0A1917)),
          ],
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A1A28),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12),
        ),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: const Color(0xFF00BFA5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
        ],
      ),
    );
  }
}
