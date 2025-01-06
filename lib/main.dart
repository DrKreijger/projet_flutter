import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projet_flutter/widgets/bottom_nav_bar.dart';
import 'blocs/calendar_bloc.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/order/order_event.dart';
import 'blocs/driver/driver_bloc.dart';
import 'repositories/order_repository.dart';
import 'repositories/driver_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase a été initialisé avec succès.');
  tz.initializeTimeZones();
  await initializeDateFormatting('fr_BE', null); // Initialiser les formats de date pour la Belgique
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderRepository = OrderRepository(firestore: FirebaseFirestore.instance);
    final driverRepository = DriverRepository(firestore: FirebaseFirestore.instance);

    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(orderRepository)..add(OrderLoad()), // Ajout de l'événement OrderLoad
        ),
        BlocProvider<DriverBloc>(
          create: (context) => DriverBloc(driverRepository: driverRepository)..add(LoadDrivers()), // Ajout de l'événement LoadDrivers
        ),
        BlocProvider<CalendarBloc>(
          create: (_) => CalendarBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr', 'BE'), // Localisation par défaut
        supportedLocales: const [
          Locale('fr', 'BE'), // Français Belgique
          Locale('en', 'US'), // Anglais US (fallback option)
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        themeMode: ThemeMode.system, // Thème basé sur les paramètres du système
        home: BottomNavBar(), // Barre de navigation
      ),
    );
  }
}
