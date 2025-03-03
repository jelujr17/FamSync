import 'dart:math';
import 'package:famsync/Model/Inicio/menuLateral.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/View/Modulos/Calendario/calendario.dart';
import 'package:famsync/View/Modulos/Tareas/agenda.dart';
import 'package:famsync/View/Modulos/categorias.dart';
import 'package:famsync/components/Inicio/BarraNavegacion/btm_nav_item.dart';
import 'package:famsync/components/Inicio/boton_menu_lateral.dart';
import 'package:famsync/components/Inicio/menu_lateral.dart';
import 'package:famsync/components/Inicio/rive_utils.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

final GlobalKey<HomeState> homeKey = GlobalKey<HomeState>();

class Home extends StatefulWidget {
  final Perfiles perfil; // Identificador del perfil del usuario
  final int initialPage; // Índice de la página inicial

  const Home({super.key, required this.perfil, this.initialPage = 0});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  //-----------------Menu Lateral-----------------------------------------------
  bool isSideBarOpen = false;

  late Menu selectedBottonNav;
  Menu selectedSideMenu = sidebarMenus.first;

  late SMIBool isMenuOpenInput;

  void updateSelectedBtmNav(Menu menu) {
    int pageIndex = bottomNavItems.indexOf(menu);
    if (pageIndex != -1) {
      if (mounted && _pageController.hasClients) {
        // Verifica que _pageController es válido
        setState(() {
          selectedBottonNav = menu;
          _pageController.jumpToPage(pageIndex);
        });
      }
    } 
  }

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;
  late PageController _pageController;

  @override
  void initState() {
    selectedBottonNav = bottomNavItems[widget.initialPage];
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
    _pageController = PageController(initialPage: widget.initialPage);
    _pageController.addListener(() {
      int currentPage = _pageController.page?.round() ?? 0;
      if (currentPage < bottomNavItems.length) {
        setState(() {
          selectedBottonNav = bottomNavItems[currentPage];
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  //-----------------Menu Lateral-----------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeKey,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF17203A),
      body: Stack(
        children: [
          AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 0 : -288,
            top: 0,
            child: SideBar(perfil: widget.perfil),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                  1 * animation.value - 30 * (animation.value) * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            selectedBottonNav = bottomNavItems[index];
                          });
                        },
                        children: [
                          // Aquí puedes agregar las páginas correspondientes a cada elemento de la barra de navegación
                          Navigator(
                            onGenerateRoute: (RouteSettings settings) {
                              switch (settings.name) {
                                case '/':
                                  return MaterialPageRoute(
                                      builder: (context) => Agenda(perfil: widget.perfil));
                                case '/page2':
                                  return MaterialPageRoute(
                                      builder: (context) => Almacen(perfil: widget.perfil));
                                case '/page3':
                                  return MaterialPageRoute(
                                      builder: (context) => Calendario(perfil: widget.perfil));
                                default:
                                  return MaterialPageRoute(
                                      builder: (context) => Agenda(perfil: widget.perfil));
                              }
                            },
                          ),
                          Navigator(
                            onGenerateRoute: (RouteSettings settings) {
                              switch (settings.name) {
                                case '/':
                                  return MaterialPageRoute(
                                      builder: (context) => Almacen(perfil: widget.perfil));
                                default:
                                  return MaterialPageRoute(
                                      builder: (context) => Almacen(perfil: widget.perfil));
                              }
                            },
                          ),
                          Navigator(
                            onGenerateRoute: (RouteSettings settings) {
                              switch (settings.name) {
                                case '/':
                                  return MaterialPageRoute(
                                      builder: (context) => Calendario(perfil: widget.perfil));
                                default:
                                  return MaterialPageRoute(
                                      builder: (context) => Calendario(perfil: widget.perfil));
                              }
                            },
                          ),
                          Navigator(
                            onGenerateRoute: (RouteSettings settings) {
                              switch (settings.name) {
                                case '/':
                                  return MaterialPageRoute(
                                      builder: (context) => CategoriaPage(perfil: widget.perfil));
                                default:
                                  return MaterialPageRoute(
                                      builder: (context) => CategoriaPage(perfil: widget.perfil));
                              }
                            },
                          ),
                          const Placeholder(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 220 : 0,
            top: 16,
            child: MenuBtn(
              press: () {
                isMenuOpenInput.value = !isMenuOpenInput.value;

                if (_animationController.value == 0) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }

                setState(
                  () {
                    isSideBarOpen = !isSideBarOpen;
                  },
                );
              },
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine");
                artboard.addController(controller!);
                isMenuOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;
                isMenuOpenInput.value = true;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: SafeArea(
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
            margin: const EdgeInsets.symmetric(horizontal: 24)
                .copyWith(bottom: 24), // Agrega margen inferior
            decoration: BoxDecoration(
              color: Colores.principal.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colores.principal.withOpacity(0.3),
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
