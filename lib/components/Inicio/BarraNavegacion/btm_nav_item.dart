import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:famsync/Model/Inicio/Iconos_animados.dart';
import 'package:famsync/components/Inicio/BarraNavegacion/animated_bar.dart';

class BtmNavItem extends StatefulWidget {
  const BtmNavItem({
    super.key,
    required this.navBar,
    required this.press,
    required this.selectedNav,
  });

  final Menu_Aux navBar;
  final VoidCallback press;
  final Menu_Aux selectedNav;

  @override
  _BtmNavItemState createState() => _BtmNavItemState();
}

class _BtmNavItemState extends State<BtmNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 🔹 Se ha añadido duración obligatoria
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await Future.delayed(const Duration(seconds: 2)); // Pausa de 2 segundos
          _controller.reset();
          _controller.forward();
        }
      });

    if (widget.selectedNav == widget.navBar) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant BtmNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedNav == widget.navBar) {
      _controller.forward(from: 0);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.press,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBar(isActive: widget.selectedNav == widget.navBar),
          SizedBox(
            height: 36,
            width: 36,
            child: Opacity(
              opacity: widget.selectedNav == widget.navBar ? 1 : 0.5,
              child: Lottie.asset(
                widget.navBar.lottie.src,
                fit: BoxFit.cover,
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  if (widget.selectedNav == widget.navBar) {
                    _controller.forward();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
