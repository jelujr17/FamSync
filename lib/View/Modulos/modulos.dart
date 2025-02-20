import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:famsync/Model/Inicio/menuLateral.dart';
import 'package:famsync/View/Modulos/Tareas/agenda.dart';
import 'package:famsync/View/Modulos/Tareas/modelo_Tarea.dart';
import 'package:famsync/View/Modulos/categorias.dart';
import 'package:famsync/components/Inicio/BarraNavegacion/btm_nav_item.dart';
import 'package:famsync/components/Inicio/rive_utils.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Calendario/calendario.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/components/colores.dart';
import 'package:rive/rive.dart' as rive;

class Modulos extends StatefulWidget {
  final Perfiles perfil;
  final NotchBottomBarController? controller;

  const Modulos({super.key, required this.perfil, this.controller});

  @override
  ModulosState createState() => ModulosState();
}

class ModulosState extends State<Modulos> with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;

  Menu selectedBottonNav = bottomNavItems.first;
  Menu selectedSideMenu = sidebarMenus.first;

  late rive.SMIBool isMenuOpenInput;

  void updateSelectedBtmNav(Menu menu) {
    if (selectedBottonNav != menu) {
      setState(() {
        selectedBottonNav = menu;
      });
    }
  }

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(
        () {
          setState(() {});
        },
      );
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  final List<Map<String, dynamic>> modulos = [
    {'titulo': 'Calendario', 'icono': Icons.calendar_today, 'ruta': 0},
    {'titulo': 'Almacén', 'icono': Icons.shopping_cart, 'ruta': 1},
    {'titulo': 'Medicina', 'icono': Icons.medical_services, 'ruta': 2},
    {'titulo': 'Ropa', 'icono': Icons.checkroom, 'ruta': 3},
    {'titulo': 'Tareas', 'icono': Icons.task, 'ruta': 4},
    {'titulo': 'Categorías', 'icono': Icons.category, 'ruta': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quita el botón de retroceso
        title: const Text(
          'Módulos',
          style: TextStyle(
            color: Colores
                .texto, // Texto blanco para resaltar sobre el fondo negro
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colores.principal, // Fondo oscuro (negro)
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2, // Para hacer las tarjetas más rectangulares
          ),
          itemCount: modulos.length,
          itemBuilder: (context, index) {
            final modulo = modulos[index];
            return GestureDetector(
              onTap: () {
                if (modulo['ruta'] == 0) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: Calendario(perfil: widget.perfil),
                    ),
                  );
                } else if (modulo['ruta'] == 1) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: Almacen(perfil: widget.perfil),
                    ),
                  );
                } else if (modulo['ruta'] == 4) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: Agenda(perfil: widget.perfil),
                    ),
                  );
                } else if (modulo['ruta'] == 5) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: CategoriaPage(perfil: widget.perfil),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      Colores.fondoAux, // Fondo gris oscuro para las tarjetas
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colores.fondoAux.withOpacity(0.1),
                      spreadRadius: 4,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colores.botonesSecundarios
                                .withOpacity(0.8), // Dorado brillante
                            Colores.botonesSecundarios
                                .withOpacity(0.6), // Dorado más tenue
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        modulo['icono'],
                        size: 40,
                        color: Colors.white, // Icono blanco
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      modulo['titulo'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.white, // Texto blanco para un buen contraste
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colores.principal, // Fondo negro
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: SafeArea(
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colores.botones.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colores.botones.withOpacity(0.3),
                  offset: const Offset(0, 20),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  bottomNavItems.length,
                  (index) {
                    Menu navBar = bottomNavItems[index];
                    return BtmNavItem(
                      navBar: navBar,
                      press: () {
                        RiveUtils.chnageSMIBoolState(navBar.rive.status!);
                        updateSelectedBtmNav(navBar);
                      },
                      riveOnInit: (artboard) {
                        navBar.rive.status = RiveUtils.getRiveInput(artboard,
                            stateMachineName: navBar.rive.stateMachineName);
                      },
                      selectedNav: selectedBottonNav,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
