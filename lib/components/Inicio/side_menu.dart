import 'package:famsync/Model/Inicio/Iconos_animados.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
    required this.menu,
    required this.press,
    required this.selectedMenu,
  });

  final Menu_Aux menu;
  final VoidCallback press;
  final Menu_Aux selectedMenu;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de animación
    _animationController = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant SideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reproduce la animación solo si el menú está seleccionado
    if (widget.selectedMenu == widget.menu) {
      _animationController.reset();
      _animationController.forward();
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(color: Colors.white24, height: 1),
        ),
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: widget.selectedMenu == widget.menu ? 288 : 0,
              height: 56,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF6792FF),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            ListTile(
              onTap: widget.press,
              leading: SizedBox(
                height: 36,
                width: 36,
                child: Lottie.asset(
                  widget.menu.lottie.src,
                  controller: _animationController, // Controlador de animación
                  onLoaded: (composition) {
                    _animationController.duration = composition.duration;
                    if (widget.selectedMenu == widget.menu) {
                      _animationController.forward();
                    }
                  },
                ),
              ),
              title: Text(
                widget.menu.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}