import 'package:famsync/Model/Inicio/Iconos_animados.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/Inicio/informacion_usuario.dart';
import 'package:flutter/material.dart';

import 'side_menu.dart';

class SideBar extends StatefulWidget {
  final Perfiles perfil; // Identificador del perfil del usuario
  const SideBar({super.key, required this.perfil});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu_Aux selectedSideMenu = sidebarMenus.first;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(
                nombre: widget.perfil.Nombre,
                fecha: widget.perfil.FechaNacimiento,
                perfil: widget.perfil,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, top: 32, bottom: 16),
                        child: Text(
                          "Perfil y Usuario".toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                      ...sidebarMenus.map((menu) => SideMenu(
                            menu: menu,
                            selectedMenu: selectedSideMenu,
                            press: () {
                              setState(() {
                                selectedSideMenu = menu;
                              });
                              menu.onTap(context);
                            },
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, top: 40, bottom: 16),
                        child: Text(
                          "Configuracion".toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                      ...sidebarMenus2.map((menu) => SideMenu(
                            menu: menu,
                            selectedMenu: selectedSideMenu,
                            press: () {
                              setState(() {
                                selectedSideMenu = menu;
                              });
                              menu.onTap(context);
                            },
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, top: 40, bottom: 16),
                        child: Text(
                          "Informacion y Ayuda".toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                      ...sidebarMenus3.map((menu) => SideMenu(
                            menu: menu,
                            selectedMenu: selectedSideMenu,
                            press: () {
                              setState(() {
                                selectedSideMenu = menu;
                              });
                              menu.onTap(context);
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}