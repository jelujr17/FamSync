import 'dart:io';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/creacionProducto.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/listas.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/nexoAlmacen.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/verProducto.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/perfiles.dart';

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2, // Posición del pico de la curva
      size.height + 20, // Altura del pico de la curva
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class Almacen extends StatefulWidget {
  final Perfiles perfil;

  const Almacen({super.key, required this.perfil});

  @override
  AlmacenState createState() => AlmacenState();
}

class AlmacenState extends State<Almacen> with SingleTickerProviderStateMixin {
  late Future<List<Productos>> _productosFuture;
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

  void _mostrarMenuFiltro() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 300, // Ajusta la altura según tus necesidades
          child: Column(
            children: [
              const Text(
                'Filtrar Productos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Ejemplo de opciones de filtrado
              ListTile(
                title: const Text('Precio Ascendente'),
                onTap: () async {
                  final productos =
                      await _productosFuture; // Espera a que se resuelva el Future
                  productos.sort((a, b) =>
                      a.Precio.compareTo(b.Precio)); // Ordena la lista
                  setState(() {
                    _productosFuture = Future.value(
                        productos); // Actualiza el Future con la lista ordenada
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Precio Descendente'),
                onTap: () async {
                  final productos =
                      await _productosFuture; // Espera a que se resuelva el Future
                  productos.sort((a, b) =>
                      b.Precio.compareTo(a.Precio)); // Ordena la lista
                  setState(() {
                    _productosFuture = Future.value(
                        productos); // Actualiza el Future con la lista ordenada
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Por Tienda'),
                onTap: () async {
                  final productos =
                      await _productosFuture; // Espera a que se resuelva el Future
                  productos.sort((a, b) =>
                      b.Tienda.compareTo(a.Tienda)); // Ordena la lista
                  setState(() {
                    _productosFuture = Future.value(
                        productos); // Actualiza el Future con la lista ordenada
                  });
                  Navigator.of(context).pop();
                },
              ),
              // Agrega más opciones de filtrado según sea necesario
            ],
          ),
        );
      },
    );
  }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return ProductCreationCarousel(perfil: widget.perfil);
      },
    ).then((_) {
      setState(() {
        _productosFuture = ServicioProductos()
            .getProductos(widget.perfil.UsuarioId, widget.perfil.Id);
      });
    });
  }

  void _showPopup1() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Esto permite controlar el tamaño de la ventana emergente
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize:
              0.6, // Ajusta el tamaño inicial (0.6 significa 60% de la pantalla)
          minChildSize: 0.4, // Tamaño mínimo al que se puede reducir la hoja
          maxChildSize: 0.9, // Tamaño máximo al que se puede expandir la hoja
          builder: (BuildContext context, ScrollController scrollController) {
            return ListasPage(
              perfil: widget.perfil,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipPath(
          clipper: CurvedAppBarClipper(), // Usa tu clipper aquí
          child: AppBar(
            backgroundColor: Colores.botonesSecundarios,
            title: const Center(
              child: Text(
                'Almacén',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Margen alrededor del botón
                decoration: const BoxDecoration(
                  color: Colores.fondo, // Color de fondo
                  shape: BoxShape.circle, // Forma circular
                ),
                child: IconButton(
                  icon: const Icon(Icons.add,
                      color: Colores.texto), // Color del ícono
                  onPressed: _showPopup,
                ),
              ),
            ],
            leading: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 8.0), // Margen alrededor del botón
              decoration: const BoxDecoration(
                color: Colores.fondo, // Color de fondo
                shape: BoxShape.circle, // Forma circular
              ),
              child: IconButton(
                icon: const Icon(Icons.checklist_outlined,
                    color: Colores.texto), // Color del ícono
                onPressed: _showPopup1,
              ),
            ),
          ),
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
                  onPressed: () {
                    _mostrarMenuFiltro(); // Llama a la función para mostrar el menú de filtro
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
                  return const Center(
                      child: Text('No hay productos disponibles.'));
                }

                List<Productos> productos = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Dos columnas
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75, // Proporción de la tarjeta
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerProducto(
                              producto: producto,
                              perfil: widget.perfil,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        color: Colores.fondo,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Imagen del producto
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: producto.Imagenes.isEmpty
                                    ? const Icon(Icons.image_not_supported,
                                        size: 80, color: Colores.texto)
                                    : FutureBuilder<File>(
                                        future: ServicioProductos()
                                            .obtenerImagen(
                                                producto.Imagenes[0]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return const Icon(Icons.error,
                                                color: Colors.red);
                                          } else if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return Image.file(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            );
                                          } else {
                                            return const Icon(Icons.image,
                                                size: 80);
                                          }
                                        },
                                      ),
                              ),
                            ),
                            // Información del producto
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.Nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colores.texto,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tienda: ${producto.Tienda}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colores.texto,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Precio: ${producto.Precio.toString()}€',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colores.hecho,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // apartado para añadir a una lista
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      NexoAlmacen().seleccionarLista(
                                          producto,
                                          widget.perfil.UsuarioId,
                                          widget.perfil.Id,
                                          context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colores
                                          .botones, // Color del texto del botón
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Bordes redondeados
                                      ),
                                    ),
                                    child: const Text(
                                      'Añadir a lista',
                                      style: TextStyle(
                                          fontSize: 16), // Tamaño del texto
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
      extendBody: true,
      bottomNavigationBar:
          CustomBottomNavBar(perfil: widget.perfil, paginaActual: 0),
    );
  }
}
