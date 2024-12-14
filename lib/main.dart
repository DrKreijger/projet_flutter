import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projet_flutter/widgets/bottom_nav_bar.dart';
import 'blocs/order_bloc.dart';
import 'blocs/driver_bloc.dart';
import 'repositories/order_repository.dart';
import 'repositories/driver_repository.dart';
import 'screens/orders_screen.dart';
import 'screens/drivers_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase a été initialisé avec succès.');
  tz.initializeTimeZones();
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
          create: (_) => OrderBloc(orderRepository),
        ),
        BlocProvider(
          create: (_) => DriverBloc(driverRepository: driverRepository)..add(LoadDrivers()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: BottomNavBar(),
      ),
    );
  }
}
