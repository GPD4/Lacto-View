import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode

import 'features/milk_collection/view_models/view_models_collection.dart';
import 'features/milk_collection/views/main_screen.dart';
import 'firebase_options.dart';

import 'features/profile/service/service_person.dart';
import 'features/profile/service/service_property_search.dart';
import 'features/profile/service/service_property.dart';
import 'features/profile/view_model/view_models_person.dart';
import 'features/profile/view_model/view_model_property.dart';
import 'features/profile/view_model/search_property_view_model.dart';

import 'features/auth/service/auth_service.dart';
import 'features/auth/service/i_auth_service.dart';
import 'features/auth/view_model/auth_view_model.dart';
import 'features/auth/view/login_view.dart';

// MODO DE DESENVOLVIMENTO: true = usa dados mockados, false = usa Firebase
// IMPORTANTE: Devido ao problema de reCAPTCHA em emuladores, use true para desenvolvimento
const bool USE_MOCK_AUTH = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Conecta ao Firebase Auth Emulator se estiver em modo debug
  // Para usar Firebase real, você precisa:
  // 1. Configurar Firebase App Check no console
  // 2. Ou criar os usuários manualmente no Firebase Console
  // 3. Ou usar dispositivo físico ao invés de emulador

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth providers
        Provider<IAuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<IAuthService>()),
        ),

        // Outros providers
        ChangeNotifierProvider(create: (context) => MilkCollectionViewModel()),

        Provider<PersonService>(create: (_) => PersonService()),

        Provider<ServicePropertySearch>(create: (_) => ServicePropertySearch()),

        Provider<PropertyService>(create: (_) => PropertyService()),

        ChangeNotifierProvider<PersonViewModel>(
          create: (context) => PersonViewModel(context.read<PersonService>()),
        ),

        ChangeNotifierProvider<PropertyViewModel>(
          create: (context) => PropertyViewModel(
            context.read<PropertyService>(), // <--- Aqui injeta o de CRIAÇÃO
          ),
        ),

        ChangeNotifierProvider<SearchPropertyViewModel>(
          create: (context) => SearchPropertyViewModel(
            context
                .read<ServicePropertySearch>(), // <--- Aqui injeta o de BUSCA
          ),
        ),
      ],

      child: MaterialApp(
        title: 'LactoView Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        routes: {
          '/main': (context) => const MainScreen(),
          '/login': (context) => const LoginView(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializa o AuthViewModel após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        if (authViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return authViewModel.isAuthenticated
            ? const MainScreen()
            : const LoginView();
      },
    );
  }
}
