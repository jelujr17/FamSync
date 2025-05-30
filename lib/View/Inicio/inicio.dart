

// Librerías de Flutter
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Paquetes externos/dependencias
import 'package:rive/rive.dart' hide Image;

// Componentes propios de la aplicación (organizados alfabéticamente)
import 'package:famsync/components/colores.dart';
import 'package:famsync/components/Inicio/animated_btn.dart';
import 'package:famsync/components/Inicio/Inciar_Sesion/Iniciar_Sesion_Dialogo.dart';

class OnbodingScreen extends StatefulWidget {
  const OnbodingScreen({super.key});

  @override
  State<OnbodingScreen> createState() => _OnbodingScreenState();
}

class _OnbodingScreenState extends State<OnbodingScreen> {
  late RiveAnimationController _btnAnimationController;
  String version = "";
  bool isShowSignInDialog = false;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );
    // Cargar la versión al iniciar
    obtenerVersionApp();
    super.initState();
  }

  Future<void> obtenerVersionApp() async {
    final info = await PackageInfo.fromPlatform();
    // Actualiza el estado con la versión obtenida
    setState(() {
      version = info.version;
    });
    print('Versión: ${info.version}');
    print('Build: ${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/Backgrounds/Animacion_Fondo_2.gif", // Ruta del archivo GIF
              fit: BoxFit.cover, // Ajusta el GIF para cubrir toda la pantalla
            ),
          ),
        
          AnimatedPositioned(
            top: isShowSignInDialog ? -50 : 0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            duration: const Duration(milliseconds: 260),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          Text(
                            "Organiza y sincroniza tu familia",
                            style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Poppins",
                                height: 1.2,
                                color: Colores.texto),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Simplifica la gestión familiar. Organiza tareas, eventos y productos de manera fácil y rápida con FamSync.",
                            style: TextStyle(color: Colores.texto),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    AnimatedBtn(
                      textoBoton: "Empezar con FamSync",
                      btnAnimationController: _btnAnimationController,
                      press: () {
                        _btnAnimationController.isActive = true;

                        Future.delayed(
                          const Duration(milliseconds: 800),
                          () {
                            setState(() {
                              isShowSignInDialog = true;
                            });
                            if (!context.mounted) return;
                            iniciar_sesion_dialogo(
                              context,
                              onValue: (_) {},
                            );
                          },
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                          "FamSync te ayuda a gestionar eventos, tareas y recursos familiares en un solo lugar. Organiza tu hogar con facilidad y eficiencia.",
                          style: TextStyle(color: Colores.texto)),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("Versión: $version",
                            style: const TextStyle(color: Colores.texto)),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
