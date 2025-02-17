import 'dart:developer';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Ajustes/ajustes.dart';
import 'package:famsync/View/Inicio/resumen.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final Perfiles perfil;
  final int pagina;
  final PageController pageController;

  const CustomBottomNavBar({
    super.key,
    required this.perfil,
    required this.pagina,
    required this.pageController,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final NotchBottomBarController controller = NotchBottomBarController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
      Modulos(perfil: widget.perfil),  // Asegúrate de usar la página correspondiente
      Resumen(perfil: widget.perfil),
      Ajustes(perfil: widget.perfil),
    ];

    // Calculando el ancho dinámico de la barra de navegación
    double screenWidth = MediaQuery.of(context).size.width;
    double bottomBarWidth = screenWidth * 0.8; // Usar el 80% del ancho de la pantalla

    return Align(
      alignment: Alignment.bottomCenter, // Alineamos al centro inferior
      child: AnimatedNotchBottomBar(
        notchBottomBarController: controller,
        color: Colores.texto,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Colores.botones,
        removeMargins: false,
        bottomBarWidth: bottomBarWidth, // Asignamos el ancho calculado
        showShadow: false,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(fontSize: 10),
        elevation: 1,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.home_filled, color: Colores.fondoAux),
            activeItem: Icon(Icons.home_filled, color: Colores.fondo),
            itemLabel: 'Módulos',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.data_usage, color: Colores.fondoAux),
            activeItem: Icon(Icons.data_usage, color: Colores.fondo),
            itemLabel: 'Asistente',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.settings, color: Colores.fondoAux),
            activeItem: Icon(Icons.settings, color: Colores.fondo),
            itemLabel: 'Ajustes',
          ),
        ],
        onTap: (index) {
          log('current selected index $index');
          widget.pageController.jumpToPage(index);  // Usamos el controlador para cambiar la página
        },
        kIconSize: 24.0,
      ),
    );
  }
}
