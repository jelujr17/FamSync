import 'package:famsync/Components/Inicio/AuthService.dart';
import 'package:famsync/components/Inicio/Inciar_Sesion/Iniciar_Sesion_Dialogo.dart';
import 'package:famsync/components/Inicio/animated_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:famsync/components/colores.dart';
import 'package:rive/rive.dart';

import 'Crear_Cuenta_Formulario.dart';

void crear_cuenta_dialogo(BuildContext context,
    {required ValueChanged onValue}) {
  final RiveAnimationController btnAnimationController = OneShotAnimation(
    "active",
    autoplay: false,
  );

  // Obtener el tamaño de la pantalla
  final size = MediaQuery.of(context).size;
  final maxHeight = size.height * 0.85; // 85% de la altura de la pantalla

  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colores.fondo.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight, // Establecer altura máxima
            maxWidth: size.width * 0.9, // 90% del ancho de la pantalla
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colores.fondo.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colores.texto.withOpacity(0.3),
                offset: const Offset(0, 30),
                blurRadius: 60,
              ),
              const BoxShadow(
                color: Colores.texto,
                offset: Offset(0, 30),
                blurRadius: 60,
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset:
                true, // Importante para ajustar cuando aparece el teclado
            body: Column(
              children: [
                // Encabezado - Fijo en la parte superior
                Column(
                  children: [
                    const Text(
                      "Crear Cuenta",
                      style: TextStyle(
                        fontSize: 34,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        color: Colores.texto,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Administra fácilmente tu hogar con FamSync. Organiza eventos, tareas y productos en un solo lugar para una mejor sincronización familiar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colores.texto,
                        ),
                      ),
                    ),
                  ],
                ),

                // Contenido deslizable - Ocupa el espacio disponible
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const Crear_Cuenta_Formulario(),
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
                                  color: Colores.texto,
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
                            "Regístrate con tus redes sociales",
                            style: TextStyle(color: Colores.texto),
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
                              onPressed: () async {
                                try {
                                  // Mostrar indicador de carga
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Center(
                                          child: CircularProgressIndicator(
                                              color: Colores.fondoAux));
                                    },
                                  );

                                  final userInfo =
                                      await AuthService.signInWithGoogle();

                                  // Cerrar indicador de carga
                                  Navigator.of(context).pop();

                                  if (userInfo != null) {
                                    // Usuario autenticado correctamente
                                    final isNewUser =
                                        userInfo.additionalUserInfo?.isNewUser ?? false;
                                    final name =
                                        userInfo.user?.displayName ?? 'Usuario';
                                    final email = userInfo.user?.email ?? '';

                                    // Puedes guardar datos adicionales del usuario si es nuevo
                                    if (isNewUser) {
                                      print(
                                          "Nuevo usuario registrado: $name ($email)");
                                    } else {
                                      print(
                                          "Usuario existente inició sesión: $name ($email)");
                                    }

                                    // Cerrar diálogo de registro
                                    Navigator.of(context).pop();

                                    // Informar al padre que se ha iniciado sesión correctamente
                                    onValue(true);

                                    // Mostrar mensaje de bienvenida
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('¡Bienvenido $name!')),
                                    );
                                  }
                                } catch (e) {
                                  // Cerrar indicador de carga si está visible
                                  if (Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  }

                                  // Personalizar mensaje de error
                                  String errorMessage =
                                      'No se pudo iniciar sesión con Google';
                                  if (e.toString().contains('network_error')) {
                                    errorMessage =
                                        'Error de conexión. Verifica tu internet y vuelve a intentar.';
                                  } else if (e
                                      .toString()
                                      .contains('sign_in_failed')) {
                                    errorMessage =
                                        'Error de inicio de sesión. Inténtalo nuevamente.';
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  );
                                  print("Error detallado: $e");
                                }
                              },
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
                        const Text(
                          "¿Ya tienes una cuenta?",
                          style: TextStyle(color: Colores.texto),
                        ),
                        // Espacio para asegurar que todo el contenido sea accesible
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // Botón fijo en la parte inferior
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: AnimatedBtn(
                    textoBoton: "Iniciar Sesión",
                    btnAnimationController: btnAnimationController,
                    press: () {
                      btnAnimationController.isActive = true;
                      print("Botón presionado");
                      Future.delayed(
                        const Duration(milliseconds: 800),
                        () {
                          Navigator.of(context).pop(); // Cerrar el diálogo
                          iniciar_sesion_dialogo(
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
