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

## Inicialização do Firebase com Dados de Teste

Para facilitar os testes e o desenvolvimento, o StairCoins oferece duas maneiras de inicializar o Firebase com dados de teste:

### Opção 1: Botão na Tela de Login

Na tela de login, há um botão na parte inferior chamado "Inicializar Firebase com dados de teste". Ao clicar neste botão, o sistema irá:

1. Criar usuários de teste:
   - Professor: professor@teste.com (senha: senha123)
   - Alunos: aluno1@teste.com, aluno2@teste.com, aluno3@teste.com (senha: senha123 para todos)

2. Criar turmas de teste com códigos:
   - Matemática - 9º Ano (MAT9A)
   - Ciências - 8º Ano (CIE8B)
   - História - 7º Ano (HIS7C)

3. Criar diversas atividades para cada turma

4. Criar produtos para resgate com StairCoins

### Opção 2: Executando o Script Diretamente

Para inicializar o Firebase via linha de comando:

```bash
flutter run lib/scripts/run_seed.dart
```

Este script executa a mesma inicialização que o botão na interface, mas pode ser útil para ambientes de desenvolvimento ou CI/CD.

### Dados Criados

A inicialização cria os seguintes dados:

#### Usuários
- Professor: professor@teste.com (senha: senha123)
- Aluno 1: aluno1@teste.com (senha: senha123)
- Aluno 2: aluno2@teste.com (senha: senha123)
- Aluno 3: aluno3@teste.com (senha: senha123)

#### Turmas
- Matemática - 9º Ano (código: MAT9A)
- Ciências - 8º Ano (código: CIE8B)
- História - 7º Ano (código: HIS7C)

#### Atividades
Diversas atividades distribuídas entre as turmas, com diferentes pontuações e datas de entrega.

#### Produtos
Vários produtos disponíveis para resgate com diferentes valores em StairCoins.

**Nota**: A inicialização verifica a existência prévia dos dados para evitar duplicações. É seguro executar o script múltiplas vezes.
