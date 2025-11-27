# Tela de Login - LactoView

## 📋 O que foi implementado

### Estrutura criada

```
lib/features/auth/
├── model/
│   └── user_model.dart          # Modelo de dados do usuário autenticado
├── service/
│   └── auth_service.dart        # Serviço de autenticação com Firebase
├── view_model/
│   └── auth_view_model.dart     # Gerenciamento de estado de autenticação
└── view/
    └── login_view.dart          # Tela de login
```

## 🎯 Funcionalidades

### 1. **Tela de Login**
- ✅ Login com email e senha usando Firebase Authentication
- ✅ Validação de campos (email válido, senha mínima de 6 caracteres)
- ✅ Botão de "Esqueci minha senha" (envia email de recuperação)
- ✅ Loading state durante autenticação
- ✅ Exibição de erros de forma amigável
- ✅ Design consistente com o padrão do app (verde escuro)
- ✅ Ícone de mostrar/ocultar senha

### 2. **Gerenciamento de Sessão**
- ✅ Verificação automática de usuário logado ao iniciar o app
- ✅ Cache local usando SharedPreferences
- ✅ Redirecionamento automático:
  - Se logado → MainScreen (tela principal)
  - Se não logado → LoginView (tela de login)

### 3. **Logout**
- ✅ Botão de logout na tela de Perfil
- ✅ Limpa sessão do Firebase e cache local
- ✅ Redireciona para tela de login

## 🔧 Dependências Adicionadas

```yaml
firebase_auth: ^6.1.1          # Autenticação Firebase
shared_preferences: ^2.3.3     # Cache local de dados
```

## 📱 Fluxo de Navegação

```
App Inicia
    ↓
AuthViewModel.initialize()
    ↓
    ├─ Usuário logado? → MainScreen (Home)
    └─ Não logado? → LoginView
                         ↓
                   Login bem-sucedido → MainScreen
                         ↓
                   Botão "Sair" no Perfil → LoginView
```

## 🔐 Como funciona a Autenticação

### Firebase Authentication
O app utiliza **Firebase Authentication** para validar credenciais:

1. Usuário digita email e senha
2. Firebase valida as credenciais
3. Se válido, retorna um token JWT
4. Token é salvo localmente (SharedPreferences)
5. Usuário é redirecionado para MainScreen

### Cache Local
- Dados do usuário são salvos localmente para evitar login a cada abertura
- Ao reabrir o app, verifica se existe sessão válida no Firebase
- Se válida, restaura os dados do cache

## 🚀 Próximos Passos (Opcional)

Para integrar com o backend Dart Frog:

1. **Criar endpoint de login no backend** (`POST /auth/login`)
   - Recebe email e senha
   - Valida no Firestore (tabela `user`)
   - Retorna token JWT e dados do usuário (name, role, etc.)

2. **Atualizar AuthService.login()**
   - Após autenticar no Firebase, chamar o backend
   - Buscar dados completos do usuário (role, name, etc.)
   - Salvar no UserAuth model

3. **Implementar controle de acesso por role**
   - Admin: acesso total
   - Coletor: apenas coleta
   - Produtor: visualização limitada

## 🧪 Como Testar

### 1. Criar usuário no Firebase Console
- Acesse o [Firebase Console](https://console.firebase.google.com/)
- Vá em Authentication → Users
- Adicione um usuário com email e senha

### 2. Testar o Login
```dart
Email: teste@lactoview.com
Senha: senha123
```

### 3. Verificar funcionalidades
- ✅ Login com credenciais válidas
- ✅ Erro com credenciais inválidas
- ✅ Recuperação de senha (email enviado)
- ✅ Permanecer logado ao fechar/reabrir app
- ✅ Logout funcionando

## 📝 Observações

- **Senhas são criptografadas**: O Firebase não permite ver senhas em texto puro
- **Token JWT**: Gerado automaticamente pelo Firebase
- **Compatibilidade**: Funciona em Android, iOS e Web
- **Offline**: Não funciona sem internet (Firebase Auth requer conexão)

## 🎨 Design

A tela segue o padrão visual do app:
- Cor principal: Verde escuro (`Colors.green[800]`)
- Ícone: Gota d'água (representa leite)
- Botões arredondados
- Feedback visual de loading e erros
