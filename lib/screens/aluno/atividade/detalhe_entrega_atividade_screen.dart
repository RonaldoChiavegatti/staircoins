import 'package:flutter/material.dart';
import 'package:staircoins/models/atividade.dart';

class DetalheEntregaAtividadeScreen extends StatelessWidget {
  final Atividade atividade;

  const DetalheEntregaAtividadeScreen({Key? key, required this.atividade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrega da Atividade: ${atividade.titulo}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 16),
              Text(
                'Esta é a tela de detalhes para a entrega da atividade:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                atividade.titulo,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Aqui você poderá adicionar anexos e finalizar a entrega.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}