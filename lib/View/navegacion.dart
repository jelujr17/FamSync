import 'package:flutter/material.dart';
import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_family/View/ajustes.dart';
import 'package:smart_family/View/resumen.dart';
import 'package:smart_family/View/Familia.dart';
import 'package:smart_family/components/colores.dart';

class FloatingNavigationBar extends StatefulWidget {
  final Function(int) onTabSelected;
  final int initialIndex;
  final int IdUsuario;
  final int Id;

  const FloatingNavigationBar({
    super.key,
    required this.onTabSelected,
    required this.IdUsuario,
    required this.Id,
    this.initialIndex = 0, 
  });

  @override
  _FloatingNavigationBarState createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTap(int index) async {
    setState(() {
      _currentIndex = index;
    });

    widget.onTabSelected(index);

    if (index == 0) {
      // Aquí usamos await para esperar que la navegación termine antes de continuar
      await Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: InicioScreen(IdUsuario: widget.IdUsuario, Id: widget.Id),
        ),
      );
    }

    if (index == 2) {
      // Aquí usamos await para esperar que la navegación termine antes de continuar
      await Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: FamiliaScreen(IdUsuario: widget.IdUsuario, Id: widget.Id),
        ),
      );
    }

    // Navegar a la pantalla de ajustes si se selecciona la pestaña de ajustes
    if (index == 3) {
      // Aquí usamos await para esperar que la navegación termine antes de continuar
      await Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: Ajustes(IdUsuario: widget.IdUsuario, Id: widget.Id),
        ),
      );

      // Una vez que regreses desde la pantalla de Ajustes, puedes restablecer el estado
      setState(() {
        _currentIndex = 3; // Asegúrate de que sigue en la pestaña de Ajustes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar(
      barColor: Colores.principal,
      controller: FloatingBottomBarController(initialIndex: _currentIndex),
      bottomBar: [
        BottomBarItem(
          icon: const Icon(Icons.add, size: 30, color: Colores.fondo),
          iconSelected: const Icon(Icons.add, color: Colores.botones, size: 30),
          title: 'Inicio',
          dotColor: Colores.botones,
          titleStyle: const TextStyle(color: Colores.fondo),
          onTap: (value) => _onItemTap(value),
        ),
        BottomBarItem(
          icon: const Icon(Icons.add, size: 30, color: Colores.fondo),
          iconSelected: const Icon(Icons.add, color: Colores.botones, size: 30),
          title: 'Buscar',
          dotColor: Colores.botones,
          titleStyle: const TextStyle(color: Colores.fondo),
          onTap: (value) => _onItemTap(value),
        ),
        BottomBarItem(
          icon:
              const Icon(Icons.family_restroom, size: 30, color: Colores.fondo),
          iconSelected: const Icon(Icons.family_restroom,
              color: Colores.botones, size: 30),
          title: 'Familia',
          dotColor: Colores.botones,
          titleStyle: const TextStyle(color: Colores.fondo),
          onTap: (value) => _onItemTap(value),
        ),
        BottomBarItem(
          icon: const Icon(Icons.settings, size: 30, color: Colores.fondo),
          iconSelected:
              const Icon(Icons.settings, color: Colores.botones, size: 30),
          title: 'Ajustes',
          dotColor: Colores.botones,
          titleStyle: const TextStyle(color: Colores.fondo),
          onTap: (value) => _onItemTap(value),
        ),
      ],
      bottomBarCenterModel: BottomBarCenterModel(
        centerBackgroundColor: Colores.botonesSecundarios,
        centerIcon: const FloatingCenterButton(
          child: Icon(
            Icons.home,
            color: Colors.white,
          ),
        ),
        centerIconChild: [
          FloatingCenterButtonChild(
            child: const Icon(Icons.calendar_month, color: Colors.white),
            onTap: () => print('Botón de inicio central'),
          ),
          FloatingCenterButtonChild(
            child: const Icon(Icons.access_alarm, color: Colors.white),
            onTap: () => print('Botón de alarma'),
          ),
          FloatingCenterButtonChild(
            child: const Icon(Icons.ac_unit_outlined, color: Colors.white),
            onTap: () => print('Botón de AC'),
          ),
        ],
      ),
    );
  }
}
