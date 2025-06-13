import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/core/utils/app_restart.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/produto_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/auth/login_screen.dart';
import 'package:staircoins/screens/splash_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/screens/professor/professor_configuracoes_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    ImageProvider<Object>? avatarImage;
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user.photoUrl!);
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'StarCoins',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarImage,
                    child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? null
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?.nome ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfessorConfiguracoesScreen()));
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              // Mostrar indicador de carregamento
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );

              try {
                // Fazer logout
                await authProvider.logout();

                // Limpar dados de todos os providers
                if (context.mounted) {
                  // Limpar TurmaProvider
                  final turmaProvider =
                      Provider.of<TurmaProvider>(context, listen: false);
                  turmaProvider.limparDados();

                  // Limpar AtividadeProvider
                  final atividadeProvider =
                      Provider.of<AtividadeProvider>(context, listen: false);
                  atividadeProvider.limparDados();

                  // Limpar ProdutoProvider
                  final produtoProvider =
                      Provider.of<ProdutoProvider>(context, listen: false);
                  produtoProvider.limparDados();

                  // Fechar o diálogo de carregamento
                  Navigator.of(context).pop();

                  // Reiniciar o app (irá exibir a SplashScreen e seguir o fluxo normal)
                  AppRestart.restartApp(context);
                }
              } catch (e) {
                // Em caso de erro, fechar o diálogo e mostrar mensagem
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao fazer logout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
