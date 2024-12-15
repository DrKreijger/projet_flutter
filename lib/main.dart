import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projet_flutter/widgets/bottom_nav_bar.dart';
import 'blocs/order_bloc.dart';
import 'blocs/driver_bloc.dart';
import 'blocs/order_event.dart';
import 'repositories/order_repository.dart';
import 'repositories/driver_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase a été initialisé avec succès.');
  tz.initializeTimeZones();
  await initializeDateFormatting('fr_BE', null); // Initialiser les formats de date pour la Belgique
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderRepository = OrderRepository(firestore: FirebaseFirestore.instance);
    final driverRepository = DriverRepository(firestore: FirebaseFirestore.instance);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OrderBloc(orderRepository)..add(LoadOrders()), // Charger les commandes au démarrage
        ),
        BlocProvider(
          create: (_) => DriverBloc(driverRepository: driverRepository)..add(LoadDrivers()), // Charger les chauffeurs au démarrage
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr', 'BE'), // Définir la localisation par défaut
        supportedLocales: const [
          Locale('fr', 'BE'), // Français Belgique
          Locale('en', 'US'), // Anglais
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: BottomNavBar(),
      ),
    );
  }
}
