import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/entrega_atividade.dart';
import 'dart:typed_data'; // Import Uint8List

class FirebaseEntregaAtividadeDatasource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseEntregaAtividadeDatasource({
    required this.firestore,
    required this.storage,
  });

  Future<void> entregarAtividade(EntregaAtividade entrega) async {
    await firestore
        .collection('entregas_atividade')
        .doc(entrega.id)
        .set(entrega.toJson());
  }

  Future<void> atualizarEntrega(EntregaAtividade entrega) async {
    await firestore
        .collection('entregas_atividade')
        .doc(entrega.id)
        .update(entrega.toJson());
  }

  Future<List<EntregaAtividade>> getEntregasByAtividade(
      String atividadeId) async {
    final query = await firestore
        .collection('entregas_atividade')
        .where('atividadeId', isEqualTo: atividadeId)
        .get();
    return query.docs
        .map((doc) => EntregaAtividade.fromJson(doc.data()))
        .toList();
  }

  Future<List<EntregaAtividade>> getEntregasByAluno(String alunoId) async {
    final query = await firestore
        .collection('entregas_atividade')
        .where('alunoId', isEqualTo: alunoId)
        .get();
    return query.docs
        .map((doc) => EntregaAtividade.fromJson(doc.data()))
        .toList();
  }

  Future<EntregaAtividade?> getEntregaByAtividadeAndAluno(
      String atividadeId, String alunoId) async {
    final query = await firestore
        .collection('entregas_atividade')
        .where('atividadeId', isEqualTo: atividadeId)
        .where('alunoId', isEqualTo: alunoId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return EntregaAtividade.fromJson(query.docs.first.data());
  }

  Future<String> uploadAnexo(String entregaId, File file) async {
    final ref = storage
        .ref()
        .child('entregas_atividade/$entregaId/${file.path.split('/').last}');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadAnexoWeb(String entregaId, Uint8List fileBytes) async {
    final fileName =
        'anexo_${DateTime.now().millisecondsSinceEpoch}'; // Generic filename for web
    final ref = storage.ref().child('entregas_atividade/$entregaId/$fileName');
    final uploadTask = await ref.putData(fileBytes);
    return await uploadTask.ref.getDownloadURL();
  }
}
