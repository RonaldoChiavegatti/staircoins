# StairCoins

## Visão Geral
StairCoins é um aplicativo gamificado para ambiente educacional que permite que professores criem atividades e recompensem alunos com moedas virtuais (StairCoins). Os alunos podem usar essas moedas para resgatar produtos/benefícios cadastrados pelos professores.

## Estado Atual do Desenvolvimento
- **Frontend**: Concluído com dados mockados (simulados)
- **Backend**: Ainda não implementado

## Funcionalidades Implementadas

### Sistema de Autenticação
- Login para professores e alunos
- Registro de novas contas
- Persistência da sessão com SharedPreferences

### Perfil de Professor
- Dashboard com visão geral das turmas
- Criação e gerenciamento de turmas
- Criação e gerenciamento de atividades
- Cadastro de produtos/benefícios para resgate
- Atribuição de StairCoins aos alunos

### Perfil de Aluno
- Dashboard com saldo de StairCoins e atividades pendentes
- Visualização das turmas em que está matriculado
- Lista de atividades disponíveis
- Loja para resgate de produtos/benefícios

## Estrutura do Projeto

### Organização de Pastas
- **lib/models/**: Modelos de dados (User, Turma, Atividade, Produto)
- **lib/providers/**: Gerenciamento de estado com Provider
- **lib/screens/**: Interfaces de usuário separadas por tipo (professor/aluno)
- **lib/widgets/**: Componentes reutilizáveis
- **lib/theme/**: Definição do tema e estilos

### Fluxos Principais
1. **Login/Registro**: Autenticação baseada em email/senha
2. **Professor**: Gerencia turmas > cria atividades > atribui StairCoins > cadastra produtos
3. **Aluno**: Visualiza turmas > completa atividades > recebe StairCoins > resgata produtos

## Tecnologias Utilizadas
- **Framework**: Flutter
- **Gerenciamento de Estado**: Provider
- **Armazenamento Local**: SharedPreferences
- **Dependências**: 
  - provider: ^6.1.1
  - shared_preferences: ^2.2.2
  - uuid: ^4.2.2
  - share_plus: ^7.2.1

## Próximos Passos
1. Implementação do backend (sugestão: Firebase ou outra solução)
2. Integração com autenticação real
3. Armazenamento de dados em nuvem
4. Notificações
5. Testes automatizados
6. Polimento da interface do usuário

## Como Executar o Projeto
```bash
cd staircoins
flutter pub get
flutter run
```

## Dados Mockados
Atualmente, o aplicativo utiliza dados simulados para demonstração:

### Usuários de Teste:
- **Professor**: professor@exemplo.com (senha: 123456)
- **Aluno**: aluno@exemplo.com (senha: 123456)

## Screenshots
[Inserir screenshots do aplicativo aqui]
