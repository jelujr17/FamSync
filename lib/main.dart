import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/login.dart';
import 'package:famsync/View/Inicio/nexoIncio.dart';
import 'package:famsync/View/Inicio/resumen.dart';
import 'package:famsync/View/Inicio/seleccionPerfil.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  print("Inicializando aplicación...");

  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
  } else {
    FlutterError.onError = (FlutterErrorDetails details) {};
  }

  Intl.defaultLocale = 'es_ES';

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
          print("Esperando la carga inicial...");

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar la aplicación'));
          } else {
            FlutterNativeSplash.remove(); // Oculta el splash después de la carga
            print("Carga finalizada, mostrando página...");
            return snapshot.data!;
          }
        },
      ),
    );
  }

  Future<Widget> getInitialPage() async {
    print("Obteniendo preferencias de usuario...");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('IdUsuario');
    final int? perfilId = prefs.getInt('IdPerfil');
    final bool aux = await NexoInicio().primeraVezResumen();
    
    print("UsuarioId: $userId, PerfilId: $perfilId, primeraVezResumen: $aux");

    if (userId == null) {
      print("No se encontró usuario, redirigiendo a Login...");
      return const LoginScreen();
    } else {
      if (perfilId == null) {
        print("No se encontró perfil, redirigiendo a Selección de Perfil...");
        return SeleccionPerfil(IdUsuario: userId);
      } else {
        final Perfiles? perfil = await ServicioPerfiles().getPerfilById(perfilId);
        if (perfil == null) {
          print("No se encontró perfil, redirigiendo a Login...");
          return const LoginScreen();
        } else {
          if (aux) {
            print("Primera vez, mostrando Resumen...");
            return Resumen(perfil: perfil);
          } else {
            print("No es la primera vez, mostrando Módulos...");
            return Modulos(perfil: perfil);
          }
        }
      }
    }
  }
}
