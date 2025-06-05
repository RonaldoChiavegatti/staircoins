# Arquitetura do Projeto StairCoins

## Visão Geral

O projeto StairCoins segue os princípios de Clean Architecture e SOLID, organizando o código em camadas bem definidas com responsabilidades claras. A arquitetura foi projetada para facilitar a manutenção, testabilidade e escalabilidade do aplicativo.

## Camadas da Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                     Camada de Apresentação                      │
│  ┌──────────┐      ┌───────────┐       ┌────────────────────┐   │
│  │ Screens  │◄────►│  Widgets  │◄─────►│ Providers (State)  │   │
│  └──────────┘      └───────────┘       └────────────────────┘   │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Camada de Domínio                        │
│  ┌───────────────────────┐    ┌────────────┐    ┌───────────┐   │
│  │ Repository Interfaces │    │  Use Cases │    │   Models  │   │
│  └───────────────────────┘    └────────────┘    └───────────┘   │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Camada de Dados                          │
│  ┌───────────────────────┐           ┌───────────────────────┐  │
│  │ Repository Impl       │◄─────────►│ DataSources           │  │
│  │ ┌─────────────────┐   │           │ ┌─────────────────┐   │  │
│  │ │ AuthRepository  │   │           │ │ FirebaseAuth    │   │  │
│  │ └─────────────────┘   │           │ └─────────────────┘   │  │
│  │ ┌─────────────────┐   │           │ ┌─────────────────┐   │  │
│  │ │ TurmaRepository │   │           │ │ FirestoreData   │   │  │
│  │ └─────────────────┘   │           │ └─────────────────┘   │  │
│  └───────────────────────┘           └───────────────────────┘  │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Camada de Infraestrutura                     │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────┐  │
│  │ DI (get_it)  │  │ Network Info │  │ Errors/Exceptions     │  │
│  └──────────────┘  └──────────────┘  └───────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 1. Camada de Apresentação (UI)
- **Screens**: Contém as telas do aplicativo
- **Widgets**: Componentes reutilizáveis
- **Providers**: Gerenciadores de estado usando o padrão Provider

### 2. Camada de Domínio
- **Repositories (Interfaces)**: Contratos para acesso a dados
- **Models**: Entidades de domínio
- **Use Cases**: Regras de negócio específicas (quando necessário)

### 3. Camada de Dados
- **Repositories (Implementações)**: Implementações concretas dos repositórios
- **DataSources**: Fontes de dados (Firebase, cache local, etc.)

### 4. Camada de Core/Infraestrutura
- **DI**: Injeção de dependências
- **Network**: Verificação de conectividade
- **Errors**: Tratamento de erros e exceções

## Fluxo de Dados

```
┌───────────┐     ┌────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌───────────────┐     ┌─────────────┐
│           │     │            │     │                 │     │                 │     │               │     │             │
│    UI     │◄───►│  Providers │◄───►│  Repositories   │◄───►│  Repositories   │◄───►│  DataSources  │◄───►│  Firebase/  │
│  Screens  │     │   State    │     │  (Interfaces)   │     │ (Implementation)│     │               │     │  Storage    │
│           │     │            │     │                 │     │                 │     │               │     │             │
└───────────┘     └────────────┘     └─────────────────┘     └─────────────────┘     └───────────────┘     └─────────────┘
```

## Injeção de Dependências

Utilizamos o pacote `get_it` para gerenciar as dependências do aplicativo, seguindo o princípio de inversão de dependência (SOLID). As dependências são configuradas no arquivo `lib/core/di/injection_container.dart`.

```
┌───────────────────────────────────────────────────────────────────────┐
│                       Injeção de Dependências                         │
│                                                                       │
│  ┌─────────────┐        registra       ┌─────────────────────────┐    │
│  │             │◄─────────────────────►│                         │    │
│  │   get_it    │                       │  injection_container.dart│    │
│  │  container  │                       │                         │    │
│  │             │                       │                         │    │
│  └─────────────┘                       └─────────────────────────┘    │
│         ▲                                                             │
│         │                                                             │
│         │ resolve                                                     │
│         │                                                             │
│  ┌──────┴──────┐     ┌─────────────┐      ┌────────────────┐          │
│  │             │     │             │      │                │          │
│  │  Providers  │     │ Repositories│      │  DataSources   │          │
│  │             │     │             │      │                │          │
│  └─────────────┘     └─────────────┘      └────────────────┘          │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

## Tratamento de Erros

O tratamento de erros é feito usando o padrão Either do pacote `dartz`, que permite retornar ou um sucesso (Right) ou uma falha (Left), tornando explícito o tratamento de erros.

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                           Padrão Either (dartz)                               │
│                                                                               │
│  ┌─────────────────────┐                          ┌─────────────────────────┐ │
│  │                     │                          │                         │ │
│  │  Left<Failure, T>   │◄─── Erro/Falha ──────────┤  Future<Either<F, S>>   │ │
│  │                     │                          │                         │ │
│  └─────────────────────┘                          └─────────────────────────┘ │
│                                                             │                 │
│                                                             │                 │
│  ┌─────────────────────┐                                    │                 │
│  │                     │                                    │                 │
│  │  Right<Failure, T>  │◄─── Sucesso ────────────────────────                 │
│  │                     │                                                      │
│  └─────────────────────┘                                                      │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘

// Exemplo de método em um repositório
Future<Either<Failure, User>> login(String email, String password);
```

