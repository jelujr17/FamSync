import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/Modulos/modulos.dart';
import 'package:smart_family/View/Modulos/resumen.dart';
import 'package:smart_family/View/ajustes.dart';
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/components/colores.dart';

class InicioScreen extends StatefulWidget {
  final Perfiles perfil;

  const InicioScreen({super.key, required this.perfil});

  @override
  InicioScreenState createState() => InicioScreenState();
}

class InicioScreenState extends State<InicioScreen> {
  late Navegacion _navegacion;

  @override
  void initState() {
    super.initState();
    _navegacion = Navegacion();
  }

  @override
  void dispose() {
    _navegacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _navegacion.pageController,
        onPageChanged: _navegacion.onPageChanged,
        children: <Widget>[
          ResumenScreen(perfil: widget.perfil),
          Modulos(perfil: widget.perfil),
          Ajustes(perfil: widget.perfil),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        pageController: _navegacion.pageController,
        controller: _navegacion.bottomBarController,
        perfil: widget.perfil,
        onTap: _navegacion.onTap,
      ),
    );
  }
}


