import 'package:flutter/material.dart';
import 'package:wild_ar/src/ar_kit/image_recognition.dart';
import 'package:wild_ar/src/ar_kit/senorama.dart';
import 'package:wild_ar/src/ar_kit/sword_of_democles.dart';
import 'package:wild_ar/video.dart';

class ScreensPage extends StatefulWidget {
  const ScreensPage({super.key});

  @override
  State<ScreensPage> createState() => _ScreensPageState();
}

class _ScreensPageState extends State<ScreensPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Views")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SwordOfDemocles(),
                  ),
                );
              },
              child: const Text('Sword of Democles'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SensoramaView()));
              },
              child: const Text("Sensorama"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ImageRecognation()));
              },
              child: const Text('Image Recognaition'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ARVideo()));
              },
              child: const Text('AR Video'),
            )
          ],
        ),
      ),
    );
  }
}
