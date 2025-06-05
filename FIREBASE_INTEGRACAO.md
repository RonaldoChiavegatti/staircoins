# Integração Firebase - Star Coins

## Estrutura do Firestore

### Coleção `users`
- **Campos**: 
  - id (UID do Firebase Auth)
  - name (string)
  - email (string)
  - tipo ('professor' ou 'aluno')
  - staircoins (number, para alunos)
  - turmas (array de IDs)
  - createdAt (timestamp)

### Coleção `turmas`
- **Campos**:
  - id (gerado automaticamente)
  - nome (string)
  - descricao (string)
  - codigo (string, único)
  - professorId (string, referência ao ID do professor)
  - alunos (array de IDs de alunos)
  - atividades (array de IDs de atividades)
  - createdAt (timestamp)

### Coleção `atividades`
- **Campos**:
  - id (gerado automaticamente)
  - titulo (string)
  - descricao (string)
  - turmaId (string, referência à turma)
  - pontuacao (number)
  - dataEntrega (timestamp)
  - status ('ativa', 'encerrada')
  - createdAt (timestamp)

### Coleção `produtos`
- **Campos**:
  - id (gerado automaticamente)
  - nome (string)
  - descricao (string)
  - preco (number)
  - disponivel (boolean)
  - professorId (string, referência ao professor)
  - createdAt (timestamp)

## Checklist de Implementação

### 1. Configuração Inicial
- [x] Adicionar dependências do Firebase ao pubspec.yaml
- [x] Configurar Firebase no projeto manualmente (sem CLI flutterfire)
- [x] Criar arquivo firebase_options.dart manualmente
- [x] Inicializar Firebase no main.dart
- [x] Configurar Firebase Authentication
- [x] Configurar Firestore

### 2. Camada de Dados
- [x] Criar interfaces de repositórios (abstrações)
  - [x] AuthRepository
  - [x] TurmaRepository
  - [x] AlunoRepository
  - [x] AtividadeRepository
  - [x] ProdutoRepository
- [x] Implementar datasources do Firebase
  - [x] FirebaseAuthDatasource
  - [x] FirestoreTurmaDatasource
  - [x] FirestoreAlunoDatasource
  - [x] FirestoreAtividadeDatasource
  - [x] FirestoreProdutoDatasource
- [x] Implementar repositórios concretos
  - [x] FirebaseAuthRepository
  - [x] FirebaseTurmaRepository
  - [x] FirebaseAlunoRepository
  - [x] FirebaseAtividadeRepository
  - [x] FirebaseProdutoRepository

### 3. Adaptar Modelos
- [x] Atualizar User para suportar Firestore
- [x] Atualizar Turma para suportar Firestore
- [x] Atualizar Atividade para suportar Firestore
- [x] Atualizar Produto para suportar Firestore

### 4. Adaptar Providers
- [x] Refatorar AuthProvider para usar FirebaseAuthRepository
- [x] Refatorar TurmaProvider para usar FirebaseTurmaRepository
- [x] Refatorar AtividadeProvider para usar FirebaseAtividadeRepository
- [x] Refatorar ProdutoProvider para usar FirebaseProdutoRepository

### 5. Implementar Validações e Tratamento de Erros
- [x] Criar enum StarCoinsError
- [x] Implementar validação de código único de turma
- [x] Implementar validação de email único
- [x] Implementar verificação de permissões

### 6. Regras de Segurança do Firestore
- [x] Configurar regras para coleção users
- [x] Configurar regras para coleção turmas
- [x] Configurar regras para coleção atividades
- [x] Configurar regras para coleção produtos

### 7. Migração de Dados
- [x] Criar script para migrar dados mockados para Firebase
- [x] Implementar toggle entre mock e Firebase para testes

### 8. Testes
- [ ] Testar autenticação (login/registro)
- [ ] Testar CRUD de turmas
- [ ] Testar CRUD de atividades
- [ ] Testar CRUD de produtos
- [ ] Testar entrada de alunos em turmas

### 9. Otimizações
- [x] Configurar índices no Firestore
- [x] Implementar paginação para listas grandes
- [x] Otimizar consultas

### 10. Deploy
- [ ] Configurar ambientes (dev/prod)
- [ ] Finalizar regras de segurança
- [ ] Realizar testes finais
- [ ] Deploy para produção 