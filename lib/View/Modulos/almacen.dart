import 'package:famsync/Model/producto.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';

class Almacen extends StatefulWidget {
  final Perfiles perfil;

  const Almacen({super.key, required this.perfil});

  @override
  AlmacenState createState() => AlmacenState();
}

class AlmacenState extends State<Almacen> {
  late Future<List<Productos>> _productosFuture;
  final int _productosPorPagina = 25;

  @override
  void initState() {
    super.initState();
    // Aquí obtén los productos al inicializar la pantalla
    _productosFuture = ServicioProductos().getProductos(widget.perfil.UsuarioId, widget.perfil.Id);
  }

  void _showPopup() {
    // Implementar la lógica para mostrar una ventana emergente
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ventana Emergente'),
          content: const Text('Aquí va el contenido de la ventana emergente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar la ventana emergente
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacén'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Aquí implementas la acción para añadir productos
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _showPopup,
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Aquí implementas la lógica para el filtro
                  },
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
                  return const Center(child: Text('No hay productos disponibles.'));
                }

                // Aquí tienes la lista de productos
                List<Productos> productos = snapshot.data!;
                return ListView.builder(
                  itemCount: productos.length > _productosPorPagina ? _productosPorPagina : productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: producto.Imagenes.isNotEmpty
                            ? Image.network(producto.Imagenes[0], width: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(producto.Nombre),
                        subtitle: Text('Tienda: ${producto.Tienda} \nPrecio: ${producto.Precio.toString()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Maneja la acción de editar
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Maneja la acción de eliminar
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
          pageController: PageController(),
          pagina: 2,
          perfil: widget.perfil),
    );
  }
}
