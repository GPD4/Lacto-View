import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/milk_collection/view_models/view_models_collection.dart';
import 'features/milk_collection/views/main_screen.dart';
import 'firebase_options.dart';

import 'features/profile/service/service_person.dart';
import 'features/profile/service/service_property_search.dart';
import 'features/profile/view_model/view_models_person.dart';
import 'features/profile/view_model/view_model_property.dart';
import 'features/profile/view_model/search_property_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MilkCollectionViewModel()),

        Provider<PersonService>(create: (_) => PersonService()),
        Provider<ServicePropertySearch>(create: (_) => ServicePropertySearch()),

        ChangeNotifierProvider<PersonViewModel>(
          create: (context) => PersonViewModel(context.read<PersonService>()),
        ),
        ChangeNotifierProvider<PropertyViewModel>(
          create: (context) =>
              PropertyViewModel(context.read<ServicePropertySearch>()),
        ),
        ChangeNotifierProvider<SearchPropertyViewModel>(
          create: (context) =>
              SearchPropertyViewModel(context.read<ServicePropertySearch>()),
        ),
      ],

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
