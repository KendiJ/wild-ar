/// Centralized registry of all local bundle assets and remote streaming media URLs.
class AssetPaths {
  AssetPaths._();

  // Local Video Assets
  static const String migration1Video = 'assets/videos/migration1.mp4';
  static const String migration2Video = 'assets/videos/migration2.MP4';

  // Local Image Assets
  static const String earthImage = 'assets/images/earth.jpeg';
  static const String earthJpgImage = 'assets/images/earth.jpg';
  static const String globeImage = 'assets/images/globe.jpeg';
  static const String kiccPngImage = 'assets/images/kicc.png';
  static const String kiccJpegImage = 'assets/images/KICC.jpeg';

  // Remote Shuzia CDN Video Streams
  static const String cdnMigration1 =
      'https://cdn.shuzia.com/assets%2Fmigration1.MP4';
  static const String cdnMigration3 =
      'https://cdn.shuzia.com/assets%2Fmigration3.MP4';
  static const String cdnMigration4 =
      'https://cdn.shuzia.com/assets%2Fmigration4.MP4';

  // Default initial video source
  static const String defaultVideo = migration1Video;
}
