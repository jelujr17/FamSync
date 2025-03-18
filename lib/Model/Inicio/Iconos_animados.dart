import 'package:famsync/View/Inicio/Inicio.dart';
import 'package:famsync/View/Inicio/seleccionPerfil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rive_model.dart';
import 'package:flutter/material.dart';

class Menu {
  final String title;
  final RiveModel rive;
  final void Function(BuildContext context) onTap; // Recibe BuildContext

  Menu({required this.title, required this.rive, required this.onTap});
}

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

List<Menu> sidebarMenus = [
  Menu(
    title: "Perfil",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "HOME",
        stateMachineName: "HOME_interactivity"),
    onTap: (context) {
      // Acción para la opción "Perfil"
      print("Perfil seleccionado");
    },
  ),
  Menu(
    title: "Cambiar de Perfil",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "SEARCH",
        stateMachineName: "SEARCH_Interactivity"),
    onTap: (context) async {
      // Acción para la opción "Cambiar de Perfil"
      print("Cambiar de Perfil seleccionado");
      SharedPreferences preferencias = await SharedPreferences.getInstance();

      int? usuario = preferencias.getInt('IdUsuario');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SeleccionPerfil(IdUsuario: usuario!), // Pasa el ID del usuario
        ),
      );
    },
  ),
  Menu(
    title: "Cerrar Sesión",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "LIKE/STAR",
        stateMachineName: "STAR_Interactivity"),
    onTap: (context) async {
      // Acción para la opción "Cerrar Sesión"
      print("Cerrar Sesión seleccionado");
      SharedPreferences preferencias = await SharedPreferences.getInstance();
      preferencias.clear();
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

List<Menu> sidebarMenus2 = [
  Menu(
    title: "Preferencias de la aplicación",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "TIMER",
        stateMachineName: "TIMER_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Preferencias de la aplicación"
      print("Preferencias de la aplicación seleccionado");
    },
  ),
  Menu(
    title: "Gestión de Notificaciones",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Gestión de Notificaciones"
      print("Gestión de Notificaciones seleccionado");
    },
  ),
  Menu(
    title: "Gestión de Credenciales",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Gestión de Credenciales"
      print("Gestión de Credenciales seleccionado");
    },
  ),
];

List<Menu> sidebarMenus3 = [
  Menu(
    title: "Asistente",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "TIMER",
        stateMachineName: "TIMER_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Asistente"
      print("Asistente seleccionado");
    },
  ),
  Menu(
    title: "Guía de Uso",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Guía de Uso"
      print("Guía de Uso seleccionado");
    },
  ),
  Menu(
    title: "Soporte",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Soporte"
      print("Soporte seleccionado");
    },
  ),
  Menu(
    title: "Terminos y Condiciones",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Terminos y Condiciones"
      print("Terminos y Condiciones seleccionado");
    },
  ),
];

List<Menu_Aux> bottomNavItems = [
  Menu_Aux(
    title: "Modulo_Tareas",
    lottie: LottieModel(
      src: "assets/LottieIcons/To_Do.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
  Menu_Aux(
    title: "Modulo_Almacen",
    lottie: LottieModel(
      src: "assets/LottieIcons/Product.json", // Ruta del archivo Lottie
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
      src: "assets/LottieIcons/To_Do.json", // Ruta del archivo Lottie
    ),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Modulo Tareas Seleccionado");
    },
  ),
];
