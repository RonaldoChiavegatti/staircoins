import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/core/di/injection_container.dart' as di;
import 'package:staircoins/firebase_options.dart';
import 'package:staircoins/login_screen.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/produto_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/scripts/firebase_seed.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar injeção de dependências
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TurmaProvider>(
          create: (_) => di.sl<TurmaProvider>(),
          update: (_, auth, previousTurmaProvider) {
            final turmaProvider =
                previousTurmaProvider ?? di.sl<TurmaProvider>();
            // Só recarregar as turmas se o usuário estiver autenticado
            if (auth.isAuthenticated) {
              // Usar Future.microtask para não bloquear a UI
              Future.microtask(() => turmaProvider.init());
            }
            return turmaProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ProdutoProvider()),
      ],
      child: MaterialApp(
        title: 'StairCoins',
        theme: AppTheme.lightTheme,
        home: const LoginScreenWithSeed(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class LoginScreenWithSeed extends StatelessWidget {
  const LoginScreenWithSeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const LoginScreen(),
      persistentFooterButtons: [
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.data_array),
            label: const Text('Inicializar Firebase com dados de teste'),
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Inicializando Firebase com dados de teste...')),
                );

                final seed = FirebaseSeed(
                  firestore: FirebaseFirestore.instance,
                  auth: firebase_auth.FirebaseAuth.instance,
                );

                await seed.seed();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Firebase inicializado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao inicializar Firebase: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