## Integração com Firebase

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                         Integração com Firebase                               │
│                                                                               │
│  ┌─────────────────────┐     ┌─────────────────────┐    ┌──────────────────┐  │
│  │                     │     │                     │    │                  │  │
│  │  Firebase Auth      │◄───►│  Authentication     │◄──►│  AuthRepository  │  │
│  │                     │     │  DataSource         │    │                  │  │
│  └─────────────────────┘     └─────────────────────┘    └──────────────────┘  │
│                                                                               │
│  ┌─────────────────────┐     ┌─────────────────────┐    ┌──────────────────┐  │
│  │                     │     │                     │    │                  │  │
│  │  Cloud Firestore    │◄───►│  Firestore          │◄──►│  TurmaRepository │  │
│  │                     │     │  DataSource         │    │                  │  │
│  └─────────────────────┘     └─────────────────────┘    └──────────────────┘  │
│                                                                               │
│  ┌─────────────────────┐     ┌─────────────────────┐                          │
│  │                     │     │                     │                          │
│  │  Firebase Storage   │◄───►│  Storage            │                          │
│  │  (opcional)         │     │  DataSource         │                          │
│  └─────────────────────┘     └─────────────────────┘                          │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### Firebase Authentication
- Gerenciamento de autenticação de usuários (alunos e professores)
- Registro, login, logout e recuperação de senha

### Cloud Firestore
- Armazenamento de dados estruturados
- Collections: users, turmas, atividades, produtos

### Firebase Storage (opcional)
- Armazenamento de arquivos (imagens de perfil, etc.)

## Estrutura de Diretórios

```
lib/
├── core/
│   ├── di/                  # Injeção de dependências
│   ├── errors/              # Classes de erros e exceções
│   └── network/             # Verificação de conectividade
├── data/
│   ├── datasources/         # Implementações de fontes de dados
│   └── repositories/        # Implementações de repositórios
├── domain/
│   └── repositories/        # Interfaces de repositórios
├── models/                  # Modelos/entidades
├── providers/               # Gerenciadores de estado
├── screens/                 # Telas do aplicativo
├── theme/                   # Configurações de tema
├── widgets/                 # Widgets reutilizáveis
├── firebase_options.dart    # Configurações do Firebase
└── main.dart                # Ponto de entrada do aplicativo
```

## Padrões de Design Utilizados

1. **Repository Pattern**: Abstrai a fonte de dados, permitindo trocar a implementação sem afetar o restante do código.
2. **Provider Pattern**: Gerenciamento de estado e injeção de dependências na UI.
3. **Dependency Injection**: Inversão de controle para facilitar testes e manutenção.
4. **Factory Pattern**: Criação de objetos em classes como `User.fromFirestore()`.
5. **Singleton Pattern**: Utilizado para instâncias únicas como FirebaseAuth.

## Regras de Segurança do Firestore

As regras de segurança do Firestore são configuradas para garantir que:

1. Apenas usuários autenticados podem ler/escrever dados
2. Professores só podem modificar suas próprias turmas
3. Alunos só podem ver turmas às quais pertencem
4. Códigos de turma são únicos

## Estratégia de Migração e Testes

Durante o desenvolvimento, implementamos uma estratégia de toggle entre dados mockados e Firebase, permitindo:

1. Desenvolvimento sem dependência imediata do Firebase
2. Testes unitários sem acesso a serviços externos
3. Migração gradual para o Firebase

## Considerações sobre Performance

1. Índices configurados no Firestore para consultas frequentes
2. Paginação para listas grandes
3. Uso de cache local para dados frequentemente acessados
4. Otimização de consultas para minimizar leituras/escritas no Firestore 