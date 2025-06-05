// Arquivo gerado pelo comando flutterfire configure
// Este é um arquivo modelo e deve ser substituído pelo arquivo gerado pelo flutterfire

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurações padrão do Firebase para o aplicativo StairCoins.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foi configurado para windows - '
          'você pode reconfigurá-lo usando o comando flutterfire configure',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foi configurado para linux - '
          'você pode reconfigurá-lo usando o comando flutterfire configure',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não está disponível para esta plataforma.',
        );
    }
  }

  // IMPORTANTE: Substitua estes valores pelos valores reais gerados pelo flutterfire configure
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBq_eh_JAgb1pE-E3qtnmr5tBPDeT-3-R4',
    appId: '1:878771198572:web:1a840c86f880b56ec15649',
    messagingSenderId: '878771198572',
    projectId: 'starcoins-782b2',
    authDomain: 'starcoins-782b2.firebaseapp.com',
    storageBucket: 'starcoins-782b2.firebasestorage.app',
    measurementId: 'G-MWVWGGGDFN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8ThpEN91P9SUNhyeUTvZZJjbePaK31Gg',
    appId: '1:878771198572:android:eacba35b09962cfcc15649',
    messagingSenderId: '878771198572',
    projectId: 'starcoins-782b2',
    storageBucket: 'starcoins-782b2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCkiahqj8pQ9ElFXqQ_VzBGFdOSjXXZSDo',
    appId: '1:878771198572:ios:f107759c7c6c8891c15649',
    messagingSenderId: '878771198572',
    projectId: 'starcoins-782b2',
    storageBucket: 'starcoins-782b2.firebasestorage.app',
    iosBundleId: 'com.example.staircoins',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCkiahqj8pQ9ElFXqQ_VzBGFdOSjXXZSDo',
    appId: '1:878771198572:ios:f107759c7c6c8891c15649',
    messagingSenderId: '878771198572',
    projectId: 'starcoins-782b2',
    storageBucket: 'starcoins-782b2.firebasestorage.app',
    iosBundleId: 'com.example.staircoins',
  );
} 