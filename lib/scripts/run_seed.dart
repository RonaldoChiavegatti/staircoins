import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:staircoins/firebase_options.dart';
import 'package:staircoins/scripts/firebase_seed.dart';

/// Script para executar a inicialização do Firebase com dados de teste
Future<void> main() async {
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    debugPrint('🔥 Firebase inicializado');
    
    // Instanciar FirebaseSeed
    final seed = FirebaseSeed(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    
    // Executar seed
    debugPrint('🌱 Iniciando seed de dados...');
    await seed.seed();
    
    debugPrint('✅ Seed concluído com sucesso!');
  } catch (e) {
    debugPrint('❌ Erro ao executar seed: $e');
  }
} 