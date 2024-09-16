import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/components/colores.dart'; // Asegúrate de importar el archivo correcto

class CustomBottomNavBar extends StatefulWidget {
  final PageController pageController;
  final NotchBottomBarController controller;
  final int Id;
  final int IdUsuario;

  const CustomBottomNavBar({
    super.key,
    required this.pageController,
    required this.controller,
    required this.Id,
    required this.IdUsuario,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    print('Construyendo CustomBottomNavBar'); // Para depuración
    return AnimatedNotchBottomBar(
      notchBottomBarController: _controller,
      color: Colores.principal,
      showLabel: true,
      textOverflow: TextOverflow.visible,
      maxLine: 1,
      shadowElevation: 5,
      kBottomRadius: 28.0,
      notchColor: Colores.botones,
      removeMargins: false,
      bottomBarWidth: 500,
      showShadow: false,
      durationInMilliSeconds: 300,
      itemLabelStyle: const TextStyle(fontSize: 10),
      elevation: 1,
      bottomBarItems: const [
        BottomBarItem(
          inActiveItem: Icon(
            Icons.home_filled,
            color: Colors.blueGrey,
          ),
          activeItem: Icon(
            Icons.home_filled,
            color: Colors.blueAccent,
          ),
          itemLabel: 'Inicio',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.star, color: Colors.blueGrey),
          activeItem: Icon(
            Icons.star,
            color: Colors.blueAccent,
          ),
          itemLabel: 'Buscar',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.settings,
            color: Colors.blueGrey,
          ),
          activeItem: Icon(
            Icons.settings,
            color: Colors.pink,
          ),
          itemLabel: 'Configuración',
        ),
      ],
      onTap: (index) {
        print('Índice tocado en onTap: $index');
        if (index != _controller.index) {
          setState(() {
            _controller.index = index;
          });
          print('Índice cambiado a: $index');
          // Verifica si el PageController puede ir a la página
          if (index >= 0 && index < widget.pageController.positions.length) {
            widget.pageController.jumpToPage(index);
          } else {
            print('Índice fuera del rango: $index');
          }
        }
      },
      kIconSize: 24.0,
    );
  }
}
