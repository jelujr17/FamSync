import 'package:famsync/View/Inicio/inicio.dart';
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

List<Menu> bottomNavItems = [
  Menu(
    title: "Chat",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "CHAT",
        stateMachineName: "CHAT_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Chat"
      print("Chat seleccionado");
    },
  ),
  Menu(
    title: "Search",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "SEARCH",
        stateMachineName: "SEARCH_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Search"
      print("Search seleccionado");
    },
  ),
  Menu(
    title: "Timer",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "TIMER",
        stateMachineName: "TIMER_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Timer"
      print("Timer seleccionado");
    },
  ),
  Menu(
    title: "Notification",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Notification"
      print("Notification seleccionado");
    },
  ),
  Menu(
    title: "Profile",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "USER",
        stateMachineName: "USER_Interactivity"),
    onTap: (context) {
      // Acción para la opción "Profile"
      print("Profile seleccionado");
    },
  ),
];
