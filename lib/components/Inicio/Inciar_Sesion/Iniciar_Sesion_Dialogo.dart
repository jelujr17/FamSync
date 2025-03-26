import 'package:famsync/components/Inicio/Crear_Cuenta/Crear_Cuenta_Dialogo.dart';
import 'package:famsync/components/Inicio/animated_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:famsync/components/colores.dart';
import 'package:rive/rive.dart';

import 'Iniciar_sesion_Formulario.dart';

void iniciar_sesion_dialogo(BuildContext context,
    {required ValueChanged onValue}) {
  // Inicializar el controlador de animación fuera del diálogo
  final RiveAnimationController btnAnimationController = OneShotAnimation(
    "active",
    autoplay: false,
  );

  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colores.grisOscuro.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Container(
          height: 770, // Aumenté la altura para dar más espacio al botón
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colores.grisOscuro.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colores.amarillo.withOpacity(0.3),
                offset: const Offset(0, 30),
                blurRadius: 60,
              ),
              const BoxShadow(
                color: Colores.amarillo,
                offset: Offset(0, 30),
                blurRadius: 60,
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          color: Colores.amarillo,
                          fontSize: 34,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Administra fácilmente tu hogar con FamSync. Organiza eventos, tareas y productos en un solo lugar para una mejor sincronización familiar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colores.amarillo,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SignInForm(),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "O",
                              style: TextStyle(
                                color: Colores.amarillo,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          "Inicia sesión con Facebook, Apple o Google",
                          style: TextStyle(color: Colores.amarillo),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            icon: SvgPicture.asset(
                              "assets/icons/email_box.svg",
                              height: 64,
                              width: 64,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            icon: SvgPicture.asset(
                              "assets/icons/apple_box.svg",
                              height: 64,
                              width: 64,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            icon: SvgPicture.asset(
                              "assets/icons/google_box.svg",
                              height: 64,
                              width: 64,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "¿No tienes una cuenta?",
                        style: TextStyle(color: Colores.amarillo),
                      ),
                      const SizedBox(
                          height:
                              170), // Incrementamos el espacio para dar cabida a los botones más abajo
                    ],
                  ),
                ),
                // Botón "Iniciar Sesión" (otro botón principal si quieres añadirlo)

                // Botón "Crear Cuenta"
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20, // Posicionado más abajo
                  child: AnimatedBtn(
                    textoBoton: "Crear Cuenta",
                    btnAnimationController: btnAnimationController,
                    press: () {
                      btnAnimationController.isActive = true;
                      print("Botón presionado");
                      Future.delayed(
                        const Duration(milliseconds: 800),
                        () {
                          Navigator.of(context).pop(); // Cerrar el diálogo
                          crear_cuenta_dialogo(
                            context,
                            onValue: (_) {},
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
      return SlideTransition(
        position: tween.animate(
          CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
  ).then(onValue);
}
