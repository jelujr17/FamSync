import 'dart:io';

import 'package:famsync/Model/producto.dart';
import 'package:famsync/View/Modulos/creacionProducto.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:image_picker/image_picker.dart';

class Almacen extends StatefulWidget {
  final Perfiles perfil;

  const Almacen({super.key, required this.perfil});

  @override
  AlmacenState createState() => AlmacenState();
}

class AlmacenState extends State<Almacen> with SingleTickerProviderStateMixin {
  late Future<List<Productos>> _productosFuture;
  final int _productosPorPagina = 25;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _productosFuture = ServicioProductos()
        .getProductos(widget.perfil.UsuarioId, widget.perfil.Id);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

// Agregar este método en la clase AlmacenState
  void _confirmarEliminacion(Productos producto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar el producto "${producto.Nombre}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Aquí llamas a tu servicio para eliminar el producto
                bool eliminado = await ServicioProductos().eliminarProducto(producto
                    .Id); // Asegúrate de implementar este método en tu servicio.

                if (eliminado) {
                  setState(() {
                    _productosFuture = ServicioProductos().getProductos(
                        widget.perfil.UsuarioId, widget.perfil.Id);
                  });
                  Navigator.of(context).pop(); // Cierra el diálogo
                } else {
                  // Manejar el error si la eliminación falla (opcional)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al eliminar el producto.')),
                  );
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  List<XFile>? _imagenesSeleccionadas =
      []; // Agregar esta línea para almacenar las imágenes seleccionadas
  final ImagePicker _picker =
      ImagePicker(); // Crear una instancia de ImagePicker

  Future<void> _seleccionarImagenes() async {
    final List<XFile>? imagenes = await _picker.pickMultiImage();
    if (imagenes != null) {
      setState(() {
        _imagenesSeleccionadas!.clear();
        _imagenesSeleccionadas!.addAll(imagenes);
        print(
            'Imágenes seleccionadas: ${_imagenesSeleccionadas!.map((img) => img.path).toList()}'); // Agrega esta línea
      });
    }
  }

  // Tu método _showPopup modificado para incluir la opción de añadir imágenes
  void _showPopup() {
  showDialog(
    context: context,
    builder: (context) {
      return const ProductCreationCarousel();
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colores.principal, // Cambiar el color de fondo
        title: const Center(
          child: Text(
            'Almacén',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showPopup,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.checklist_outlined),
          onPressed: _showPopup,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
                hintText: 'Buscar productos...',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Productos>>(
              future: _productosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hay productos disponibles.'));
                }

                List<Productos> productos = snapshot.data!;
                return ListView.builder(
                  itemCount: productos.length > _productosPorPagina
                      ? _productosPorPagina
                      : productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      color: Colores.fondo, // Cambiar el color de la tarjeta
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: producto.Imagenes.isNotEmpty &&
                                File(producto.Imagenes[0]).existsSync()
                            ? Image.file(
                                File(producto.Imagenes[0]),
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(producto.Nombre,
                            style: const TextStyle(
                                color:
                                    Colores.texto)), // Cambiar color del texto
                        subtitle: Text(
                          'Tienda: ${producto.Tienda} \nPrecio: ${producto.Precio.toString()}',
                          style: const TextStyle(
                              color: Colores.texto), // Cambiar color del texto
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colores
                                      .botones), // Cambiar color del icono
                              onPressed: () {
                                // Maneja la acción de editar
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colores
                                      .eliminar), // Cambiar color del icono
                              onPressed: () {
                                _confirmarEliminacion(
                                    producto); // Llama al método de confirmación
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Maneja la acción al tocar el producto
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
          pageController: PageController(), pagina: 1, perfil: widget.perfil),
    );
  }
}
