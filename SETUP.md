# Setup do Projeto StairCoins

Este guia contém as instruções para configurar o ambiente de desenvolvimento do StairCoins, incluindo a integração com o Firebase.

## Pré-requisitos

- Flutter SDK (versão 3.10.0 ou superior)
- Dart SDK (versão 3.0.0 ou superior)
- Android Studio / VS Code
- Git
- Conta no Firebase

## 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/staircoins.git
cd staircoins
```

## 2. Instale as Dependências

```bash
flutter pub get
```

## 3. Configuração do Firebase

### 3.1. Crie um Projeto no Firebase

1. Acesse o [Console do Firebase](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Dê um nome ao projeto (ex: "StairCoins")
4. Siga as instruções para criar o projeto

### 3.2. Configure o Firebase para Flutter

#### Configuração Manual (Recomendada)

1. **Para Android**:
   - No console do Firebase, clique no ícone do Android para adicionar um app
   - Registre o app com o pacote `com.example.staircoins` (ou seu pacote personalizado)
   - Baixe o arquivo `google-services.json`
   - Coloque o arquivo na pasta `android/app/`
   - Edite o arquivo `android/build.gradle` para adicionar o plugin do Google Services:
     ```gradle
     buildscript {
         dependencies {
             // ... outras dependências
             classpath 'com.google.gms:google-services:4.3.15'
         }
     }
     ```
   - Edite o arquivo `android/app/build.gradle` para aplicar o plugin:
     ```gradle
     apply plugin: 'com.android.application'
     apply plugin: 'kotlin-android'
     apply plugin: 'com.google.gms.google-services'  // Adicione esta linha
     ```

2. **Para iOS**:
   - No console do Firebase, clique no ícone do iOS para adicionar um app
   - Registre o app com o Bundle ID `com.example.staircoins` (ou seu ID personalizado)
   - Baixe o arquivo `GoogleService-Info.plist`
   - Abra o projeto no Xcode e adicione o arquivo ao diretório Runner (clique direito em Runner > Add Files to "Runner")
   - Certifique-se de selecionar "Copy items if needed"

3. **Para Web**:
   - No console do Firebase, clique no ícone da Web para adicionar um app
   - Registre o app com um nome (ex: "staircoins-web")
   - Copie o snippet de configuração do Firebase

4. **Crie o arquivo `lib/firebase_options.dart`**:
   - Crie manualmente o arquivo com base no template fornecido anteriormente
   - Substitua os valores placeholder pelos valores reais do seu projeto Firebase
   - Exemplo:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não está disponível para esta plataforma.',
        );
    }
  }

  // Substitua estes valores pelos valores reais do seu projeto Firebase
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SEU_API_KEY',
    appId: 'SEU_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    authDomain: 'SEU_AUTH_DOMAIN',
    storageBucket: 'SEU_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SEU_API_KEY',
    appId: 'SEU_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SEU_API_KEY',
    appId: 'SEU_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_STORAGE_BUCKET',
    iosClientId: 'SEU_IOS_CLIENT_ID',
    iosBundleId: 'SEU_IOS_BUNDLE_ID',
  );
}
```

### 3.3. Habilite os Serviços Necessários

No console do Firebase, ative:

1. **Authentication**
   - Habilite o método de autenticação "E-mail/senha"

2. **Cloud Firestore**
   - Crie um banco de dados no modo de produção
   - Configure as regras de segurança conforme necessário

3. **Firebase Storage** (opcional)
   - Configure se precisar armazenar arquivos

## 4. Regras de Segurança do Firestore

Copie estas regras para o console do Firebase > Firestore > Regras:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Verifica se o usuário está autenticado
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Verifica se o usuário é o proprietário do documento
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Verifica se o usuário é professor
    function isProfessor() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.tipo == 'professor';
    }
    
    // Regras para usuários
    match /users/{userId} {
      allow read: if isAuthenticated() && (isOwner(userId) || isProfessor());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && isOwner(userId);
      allow delete: if false; // Não permitir exclusão de usuários
    }
    
    // Regras para turmas
    match /turmas/{turmaId} {
      // Professores podem criar e atualizar suas próprias turmas
      allow create: if isAuthenticated() && isProfessor();
      allow update: if isAuthenticated() && 
                     (isProfessor() && resource.data.professorId == request.auth.uid);
      
      // Professores podem ver todas as turmas, alunos só veem as turmas em que estão
      allow read: if isAuthenticated() && 
                   (isProfessor() || resource.data.alunos.hasAny([request.auth.uid]));
      
      allow delete: if isAuthenticated() && 
                     isProfessor() && resource.data.professorId == request.auth.uid;
    }
    
    // Regras para atividades
    match /atividades/{atividadeId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isProfessor();
    }
    
    // Regras para produtos
    match /produtos/{produtoId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isProfessor();
    }
  }
}
```

## 5. Estrutura do Banco de Dados

### Collection: users
```
{
  "id": "user_id",
  "name": "Nome do Usuário",
  "email": "email@exemplo.com",
  "tipo": "professor" | "aluno",
  "staircoins": 100, // apenas para alunos
  "turmas": ["turma_id_1", "turma_id_2"],
  "createdAt": timestamp
}
```

### Collection: turmas
```
{
  "id": "turma_id",
  "nome": "Nome da Turma",
  "descricao": "Descrição da turma",
  "codigo": "CODIGO",
  "professorId": "professor_id",
  "alunos": ["aluno_id_1", "aluno_id_2"],
  "atividades": ["atividade_id_1", "atividade_id_2"],
  "createdAt": timestamp
}
```

### Collection: atividades
```
{
  "id": "atividade_id",
  "titulo": "Título da Atividade",
  "descricao": "Descrição da atividade",
  "turmaId": "turma_id",
  "pontuacao": 50,
  "dataEntrega": timestamp,
  "status": "ativa" | "encerrada",
  "createdAt": timestamp
}
```

### Collection: produtos
```
{
  "id": "produto_id",
  "nome": "Nome do Produto",
  "descricao": "Descrição do produto",
  "preco": 100,
  "disponivel": true,
  "professorId": "professor_id",
  "createdAt": timestamp
}
```

## 6. Executando o Projeto

```bash
flutter run
```

## 7. Solução de Problemas

### Erro de Compilação com Firebase
Se encontrar erros relacionados ao Firebase durante a compilação:

```bash
flutter clean
flutter pub get
flutter run
```

### Problemas com Permissões
Verifique se as regras de segurança do Firestore estão configuradas corretamente.

### Problemas de Autenticação
Certifique-se de que o método de autenticação por e-mail/senha está habilitado no console do Firebase.

### Erro com google-services.json
Verifique se o arquivo `google-services.json` está no diretório correto (`android/app/`) e se o pacote no arquivo corresponde ao pacote do seu aplicativo.

## 8. Recursos Adicionais

- [Documentação do Flutter](https://flutter.dev/docs)
- [Documentação do Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [Configuração manual do Firebase no Flutter](https://firebase.google.com/docs/flutter/setup?platform=android#manual-setup)
- [Provider Package](https://pub.dev/packages/provider)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth) 