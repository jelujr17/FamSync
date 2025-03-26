import 'dart:ui';

import 'package:famsync/components/Inicio/animated_btn.dart';
import 'package:famsync/components/Inicio/Inciar_Sesion/Iniciar_Sesion_Dialogo.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image;

class OnbodingScreen extends StatefulWidget {
  const OnbodingScreen({super.key});

  @override
  State<OnbodingScreen> createState() => _OnbodingScreenState();
}

class _OnbodingScreenState extends State<OnbodingScreen> {
  late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: const SizedBox(),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              "assets/Backgrounds/Animacion_Fondo.gif", // Ruta del archivo GIF
              fit: BoxFit.cover, // Ajusta el GIF para cubrir toda la pantalla
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox(),
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
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                              "Simplifica la gestión familiar. Organiza tareas, eventos y productos de manera fácil y rápida con FamSync."),
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
                            // showCustomDialog(
                            //   context,
                            //   onValue: (_) {
                            //     setState(() {
                            //       isShowSignInDialog = false;
                            //     });
                            //   },
                            // );
                          },
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        "FamSync te ayuda a gestionar eventos, tareas y recursos familiares en un solo lugar. Organiza tu hogar con facilidad y eficiencia.",
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
