import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/navegacion.dart';

class Perfil extends StatefulWidget {
  final Perfiles perfil;
  const Perfil({super.key, required this.perfil});

  @override
  PerfilState createState() => PerfilState();
}

class PerfilState extends State<Perfil> {
  final PageController _pageController = PageController(initialPage: 2);
  late NotchBottomBarController _bottomBarController;

  @override
  void initState() {
    super.initState();
    _bottomBarController = NotchBottomBarController(index: 2);
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navegar a la página de notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navegar a la página de ajustes
            },
          ),
        ],
        centerTitle: true,
        // Opción para cambiar de perfil
        leading: IconButton(
          icon: const Icon(Icons.switch_account),
          onPressed: () {
            // Acción para cambiar de perfil
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                      'assets/profile_picture.png'), // Reemplazar con la imagen del perfil
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navegar a la página de edición de perfil
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.perfil.Nombre, // Reemplazar con el nombre del perfil
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        pageController: _pageController,
        controller: _bottomBarController,
        perfil: widget.perfil,
      ),
    );
  }
}
