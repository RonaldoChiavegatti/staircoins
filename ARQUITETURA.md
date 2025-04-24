# Arquitetura do Aplicativo StairCoins

## Visão Geral da Arquitetura

O StairCoins utiliza uma arquitetura baseada em Provider para gerenciamento de estado, seguindo padrões de projeto recomendados para aplicativos Flutter.

```
┌───────────────────────┐
│     Apresentação      │
│  (Screens, Widgets)   │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│    Lógica de Estado   │
│      (Providers)      │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│    Modelo de Dados    │
│       (Models)        │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│   Armazenamento Local │
│  (SharedPreferences)  │
└───────────────────────┘
```

## Diagrama de Fluxo de Dados

```
┌─────────────┐     ┌────────────┐     ┌────────────┐
│  UI Events  │────▶│  Providers │────▶│   Models   │
└─────────────┘     └─────┬──────┘     └────────────┘
                          │
                          ▼
                    ┌────────────┐
                    │  Storage   │
                    └────────────┘
```

## Estrutura de Pastas

```
lib/
├── main.dart                  # Ponto de entrada da aplicação
├── models/                    # Modelos de dados
│   ├── user.dart
│   ├── turma.dart
│   ├── atividade.dart
│   └── produto.dart
├── providers/                 # Gerenciamento de estado
│   ├── auth_provider.dart
│   ├── turma_provider.dart
│   └── atividade_provider.dart
├── screens/                   # Interfaces de usuário
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── splash_screen.dart
│   ├── professor/
│   │   ├── professor_home_screen.dart
│   │   ├── professor_turmas_screen.dart
│   │   ├── professor_atividades_screen.dart
│   │   └── professor_produtos_screen.dart
│   └── aluno/
│       ├── aluno_home_screen.dart
│       ├── aluno_turmas_screen.dart
│       ├── aluno_atividades_screen.dart
│       └── aluno_produtos_screen.dart
├── widgets/                   # Componentes reutilizáveis
│   ├── app_drawer.dart
│   ├── atividade_card.dart
│   ├── produto_card.dart
│   └── turma_card.dart
└── theme/                     # Definição do tema
    └── app_theme.dart
```

## Fluxo de Autenticação

```
┌────────────┐     ┌────────────┐     ┌─────────────┐
│Login Screen│────▶│AuthProvider│────▶│SharedPrefs  │
└────────────┘     └─────┬──────┘     └─────────────┘
                         │
                         ▼
                   ┌────────────┐
                   │ User Model │
                   └─────┬──────┘
                         │
                         ▼
               ┌─────────────────────┐
               │Professor/Aluno Home │
               └─────────────────────┘
```

## Fluxo de Dados (Turmas)

```
┌────────────┐     ┌────────────────┐     ┌───────────┐
│ Turma UI   │────▶│ TurmaProvider  │────▶│Turma Model│
└────────────┘     └────────┬───────┘     └───────────┘
                            │
                            ▼
                     ┌─────────────┐
                     │SharedPrefs  │
                     └─────────────┘
```

## Padrões de Arquitetura Aplicados

1. **Provider Pattern**: Para injeção de dependência e gerenciamento de estado
2. **Repository Pattern** (simulado): Os providers atuam como repositórios
3. **Factory Pattern**: Usado nos modelos para construção de objetos
4. **Observer Pattern**: Implementado através do ChangeNotifier

## Considerações para Backend

Quando o backend for implementado, a arquitetura será atualizada para:

```
┌───────────┐     ┌────────────┐     ┌───────────┐     ┌────────────┐
│   UI      │────▶│ Providers  │────▶│ Services  │────▶│   API      │
└───────────┘     └────────────┘     └───────────┘     └────────────┘
                        │                                     │
                        ▼                                     ▼
                  ┌────────────┐                      ┌─────────────┐
                  │   Models   │                      │ Database    │
                  └────────────┘                      └─────────────┘
```

## Futuras Melhorias Arquiteturais

1. **Camada de Serviço**: Adicionar serviços para separar a lógica de negócios da lógica de UI
2. **Clean Architecture**: Evolução para uma arquitetura mais escalável com casos de uso
3. **Injeção de Dependência**: Utilizar um sistema mais robusto como GetIt ou Riverpod
4. **Gerenciamento de Estado**: Considerar Bloc para estados mais complexos
5. **Testes**: Estrutura para facilitar testes unitários e de integração 