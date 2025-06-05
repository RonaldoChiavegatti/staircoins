// Exceções para a camada de Dados (Data Layer)

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Ocorreu um erro no servidor']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Erro ao acessar o cache local']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sem conexão com a internet']);
}

// Exceções específicas do Firebase
class FirebaseAuthException implements Exception {
  final String code;
  final String message;
  
  FirebaseAuthException({required this.code, required this.message});
}

class FirestoreException implements Exception {
  final String code;
  final String message;
  
  FirestoreException({required this.code, required this.message});
}

// Exceções específicas do domínio
class TurmaException implements Exception {
  final String message;
  TurmaException(this.message);
}

class CodigoTurmaDuplicadoException implements Exception {
  final String codigo;
  CodigoTurmaDuplicadoException(this.codigo);
  
  @override
  String toString() => 'O código de turma "$codigo" já está em uso';
}

class EmailDuplicadoException implements Exception {
  final String email;
  EmailDuplicadoException(this.email);
  
  @override
  String toString() => 'O email "$email" já está em uso';
}

class PermissaoNegadaException implements Exception {
  final String message;
  PermissaoNegadaException([this.message = 'Você não tem permissão para realizar esta ação']);
  
  @override
  String toString() => message;
}

class TurmaNaoEncontradaException implements Exception {
  final String codigo;
  TurmaNaoEncontradaException(this.codigo);
  
  @override
  String toString() => 'Turma com código "$codigo" não encontrada';
} 