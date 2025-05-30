// Paquetes de Flutter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Paquetes externos
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Eventos_Provider.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/Provider/Tienda_Provider.dart';

// Vistas
import 'package:famsync/View/Inicio/Home.dart';
import 'package:famsync/View/Inicio/Inicio.dart';
import 'package:famsync/View/Inicio/Seleccion_Perfil.dart';

// Modelos y Componentes
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const Locale('es', 'ES');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductosProvider()),
        ChangeNotifierProvider(create: (_) => PerfilesProvider()),
        ChangeNotifierProvider(create: (_) => ListasProvider()),
        ChangeNotifierProvider(create: (_) => TareasProvider()),
        ChangeNotifierProvider(create: (_) => CategoriasProvider()),
        ChangeNotifierProvider(create: (_) => TiendasProvider()),
        ChangeNotifierProvider(create: (_) => EventosProvider()),
        // Agrega otros proveedores si es necesario
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FamSync',
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: Colores.fondo, // Fondo principal
        primaryColor: Colores.texto, // Color primario
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colores.texto,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            color: Colores.fondoAux,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colores.texto, // Botones
            foregroundColor: Colores.fondo, // Texto de los botones
          ),
        ),
      ),
      home: FutureBuilder<Widget>(
        future: getInitialPage(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Mostrar un mensaje de error genérico sin detalles
            print('Error en FutureBuilder: ${snapshot.error}');
            return const Center(child: Text('Error al cargar la aplicación'));
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }

  Future<Widget> getInitialPage(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No hay usuario logueado con Firebase
      return const OnbodingScreen();
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? perfilId = prefs.getInt('IdPerfil');

    if (perfilId == null) {
      // No ha seleccionado perfil aún
      return SeleccionPerfil(
          IdUsuario: user.uid.hashCode); // o lo que uses como ID
    } else {
      final Perfiles? perfil = await ServicioPerfiles()
          .getPerfilById(context, perfilId)
          .timeout(const Duration(seconds: 2));

      if (perfil == null) {
        return const OnbodingScreen();
      } else {
        return Home(perfil: perfil);
      }
    }
  }
}
