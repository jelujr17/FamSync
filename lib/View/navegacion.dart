
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/components/colores.dart';

class CustomBottomNavBar extends StatefulWidget {
  final PageController pageController;
  final NotchBottomBarController controller;
  final Perfiles perfil;

  const CustomBottomNavBar({
    super.key,
    required this.pageController,
    required this.controller,
    required this.perfil
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
    print('Construyendo CustomBottomNavBar');
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
          inActiveItem: Icon(Icons.home_filled, color: Colores.texto),
          activeItem: Icon(Icons.home_filled, color: Colores.texto),
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.widgets, color: Colores.texto),
          activeItem: Icon(Icons.dashboard, color: Colores.texto),
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.person, color: Colores.texto),
          activeItem: Icon(Icons.person, color: Colores.texto),
        ),
      ],
      onTap: (index) {
        print('Índice tocado en onTap: $index');
        if (index != _controller.index) {
          setState(() {
            _controller.index = index;
          });
          print('Índice cambiado a: $index');
        }
        widget.pageController.jumpToPage(index);
      },
      kIconSize: 24.0,
    );
  }
}