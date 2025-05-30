import 'package:famsync/View/Inicio/Inicio.dart';
import 'package:famsync/View/Inicio/Seleccion_Perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class Menu_Aux {
  final String title;
  final LottieModel lottie;
  final void Function(BuildContext context) onTap; // Recibe BuildContext

  Menu_Aux({required this.title, required this.lottie, required this.onTap});
}

class LottieModel {
  final String src; // Ruta del archivo .json de Lottie

  LottieModel({required this.src});
}

List<Menu_Aux> sidebarMenus = [
  Menu_Aux(
    title: "Perfil",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Perfil.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Perfil Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Cambiar Perfil",
    lottie: LottieModel(
      src:
          "assets/LottieIcons/Icono_Cambiar_Perfil.json", // Ruta del archivo Lottie
    ),
    onTap: (context) async {
      // Acción para la opción "Cambiar de Perfil"
      print("Cambiar de Perfil seleccionado");
          final user = FirebaseAuth.instance.currentUser;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SeleccionPerfil(UID: user!.uid), // Pasa el ID del usuario
        ),
      );
    },
  ),
  Menu_Aux(
    title: "Cerrar Sesion",
    lottie: LottieModel(
      src:
          "assets/LottieIcons/Icono_Cerrar_Sesion.json", // Ruta del archivo Lottie
    ),
    onTap: (context) async {
      // Acción para la opción "Cerrar Sesión"
      print("Cerrar Sesión seleccionado");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const OnbodingScreen(), // Pasa el ID del usuario
        ),
      );
    },
  ),
];

List<Menu_Aux> sidebarMenus2 = [
  Menu_Aux(
    title: "Preferencias de la Aplicación",
    lottie: LottieModel(
      src:
          "assets/LottieIcons/Icono_Preferencias_Aplicacion.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Gestión de Notificaciones",
    lottie: LottieModel(
      src:
          "assets/LottieIcons/Icono_Gestion_Notificaciones.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Gestión de Credeciales",
    lottie: LottieModel(
      src:
          "assets/LottieIcons/Icono_Gestion_Credenciales.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
];

List<Menu_Aux> sidebarMenus3 = [
  Menu_Aux(
    title: "Asistente",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Asistente.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Guia de Uso",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Guia_Uso.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Soporte",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Soporte.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  )
];

List<Menu_Aux> bottomNavItems = [
  Menu_Aux(
    title: "Modulo_Tareas",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Tareas.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Modulo_Almacen",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Almacen.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Almacen Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Modulo_Calendario",
    lottie: LottieModel(
      src:
          "assets/LottieIcons/Icono_Calendario.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Calendario Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Modulo_Medicina",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Medicina.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Medicina Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Modulo_Tareas",
    lottie: LottieModel(
      src: "assets/LottieIcons/Icono_Tareas.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
];
