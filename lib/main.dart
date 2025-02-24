import 'package:famsync/View/Inicio/inicio.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/nexoIncio.dart';
import 'package:famsync/View/Inicio/resumen.dart';
import 'package:famsync/View/Inicio/seleccionPerfil.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar la aplicación'));
          } else {
            return snapshot.data!;
          }
        },
      ),
      // Comentado el AnimatedSplashScreen
      // home: AnimatedSplashScreen(
      //   splash: Image.asset(
      //     'assets/images/splash.png',
      //     fit: BoxFit.cover, // Asegura que la imagen ocupe toda la pantalla
      //   ),
      //   nextScreen: FutureBuilder<Widget>(
      //     future: getInitialPage(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return const Center(child: CircularProgressIndicator());
      //       } else if (snapshot.hasError) {
      //         return const Center(child: Text('Error al cargar la aplicación'));
      //       } else {
      //         return snapshot.data!;
      //       }
      //     },
      //   ),
      //   splashIconSize: double.infinity, // Hace que el icono ocupe todo el espacio disponible
      //   duration: 1000,
      //   splashTransition: SplashTransition.fadeTransition,
      //   backgroundColor: Colores.botonesSecundarios,
      // ),
    );
  }

  Future<Widget> getInitialPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('IdUsuario');
    final int? perfilId = prefs.getInt('IdPerfil');
    final bool aux = await NexoInicio().primeraVezResumen();

    // Comentado el redireccionamiento al login
     if (userId != null) {
       return const OnbodingScreen();
     } else {
    if (perfilId == null) {
      return SeleccionPerfil(IdUsuario: userId!);
    } else {
      final Perfiles? perfil = await ServicioPerfiles().getPerfilById(perfilId);
      if (perfil == null) {
        return const OnbodingScreen();
      } else {
        if (aux) {
          return Resumen(perfil: perfil);
        } else {
          return Modulos(perfil: perfil);
        }
      }
    }
     }
  }
}
