import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:famsync/View/Modulos/resumen.dart';
import 'package:famsync/View/ajustes.dart';
import 'package:famsync/components/colores.dart';

class CustomBottomNavBar extends StatefulWidget {
  final PageController pageController;
  final Perfiles perfil;
  final int pagina;

  const CustomBottomNavBar({
    super.key,
    required this.pageController,
    required this.perfil,
    required this.pagina,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int pagina; // Usar late para que se inicialice en initState

  @override
  void initState() {
    super.initState();
    pagina = widget.pagina; // Inicializar con el valor pasado
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      items: const [
        TabItem(icon: Icons.home_filled, title: 'Inicio'),
        TabItem(icon: Icons.widgets, title: 'Módulos'),
        TabItem(icon: Icons.settings, title: 'Ajustes'),
      ],
      initialActiveIndex: pagina, // Establecer el índice activo inicial
      onTap: (index) {
        setState(() {
          pagina = index; // Actualizar el estado con el nuevo índice
        });

        // Navegación según el índice
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: ResumenScreen(perfil: widget.perfil),
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: Modulos(perfil: widget.perfil),
              ),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: Ajustes(perfil: widget.perfil),
              ),
            );
            break;
            case 3:
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: Modulos(perfil: widget.perfil),
              ),
            );
            break;
        }

        // Saltar a la página correspondiente
        widget.pageController.jumpToPage(index);
      },
      backgroundColor: Colores.fondo, // Color de fondo de la barra
      color: Colores.texto, // Color de iconos inactivos
      activeColor:  Colores.principal, // Color de iconos activos
      elevation: 5.0, // Elevación de la barra
      style: TabStyle.fixed, // Estilo de la barra (fijo)
    );
  }
}
