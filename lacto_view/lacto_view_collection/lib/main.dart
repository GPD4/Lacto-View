import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/milk_collection/view_models/view_models.dart';
import 'features/milk_collection/views/views.dart';
import 'features/milk_collection/views/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o ChangeNotifierProvider para disponibilizar o ViewModel
    // para a tela MilkCollectionListView e seus descendentes.
    return ChangeNotifierProvider(
      create: (context) => MilkCollectionViewModel(),
      child: MaterialApp(
        title: 'LactoView Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
