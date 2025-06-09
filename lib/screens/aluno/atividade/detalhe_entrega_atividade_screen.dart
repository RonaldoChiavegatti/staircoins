import 'package:flutter/material.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/entrega_atividade_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staircoins/models/entrega_atividade.dart' as model;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class DetalheEntregaAtividadeScreen extends StatefulWidget {
  final Atividade atividade;

  const DetalheEntregaAtividadeScreen({Key? key, required this.atividade})
      : super(key: key);

  @override
  State<DetalheEntregaAtividadeScreen> createState() =>
      _DetalheEntregaAtividadeScreenState();
}

class _DetalheEntregaAtividadeScreenState
    extends State<DetalheEntregaAtividadeScreen> {
  File? _selectedFile;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _isSubmitting = false;

  // Função auxiliar para encontrar a entrega (copiada de aluno_atividades_screen)
  model.EntregaAtividade? _findEntrega(String atividadeId, String? userId,
      EntregaAtividadeProvider entregaProvider) {
    if (userId == null) return null;
    for (final entrega in entregaProvider.entregas) {
      if (entrega.atividadeId == atividadeId && entrega.alunoId == userId) {
        return entrega;
      }
    }
    return null;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      String? fileName = platformFile.name;
      Uint8List? fileBytes = platformFile.bytes;

      File? file;
      if (!kIsWeb && platformFile.path != null) {
        file = File(platformFile.path!);
      }

      setState(() {
        _selectedFileName = fileName;
        _selectedFileBytes = fileBytes;
        _selectedFile = file;
      });
    }
  }

  Future<void> _entregarAtividade() async {
    if (kIsWeb) {
      if (_selectedFileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selecione um anexo para entregar a atividade.')),
        );
        return;
      }
    } else {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selecione um anexo para entregar a atividade.')),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });
    final provider =
        Provider.of<EntregaAtividadeProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }
    final entregaId = const Uuid().v4();
    String? anexoUrl;

    if (kIsWeb) {
      anexoUrl =
          await provider.uploadAnexo(entregaId, fileBytes: _selectedFileBytes!);
    } else {
      anexoUrl = await provider.uploadAnexo(entregaId, file: _selectedFile!);
    }

    if (anexoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao fazer upload do anexo.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }
    final entrega = model.EntregaAtividade(
      id: entregaId,
      atividadeId: widget.atividade.id,
      alunoId: user.uid,
      dataEntrega: DateTime.now(),
      anexoUrl: anexoUrl,
      status: 'entregue',
      nota: null,
      feedback: null,
    );
    await provider.entregarAtividade(entrega);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Atividade entregue com sucesso!')),
    );
    setState(() {
      _isSubmitting = false;
    });
    Navigator.of(context).pop();
  }

  // Utility function to check if a file extension corresponds to an image
  bool _isImageFile(String? fileNameOrUrl) {
    if (fileNameOrUrl == null) return false;
    final lowerCaseString = fileNameOrUrl.toLowerCase();
    return lowerCaseString.endsWith('.jpg') ||
        lowerCaseString.endsWith('.jpeg') ||
        lowerCaseString.endsWith('.png') ||
        lowerCaseString.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    final entregaProvider = Provider.of<EntregaAtividadeProvider>(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    // Usa a função auxiliar para encontrar a entrega
    final entrega = _findEntrega(widget.atividade.id, userId, entregaProvider);

    final status = entrega?.status;
    final nota = entrega?.nota;
    final feedback = entrega?.feedback;

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrega da Atividade: ${widget.atividade.titulo}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_outlined,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Selecione um anexo para entregar a atividade:',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                widget.atividade.titulo,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (status == null ||
                  status == 'pendente' ||
                  status == 'atrasado') ...[
                if (_selectedFileName != null)
                  if (_isImageFile(_selectedFileName) &&
                      _selectedFile != null &&
                      !kIsWeb)
                    Image.file(_selectedFile!, height: 120)
                  else
                    Text('Arquivo selecionado: $_selectedFileName')
                else
                  const Text('Nenhum anexo selecionado.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Selecionar Anexo'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _entregarAtividade,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Entregar Atividade'),
                ),
              ] else ...[
                const Text('Atividade já entregue!',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (nota != null)
                  Text('Nota: $nota',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                if (feedback != null && feedback.isNotEmpty)
                  Text('Feedback: $feedback'),
                if (entrega?.anexoUrl != null && entrega!.anexoUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Anexo Entregue:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_isImageFile(entrega.anexoUrl))
                          Image.network(entrega.anexoUrl!, height: 120)
                        else
                          Text(
                              'Anexo disponível: ${Uri.decodeComponent(entrega.anexoUrl!.split('/').last.split('?').first)}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
