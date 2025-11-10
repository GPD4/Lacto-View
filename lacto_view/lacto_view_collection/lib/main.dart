import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports do Módulo Collection (Existentes) ---
import 'features/milk_collection/view_models/view_models_collection.dart';
import 'features/milk_collection/views/main_screen.dart';
import 'firebase_options.dart';

// --- Imports do Módulo Person (NOVOS) ---
// (Ajuste os caminhos se você os colocou em outra pasta)
import 'features/profile/service/service_person.dart';
import 'features/profile/view_model/view_models_person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Substitua o 'ChangeNotifierProvider' por 'MultiProvider'
    return MultiProvider(
      providers: [
        // --- Seu Provider Existente (Coleta de Leite) ---
        ChangeNotifierProvider(create: (context) => MilkCollectionViewModel()),

        // --- Novos Providers para Cadastro de Pessoa ---

        // 2. Prover o PersonService
        Provider<PersonService>(create: (_) => PersonService()),

        // 3. Prover o PersonViewModel (que usa o PersonService)
        ChangeNotifierProvider<PersonViewModel>(
          create: (context) => PersonViewModel(
            // Pega o PersonService que acabamos de prover acima
            context.read<PersonService>(),
          ),
        ),

        // (Você pode adicionar mais providers para outros módulos aqui no futuro)
      ],

      // 4. O 'child' do MultiProvider é o seu MaterialApp
      child: MaterialApp(
        title: 'LactoView Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(), // MainScreen agora tem acesso a tudo
      ),
    );
  }
}
