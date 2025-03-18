import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/View/Inicio/Home.dart';
import 'package:famsync/View/Inicio/Inicio.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/seleccionPerfil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_ES';
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductosProvider()),
        ChangeNotifierProvider(create: (_) => PerfilesProvider()),
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
      home: FutureBuilder<Widget>(
        future: getInitialPage(),
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

  Future<Widget> getInitialPage() async {
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
          final Perfiles? perfil =
              await ServicioPerfiles().getPerfilById(perfilId);
          if (perfil == null) {
            return const OnbodingScreen();
          } else {
            return Home(perfil: perfil);
          }
        }
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la ejecución del Future
      print('Error en getInitialPage: $e'); // Imprimir el error en la consola
      rethrow; // Sigue lanzando el error para que el FutureBuilder lo maneje
    }
  }
}
