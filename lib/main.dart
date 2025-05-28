import 'package:famsync/Error_Conexion.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Eventos_Provider.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/Provider/Tienda_Provider.dart';
import 'package:famsync/View/Inicio/Home.dart';
import 'package:famsync/View/Inicio/Inicio.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/Seleccion_Perfil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_ES';
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(
  );
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
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('IdUsuario');
      final int? perfilId = prefs.getInt('IdPerfil');

      // Comentado el redireccionamiento al login
      if (userId == null) {
        return const OnbodingScreen();
      } else {
        if (perfilId == null) {
          return SeleccionPerfil(IdUsuario: userId);
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
    } catch (e) {
      return const NoconnectionScreen();
    }
  }
}
