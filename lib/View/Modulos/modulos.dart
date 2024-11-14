import 'package:famsync/View/Modulos/categorias.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Calendario/calendario.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/components/colores.dart';

class Modulos extends StatefulWidget {
  final Perfiles perfil;

  const Modulos({super.key, required this.perfil});

  @override
  ModulosState createState() => ModulosState();
}

class ModulosState extends State<Modulos> {
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
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                }
                else if (modulo['ruta'] == 5) {
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                            Colores.principal.withOpacity(0.8),
                            Colores.principal.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        modulo['icono'],
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      modulo['titulo'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
          pageController: PageController(), pagina: 0, perfil: widget.perfil),
    );
  }
}
