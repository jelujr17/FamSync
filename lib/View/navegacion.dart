import 'package:famsync/View/Asistente%20Virtual/chatVS.dart';
import 'package:famsync/View/Inicio/resumen.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:famsync/View/Ajustes/ajustes.dart';
import 'package:famsync/components/colores.dart';

class CustomBottomNavBar extends StatefulWidget {
  final Perfiles perfil;
  final int pagina;

  const CustomBottomNavBar({
    super.key,
    required this.perfil,
    required this.pagina, required PageController pageController,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int pagina;

  @override
  void initState() {
    super.initState();
    pagina = widget.pagina;
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      items: const [
        TabItem(icon: Icons.widgets, title: 'Módulos'),
        TabItem(icon: Icons.details, title: 'Yaya'),
        TabItem(icon: Icons.settings, title: 'Ajustes'),
      ],
      initialActiveIndex: pagina,
      onTap: (index) {
        setState(() {
          pagina = index;
        });

        // Navegación entre pantallas sin `jumpToPage`
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: Modulos(perfil: widget.perfil),
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: Resumen(perfil: widget.perfil),
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
        }
      },
      backgroundColor: Colores.fondo,
      color: Colores.texto,
      activeColor: Colores.botonesSecundarios,
      elevation: 5.0,
      style: TabStyle.fixed,
    );
  }
}
