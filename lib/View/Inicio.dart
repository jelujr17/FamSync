import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/Modulos/modulos.dart';
import 'package:smart_family/View/Modulos/resumen.dart';
import 'package:smart_family/View/ajustes.dart';
import 'package:smart_family/View/navegacion.dart';

class InicioScreen extends StatefulWidget {
  final Perfiles perfil;

  const InicioScreen({super.key, required this.perfil});

  @override
  InicioScreenState createState() => InicioScreenState();
}

class InicioScreenState extends State<InicioScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  late NotchBottomBarController _bottomBarController;

  @override
  void initState() {
    super.initState();
    _bottomBarController = NotchBottomBarController(index: 0);
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_bottomBarController.index != index) {
      setState(() {
        _bottomBarController.index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          ResumenScreen(perfil: widget.perfil),
          Modulos(perfil: widget.perfil),
          Ajustes(perfil: widget.perfil),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        pageController: _pageController,
        controller: _bottomBarController,
        perfil: widget.perfil
      ),
    );
  }
}
