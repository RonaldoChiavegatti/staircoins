import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:staircoins/core/network/network_info.dart';
import 'package:staircoins/data/datasources/firebase_auth_datasource.dart';
import 'package:staircoins/data/datasources/firebase_turma_datasource.dart';
import 'package:staircoins/data/repositories/firebase_auth_repository_impl.dart';
import 'package:staircoins/data/repositories/firebase_turma_repository_impl.dart';
import 'package:staircoins/domain/repositories/auth_repository.dart';
import 'package:staircoins/domain/repositories/turma_repository.dart';
import 'package:staircoins/providers/auth_provider.dart' as app_providers;
import 'package:staircoins/providers/turma_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  
  // InternetConnectionChecker só funciona em plataformas móveis
  if (!kIsWeb) {
    sl.registerLazySingleton(() => InternetConnectionChecker());
  }
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(kIsWeb ? null : sl<InternetConnectionChecker>()),
  );
  
  // Data sources
  sl.registerLazySingleton<FirebaseAuthDatasource>(
    () => FirebaseAuthDatasourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  
  sl.registerLazySingleton<FirebaseTurmaDatasource>(
    () => FirebaseTurmaDatasourceImpl(
      firestore: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepositoryImpl(
      datasource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton<TurmaRepository>(
    () => FirebaseTurmaRepositoryImpl(
      datasource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Providers
  sl.registerFactory(() => app_providers.AuthProvider(authRepository: sl()));
  sl.registerFactory(() => TurmaProvider(turmaRepository: sl()));
}

// Função para registrar mocks para testes
Future<void> initMock() async {
  // TODO: Implementar registro de mocks para testes
} 