import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure([this.message = 'Ocorreu um erro']);
  
  @override
  List<Object> get props => [message];
}

// Falhas gerais
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro de cache']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet']);
}

// Falhas específicas de autenticação
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erro de autenticação']);
}

class EmailJaExisteFailure extends AuthFailure {
  const EmailJaExisteFailure([super.message = 'Este email já está em uso']);
}

class CredenciaisInvalidasFailure extends AuthFailure {
  const CredenciaisInvalidasFailure([super.message = 'Email ou senha inválidos']);
}

class UsuarioNaoAutenticadoFailure extends AuthFailure {
  const UsuarioNaoAutenticadoFailure([super.message = 'Usuário não autenticado']);
}

// Falhas específicas de turmas
class TurmaFailure extends Failure {
  const TurmaFailure([super.message = 'Erro ao processar turma']);
}

class CodigoTurmaExistenteFailure extends Failure {
  final String codigo;

  const CodigoTurmaExistenteFailure(this.codigo, [String message = ''])
    : super(message == '' ? 'O código de turma já está em uso' : message);
}

class TurmaNaoEncontradaFailure extends Failure {
  final String codigo;

  const TurmaNaoEncontradaFailure(this.codigo, [String message = ''])
    : super(message == '' ? 'Turma não encontrada' : message);
}

// Falhas de permissão
class PermissaoNegadaFailure extends Failure {
  const PermissaoNegadaFailure([super.message = 'Você não tem permissão para realizar esta ação']);
} 