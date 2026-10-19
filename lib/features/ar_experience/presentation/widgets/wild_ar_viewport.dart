import 'dart:io';
import 'package:flutter/material.dart';
import 'android_ar_core_view.dart';
import 'ios_ar_kit_view.dart';

class WildArViewport extends StatelessWidget {
  const WildArViewport({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const AndroidArCoreView();
    } else if (Platform.isIOS) {
      return const IosArKitView();
    }
    return const Center(
      child: Text(
        'AR is only supported on Android and iOS devices.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}