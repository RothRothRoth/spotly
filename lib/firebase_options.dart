import 'package:firebase_core/firebase_core.dart';

/// Default Firebase options generated for the Spotly app.
/// This file contains only the Android configuration because the project
/// currently targets Android. Add iOS/macOS/web options as needed.
class DefaultFirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String storageBucket;

  const DefaultFirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.storageBucket,
  });

  // Android configuration derived from the provided google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDWYFM-l2jqa4PZSFcBmbRm-Hx8JjPXTQ',
    appId: '1:672351615093:android:f98f9d592dc32a1bcd603c',
    messagingSenderId: '672351615093',
    projectId: 'spotly-app-21963',
    storageBucket: 'spotly-app-21963.firebasestorage.app',
  );

  /// Returns the options for the current platform. For now we only support Android.
  static const FirebaseOptions currentPlatform = android;
}
