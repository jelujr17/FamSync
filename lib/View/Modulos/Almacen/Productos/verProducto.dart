import 'dart:io';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/editarProducto.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:page_transition/page_transition.dart';

import 'package:famsync/View/Modulos/Almacen/Productos/nexoAlmacen.dart';

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

class VerProducto extends StatefulWidget {
  final Productos producto;
  final Perfiles perfil;

  const VerProducto({super.key, required this.producto, required this.perfil});

  @override
  DetallesProducto createState() => DetallesProducto();
}

class DetallesProducto extends State<VerProducto> {
  int _currentImageIndex = 0;
  String? _nombrePerfilCreador;
  Future<List<Perfiles>>? _futurePerfiles;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      obtenerNombrePerfil(widget.producto.IdPerfilCreador);
      _futurePerfiles = obtenerPerfiles(widget.producto.Visible);
    });
  }

  Future<List<Perfiles>> obtenerPerfiles(List<int> visiblesIds) async {
    return await ServicioPerfiles().getPerfilesByPerfil(visiblesIds);
  }

  Future<void> obtenerNombrePerfil(int idPerfil) async {
    Perfiles? perfil = await ServicioPerfiles().getPerfilById(idPerfil);
    if (perfil != null) {
      setState(() {
        _nombrePerfilCreador = perfil.Nombre;
      });
    }
  }

  void _showMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(
          100, 50, 0, 0), // Ajusta la posición según tus necesidades
      items: [
        const PopupMenuItem<String>(
          value: 'lista',
          child: Text('Añadir a una lista'),
        ),
        const PopupMenuItem<String>(
          value: 'editar',
          child: Text('Editar'),
        ),
        const PopupMenuItem<String>(
          value: 'eliminar',
          child: Text('Eliminar'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        // Maneja la opción seleccionada
        if (value == 'eliminar') {
          _confirmarEliminacion(widget.producto);
        }
        if (value == 'editar') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: EditarProducto(
                perfil: widget.perfil,
                producto: widget.producto,
              ),
            ),
          );
        }
        if (value == "lista") {
          NexoAlmacen().seleccionarLista(widget.producto,
              widget.perfil.UsuarioId, widget.perfil.Id, context);
        }
        print('Seleccionaste: $value');
      }
    });
  }

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
                bool eliminado =
                    await ServicioProductos().eliminarProducto(producto.Id);

                if (eliminado) {
                  // Aquí regresas a la página anterior después de eliminar
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: Almacen(perfil: widget.perfil),
                    ),
                  );
                } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.producto.Nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Ícono de flecha hacia atrás
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Almacen(perfil: widget.perfil),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin =
                      Offset(-1.0, 0.0); // Desplazamiento desde la derecha
                  const end = Offset.zero; // Posición final
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
              (route) => false, // Elimina todas las rutas anteriores
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), // Ícono de tres puntos
            onPressed: () => _showMenu(context), // Muestra el menú al presionar
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFABC270), Color(0xFFFEC868)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 4,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carrusel de imágenes
              widget.producto.Imagenes.isNotEmpty
                  ? Column(
                      children: [
                        CarouselSlider.builder(
                            options: CarouselOptions(
                              height: 280,
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
                              final imageName = widget.producto.Imagenes[index];

                              return FutureBuilder<File>(
                                future: ServicioProductos()
                                    .obtenerImagen(imageName),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // Muestra un indicador de carga mientras se obtiene la imagen
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    // Muestra un ícono de error si hay un problema al cargar la imagen
                                    return const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 100, color: Colors.red),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data!.existsSync()) {
                                    // Muestra la imagen si se obtuvo correctamente
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    // Muestra un ícono si la imagen no está disponible
                                    return const Center(
                                      child: Icon(Icons.image_not_supported,
                                          size: 100),
                                    );
                                  }
                                },
                              );
                            }),
                        const SizedBox(height: 8),
                        // Indicadores del carrusel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              widget.producto.Imagenes.asMap().entries.map(
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
                                      _currentImageIndex == entry.key
                                          ? 0.9
                                          : 0.4,
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
              // Barra de nombre del producto

              const SizedBox(height: 16),
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
                        'Creador del producto: ${_nombrePerfilCreador ?? 'Cargando...'}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Visible para:', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    // Lista de perfiles visibles
                    FutureBuilder<List<Perfiles>>(
                      future: _futurePerfiles,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No hay perfiles visibles.');
                        } else {
                          // Mostrar fotos de perfiles
                          return Wrap(
                            spacing: 8.0,
                            children: snapshot.data!.map((perfil) {
                              return Column(
                                children: [
                                  CircleAvatar(
                                    radius:
                                        25, // Ajusta el radio según tu necesidad
                                    backgroundImage: FileImage(File(
                                        'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    perfil.Nombre,
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        perfil: widget.perfil,
        pagina: 0,
        pageController: PageController(),
      ),
    );
  }
}
