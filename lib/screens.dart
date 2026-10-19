import 'package:flutter/material.dart';
import 'features/ar_experience/presentation/screens/ar_stage_screen.dart';
import 'features/ar_experience/presentation/screens/image_recognition_screen.dart';
import 'features/ar_experience/presentation/screens/sensorama_screen.dart';
import 'features/ar_experience/presentation/screens/sword_of_damocles_screen.dart';

export 'features/ar_experience/presentation/screens/image_recognition_screen.dart';
export 'features/ar_experience/presentation/screens/sensorama_screen.dart';
export 'features/ar_experience/presentation/screens/sword_of_damocles_screen.dart';

/// Legacy screens navigation container, updated to modern Clean Architecture destinations.
class ScreensPage extends StatelessWidget {
  const ScreensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wild AR'),
        centerTitle: true,
        backgroundColor: const Color(0xFF161624),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArStageScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  'AR Road Wildlife (Live Camera)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SensoramaScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.public),
                label: const Text('Sensorama'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageRecognitionScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.image_search),
                label: const Text('Image Recognition'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SwordOfDamoclesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Sword of Damocles'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}