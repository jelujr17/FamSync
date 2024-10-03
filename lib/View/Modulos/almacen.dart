import 'dart:io';

import 'package:famsync/Model/producto.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';

class Almacen extends StatefulWidget {
  final Perfiles perfil;

  const Almacen({super.key, required this.perfil});

  @override
  AlmacenState createState() => AlmacenState();
}

class AlmacenState extends State<Almacen> with SingleTickerProviderStateMixin {
  late Future<List<Productos>> _productosFuture;
  final int _productosPorPagina = 25;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tiendaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _sustitutoController = TextEditingController();
  List<int> _perfilSeleccionado = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _productosFuture = ServicioProductos()
        .getProductos(widget.perfil.UsuarioId, widget.perfil.Id);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPopup() {
    _nombreController.clear();
    _tiendaController.clear();
    _precioController.clear();
    _sustitutoController.clear(); // Añadir controlador para el sustituto

    _animationController.forward();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 200 * (1 - _animation.value)),
                  child: Opacity(
                    opacity: _animation.value,
                    child: AlertDialog(
                      contentPadding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: const Text('Crear Nuevo Producto'),
                      content: SizedBox(
                        width: 400,
                        height: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _nombreController,
                                decoration: const InputDecoration(
                                  hintText: 'Nombre del producto',
                                ),
                              ),
                              TextField(
                                controller: _tiendaController,
                                decoration: const InputDecoration(
                                  hintText: 'Tienda',
                                ),
                              ),
                              TextField(
                                controller: _precioController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Precio',
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Selecciona un perfil:',
                                  style: TextStyle(fontSize: 16)),
                              FutureBuilder<List<Perfiles>>(
                                future: ServicioPerfiles()
                                    .getPerfiles(widget.perfil.UsuarioId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text(
                                            'No hay perfiles disponibles.'));
                                  }

                                  List<Perfiles> perfiles = snapshot.data!;

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: perfiles.length,
                                    itemBuilder: (context, index) {
                                      final perfil = perfiles[index];

                                      return ListTile(
                                        title: Text(
                                          perfil.Nombre,
                                          style: const TextStyle(
                                            color: Colores.texto,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        leading: perfil.FotoPerfil.isNotEmpty &&
                                                File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')
                                                    .existsSync()
                                            ? Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius:
                                                        25, // Puedes ajustar el radio según tu necesidad
                                                    backgroundImage: FileImage(File(
                                                        'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')),
                                                  ),
                                                  if (_perfilSeleccionado
                                                      .contains(perfil.Id))
                                                    const Positioned(
                                                      right: 0,
                                                      bottom: 0,
                                                      child: Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green),
                                                    ),
                                                ],
                                              )
                                            : const Icon(
                                                Icons.image_not_supported),
                                        tileColor: _perfilSeleccionado
                                                .contains(perfil.Id)
                                            ? Colores.principal.withOpacity(0.2)
                                            : null,
                                        onTap: () {
                                          setStateDialog(() {
                                            if (_perfilSeleccionado
                                                .contains(perfil.Id)) {
                                                  _perfilSeleccionado.remove(perfil.Id);
                                            } else {
                                              _perfilSeleccionado
                                                  .add(perfil.Id);
                                            }
                                          });
                                          print(
                                              'Perfil seleccionado: $_perfilSeleccionado');
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (_perfilSeleccionado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Por favor, selecciona un perfil.')),
                              );
                              return;
                            }

                            String nombre = _nombreController.text;
                            String tienda = _tiendaController.text;
                            double precio =
                                double.tryParse(_precioController.text) ?? 0.0;

                            print(
                                'Producto: $nombre, Tienda: $tienda, Precio: $precio, Perfil seleccionado: $_perfilSeleccionado');

                            Navigator.of(context).pop();
                          },
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _animationController.reverse();
    });
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
          pageController: PageController(), pagina: 1, perfil: widget.perfil),
    );
  }
}
