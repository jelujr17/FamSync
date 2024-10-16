import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductCreationCarousel extends StatefulWidget {
  const ProductCreationCarousel({super.key});

  @override
  _ProductCreationCarouselState createState() =>
      _ProductCreationCarouselState();
}

class _ProductCreationCarouselState extends State<ProductCreationCarousel> {
  final PageController _pageController = PageController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tiendaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final List<XFile> _imagenesSeleccionadas = [];

  final ImagePicker _picker = ImagePicker();

  // Variable para mantener el índice de la página actual
  int _currentPageIndex = 0;

  Future<void> _seleccionarImagenes() async {
    final List<XFile> imagenes = await _picker.pickMultiImage();
    setState(() {
      _imagenesSeleccionadas.clear();
      _imagenesSeleccionadas.addAll(imagenes);
    });
  }

  @override
  void initState() {
    super.initState();
    // Escuchar los cambios de página del PageController
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.toInt();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _tiendaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 550,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Primera pantalla: Nombre, tienda y precio
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del producto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.shopping_cart),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _tiendaController,
                          decoration: InputDecoration(
                            labelText: 'Tienda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.store),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _precioController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Segunda pantalla: Selección de perfiles
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selecciona los perfiles visibles:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 5, // Cambia esto por la lista real
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 4,
                                child: ListTile(
                                  title: Text('Perfil $index'),
                                  onTap: () {
                                    // Lógica para seleccionar perfiles
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tercera pantalla: Selección de imágenes
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _seleccionarImagenes,
                          icon: const Icon(Icons.image),
                          label: const Text('Seleccionar imágenes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _imagenesSeleccionadas.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _imagenesSeleccionadas.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(_imagenesSeleccionadas[index]
                                              .path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text(
                                'No hay imágenes seleccionadas.',
                                style: TextStyle(color: Colors.grey),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contenedor para los botones de navegación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón "Atrás" visible solo en la segunda y tercera página
                  if (_currentPageIndex > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_currentPageIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context)
                              .pop(); // Cerrar diálogo si es la primera página
                        }
                      },
                      label: const Text('Atrás'),
                      icon: const Icon(Icons.arrow_back),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),

                  // Botón "Siguiente" visible solo en la primera y segunda página
                  if (_currentPageIndex < 2)
                    ElevatedButton.icon(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      label: const Text('Siguiente'),
                      icon: const Icon(Icons.arrow_forward),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),

                  // Botón "Guardar" visible solo en la tercera página
                  if (_currentPageIndex == 2)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Lógica para guardar el producto
                        // Aquí puedes manejar la lógica para guardar los datos.
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
