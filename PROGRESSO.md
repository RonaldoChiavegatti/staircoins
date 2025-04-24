# Progresso de Desenvolvimento - StairCoins

## Estado Atual (Frontend com Dados Mockados)

### Concluído (Frontend)

#### 1. Arquitetura e Configuração
- [x] Setup do projeto Flutter
- [x] Definição da estrutura de pastas
- [x] Configuração do gerenciamento de estado (Provider)
- [x] Configuração de armazenamento local (SharedPreferences)
- [x] Tema e estilos consistentes

#### 2. Modelos de Dados
- [x] User (Professor/Aluno)
- [x] Turma
- [x] Atividade
- [x] Produto

#### 3. Autenticação
- [x] Tela de login
- [x] Tela de registro
- [x] Persistência de sessão
- [x] Rotas protegidas
- [x] Logout

#### 4. Interface do Professor
- [x] Dashboard principal
- [x] Gerenciamento de turmas
- [x] Criação/edição de atividades
- [x] Cadastro de produtos para resgate
- [x] Atribuição de StairCoins

#### 5. Interface do Aluno
- [x] Dashboard com saldo e atividades
- [x] Visualização de turmas
- [x] Lista de atividades disponíveis
- [x] Loja para resgate de produtos
- [x] Histórico de transações

## Próximos Passos (Backend e Integrações)

### Fase 1: Configuração do Backend
- [ ] Escolha da tecnologia de backend (Firebase, Node.js, etc.)
- [ ] Configuração do ambiente de desenvolvimento
- [ ] Criação do esquema de banco de dados
- [ ] Implementação de autenticação real
- [ ] API para CRUD básico dos modelos

### Fase 2: Integração Frontend-Backend
- [ ] Refatoração dos provedores para usar APIs reais
- [ ] Implementação de autenticação via API
- [ ] Upload e armazenamento de imagens (fotos de perfil, produtos, etc.)
- [ ] Tratamento de erros e feedback ao usuário
- [ ] Cache offline e sincronização

### Fase 3: Funcionalidades Avançadas
- [ ] Notificações push
- [ ] Sistema de convites para turmas
- [ ] Exportação de relatórios para professores
- [ ] Gamificação avançada (badges, rankings, etc.)
- [ ] Filtros e pesquisa avançada

### Fase 4: Testes e Otimização
- [ ] Testes unitários
- [ ] Testes de integração
- [ ] Testes de UI
- [ ] Otimização de performance
- [ ] Redução do tamanho do aplicativo

### Fase 5: Lançamento
- [ ] Versão beta fechada
- [ ] Correção de bugs reportados
- [ ] Preparação para lojas de aplicativos
- [ ] Materiais de marketing
- [ ] Lançamento oficial

## Detalhes Técnicos Importantes

### Dados Mockados Atuais
Atualmente, os dados são simulados nas classes Provider:
- **AuthProvider**: Simula autenticação com lista de usuários mockados
- **TurmaProvider**: Simula turmas e operações CRUD
- **AtividadeProvider**: Simula atividades e operações CRUD

### Refatoração Necessária para Backend
Ao implementar o backend, precisaremos refatorar:

1. **Serviços API**: Criar classes de serviço separadas para cada entidade
2. **Provedores**: Modificar para consumir os serviços API
3. **Modelos**: Possivelmente ajustar para corresponder ao esquema do banco
4. **UI**: Adicionar feedback de carregamento e tratamento de erros

### Considerações de Segurança
- Autenticação robusta (Firebase Auth ou JWT)
- Validação de dados no servidor
- Regras de acesso baseadas em papéis
- Proteção contra injeção SQL e outros ataques

## Recursos Atuais vs. Planejados

| Funcionalidade | Estado Atual | Próximos Passos |
|----------------|--------------|-----------------|
| Autenticação | Mockada, funcional na UI | Implementar com Firebase Auth ou similar |
| Turmas | CRUD local | API para gestão, convites, upload de imagens |
| Atividades | CRUD local | API, prazos reais, notificações |
| Produtos | CRUD local | API, imagens, estoque, histórico |
| StairCoins | Transações locais | Registro seguro, histórico, relatórios |
| Notificações | Não implementado | Push para atividades, transações |
| Relatórios | Não implementado | Exportação PDF/CSV, gráficos |

## Alocação de Recursos Recomendada

### Equipe Frontend
- Continuar refinamento da UI/UX
- Preparar para integração com APIs
- Implementar testes

### Equipe Backend
- Desenvolver APIs RESTful
- Implementar autenticação
- Configurar banco de dados
- Criar infraestrutura para upload

### DevOps
- Configurar CI/CD
- Preparar ambientes de staging/produção
- Monitoramento e logs 