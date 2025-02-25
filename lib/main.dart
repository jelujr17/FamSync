import 'package:famsync/View/Inicio/home.dart';
import 'package:famsync/View/Inicio/inicio.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/nexoIncio.dart';
import 'package:famsync/View/Inicio/seleccionPerfil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_ES';
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
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
            // Mostrar el error específico
            return Center(child: Text('Error al cargar la aplicación: ${snapshot.error}'));
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
      final bool aux = await NexoInicio().primeraVezResumen();

      // Comentado el redireccionamiento al login
      if (userId == null) {
        return const OnbodingScreen();
      } else {
        if (perfilId == null) {
          return SeleccionPerfil(IdUsuario: userId);
        } else {
          final Perfiles? perfil = await ServicioPerfiles().getPerfilById(perfilId);
          if (perfil == null) {
            return const OnbodingScreen();
          } else {
            
              return Home(perfil: perfil);
            
          }
        }
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la ejecución del Future
      print('Error en getInitialPage: $e');
      throw e;
    }
  }
}