import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Ajustes/ajustes.dart';
import 'package:famsync/View/Asistente%20Virtual/chatVS.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:famsync/components/colores.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Perfiles perfil;
  final int paginaActual;

  const CustomBottomNavBar({
    super.key,
    required this.perfil,
    required this.paginaActual,
  });

  void _cambiarPagina(BuildContext context, int index) {
    if (index == paginaActual) return; // Evita recargar la misma página

    Widget paginaDestino;
    switch (index) {
      case 0:
        paginaDestino = Modulos(perfil: perfil);
        break;
      case 1:
        paginaDestino = VirtualAssistantPage(perfil: perfil);
        break;
      case 2:
        paginaDestino = Ajustes(perfil: perfil);
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => paginaDestino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colores.botonesSecundarios,
        borderRadius: BorderRadius.circular(30), // Más curvatura
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4), // Sombra hacia abajo
          ),
        ],
      ),
      child: GNav(
        selectedIndex: paginaActual,
        onTabChange: (index) => _cambiarPagina(context, index),
        gap: 10,
        backgroundColor: Colors.transparent,
        activeColor: Colores.fondo, // Color del icono activo
        color: Colores.fondoAux, // Color del icono inactivo
        iconSize: 26, // Iconos más grandes
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        curve: Curves.easeInOut, // Transición más suave
        tabs: const [
          GButton(
            icon: Icons.home_filled,
            text: 'Módulos', iconColor: Colores.fondoAux,
            iconActiveColor: Colores.texto,
            backgroundColor: Colores.fondoAux, // Fondo del botón seleccionado
            textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colores.texto),
          ),
          GButton(
            icon: Icons.data_usage,
            text: 'Asistente', iconColor: Colores.fondoAux,
            iconActiveColor: Colores.texto,
            backgroundColor: Colores.fondoAux, // Fondo del botón seleccionado
            textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colores.texto),
          ),
          GButton(
            icon: Icons.settings,
            text: 'Ajustes',
            iconColor: Colores.fondoAux,
            iconActiveColor: Colores.texto,
            backgroundColor: Colores.fondoAux, // Fondo del botón seleccionado
            textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colores.texto),
          ),
        ],
      ),
    );
  }
}
