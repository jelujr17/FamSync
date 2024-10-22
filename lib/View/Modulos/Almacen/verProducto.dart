import 'dart:io';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/producto.dart';
import 'package:carousel_slider/carousel_slider.dart';

class VerProducto extends StatefulWidget {
  final Productos producto;
  final Perfiles perfil;

  const VerProducto({super.key, required this.producto, required this.perfil});

  @override
  DetallesProducto createState() => DetallesProducto();
}

class DetallesProducto extends State<VerProducto> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto.Nombre),
        backgroundColor: const Color(0xFFABC270),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar imágenes del producto en un carrusel
            widget.producto.Imagenes.isNotEmpty
                ? Column(
                    children: [
                      CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 200,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                        itemCount: widget.producto.Imagenes.length,
                        itemBuilder: (context, index, realIndex) {
                          final imagePath = widget.producto.Imagenes[index];
                          final imageFile = File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\$imagePath');

                          // Comprobar si el archivo existe antes de mostrarlo
                          if (imageFile.existsSync()) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else {
                            return const Center(
                              child: Icon(Icons.image_not_supported, size: 100),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      // Indicadores de la posición del carrusel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.producto.Imagenes.asMap().entries.map(
                          (entry) {
                            return GestureDetector(
                              onTap: () => setState(() {
                                _currentImageIndex = entry.key;
                              }),
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.green)
                                      .withOpacity(
                                    _currentImageIndex == entry.key ? 0.9 : 0.4,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  )
                : const Center(
                    child: Icon(Icons.image_not_supported, size: 100)),
            // Detalles del producto
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text('Tienda: ${widget.producto.Tienda}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.price_change, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                          'Precio: ${widget.producto.Precio.toStringAsFixed(2)}€',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Creador del Perfil ID: ${widget.producto.IdPerfilCreador}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                      'Creador del Usuario ID: ${widget.producto.IdUsuarioCreador}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Visibilidad: ${widget.producto.Visible.join(", ")}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción de edición aquí
        },
        backgroundColor: const Color(0xFFABC270),
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: CustomBottomNavBar(
          pageController: PageController(), pagina: 1, perfil: widget.perfil),
    );
  }
}
