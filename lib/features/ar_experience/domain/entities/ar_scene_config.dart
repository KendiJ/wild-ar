/// AR Experience modes supported by the architecture.
enum ArExperienceMode {
  roadWildlifeVideo,
  imageTrackingKicc,
  sensoramaEarth,
  wireframePrimitives,
}

/// The media storage type for AR video projection.
enum VideoSourceType { localAsset, remoteCdn }

/// Immutable configuration entity governing AR projection, video source,
/// and real-time Chroma-Key / alpha-masking parameters.
class ArSceneConfig {
  final ArExperienceMode mode;
  final VideoSourceType sourceType;
  final String videoPath;
  final bool enableChromaKey;
  final List<double> keyColorRgb; // Normalized [R, G, B] to strip out
  final double similarityThreshold;
  final double edgeSmoothness;
  final double scale;
  final double bottomFeather; // Soft-edge feathering along road contact line

  const ArSceneConfig({
    this.mode = ArExperienceMode.roadWildlifeVideo,
    this.sourceType = VideoSourceType.localAsset,
    this.videoPath = 'assets/videos/migration1.mp4',
    this.enableChromaKey = true,
    this.keyColorRgb = const [0.55, 0.68, 0.78], // Default sky/horizon key
    this.similarityThreshold = 0.28,
    this.edgeSmoothness = 0.12,
    this.scale = 1.0,
    this.bottomFeather = 0.20,
  });

  bool get isLocal => sourceType == VideoSourceType.localAsset;

  ArSceneConfig copyWith({
    ArExperienceMode? mode,
    VideoSourceType? sourceType,
    String? videoPath,
    bool? enableChromaKey,
    List<double>? keyColorRgb,
    double? similarityThreshold,
    double? edgeSmoothness,
    double? scale,
    double? bottomFeather,
  }) {
    return ArSceneConfig(
      mode: mode ?? this.mode,
      sourceType: sourceType ?? this.sourceType,
      videoPath: videoPath ?? this.videoPath,
      enableChromaKey: enableChromaKey ?? this.enableChromaKey,
      keyColorRgb: keyColorRgb ?? this.keyColorRgb,
      similarityThreshold: similarityThreshold ?? this.similarityThreshold,
      edgeSmoothness: edgeSmoothness ?? this.edgeSmoothness,
      scale: scale ?? this.scale,
      bottomFeather: bottomFeather ?? this.bottomFeather,
    );
  }

  Map<String, dynamic> toMap() => {
        'mode': mode.name,
        'isLocal': sourceType == VideoSourceType.localAsset,
        'videoPath': videoPath,
        'enableChromaKey': enableChromaKey,
        'keyColorRgb': keyColorRgb,
        'similarityThreshold': similarityThreshold,
        'edgeSmoothness': edgeSmoothness,
        'scale': scale,
        'bottomFeather': bottomFeather,
      };

  factory ArSceneConfig.fromMap(Map<String, dynamic> map) {
    final modeName = map['mode'] as String? ?? 'roadWildlifeVideo';
    final isLocal = map['isLocal'] as bool? ?? true;
    final rgbRaw = map['keyColorRgb'] as List<dynamic>?;
    final rgb = rgbRaw != null
        ? rgbRaw.map((e) => (e as num).toDouble()).toList()
        : const [0.55, 0.68, 0.78];

    return ArSceneConfig(
      mode: ArExperienceMode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => ArExperienceMode.roadWildlifeVideo,
      ),
      sourceType: isLocal ? VideoSourceType.localAsset : VideoSourceType.remoteCdn,
      videoPath: map['videoPath'] as String? ?? 'assets/videos/migration1.mp4',
      enableChromaKey: map['enableChromaKey'] as bool? ?? true,
      keyColorRgb: rgb,
      similarityThreshold: (map['similarityThreshold'] as num?)?.toDouble() ?? 0.28,
      edgeSmoothness: (map['edgeSmoothness'] as num?)?.toDouble() ?? 0.12,
      scale: (map['scale'] as num?)?.toDouble() ?? 1.0,
      bottomFeather: (map['bottomFeather'] as num?)?.toDouble() ?? 0.20,
    );
  }
}
