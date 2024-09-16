import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/components/colores.dart';

class CalendarioScreen extends StatefulWidget {
  final int IdUsuario;
  final int Id;

  const CalendarioScreen(
      {super.key, required this.IdUsuario, required this.Id});

  @override
  CalendarioScreenState createState() => CalendarioScreenState();
}

class CalendarioScreenState extends State<CalendarioScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  late NotchBottomBarController _controller;
  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        pageController: _pageController,
        controller: _controller,
        Id: widget.Id,
        IdUsuario: widget.IdUsuario,
      ),
    );
  }
}
