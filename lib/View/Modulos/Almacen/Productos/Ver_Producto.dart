import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Anadir_Lista.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Lista.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Editar_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_ID/Imagen_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:provider/provider.dart';

class DetallesProducto extends StatefulWidget {
  const DetallesProducto({
    super.key,
    required this.producto,
    required this.perfil,
  });

  final Productos producto;
  final Perfiles perfil;

  @override
  State<DetallesProducto> createState() => _DetallesProductoState();
}

class _DetallesProductoState extends State<DetallesProducto> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productoProvider =
          Provider.of<ProductosProvider>(context, listen: false);
      productoProvider.cargarProductos(
          context, widget.perfil.UsuarioId, widget.perfil.Id);

      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      perfilesProvider.cargarPerfiles(context, widget.perfil.UsuarioId);

      final listasProvider =
          Provider.of<ListasProvider>(context, listen: false);
      listasProvider.cargarListas(
          context, widget.perfil.UsuarioId, widget.perfil.Id);
    });
    void actualizarBanner() {
      setState(() {});
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // Aumenta la altura del AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false, // Desactiva el botón por defecto
          flexibleSpace: Padding(
            padding:
                const EdgeInsets.only(left: 0, top: 100), // Ajusta la posición
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(
                            context); // Navega hacia atrás si hay una página en la pila
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Almacen(perfil: widget.perfil),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'Editar') {
                        _editarProducto(context);
                      } else if (result == 'Eliminar') {
                        _eliminarProducto(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'Editar',
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Eliminar',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ImagenesProducto(producto: widget.producto),
          TopRoundedContainer(
            color: Colors.white,
            child: Column(
              children: [
                ProductoCard(
                  producto: widget.producto,
                  onTap: () {},
                ),
                TopRoundedContainer(
                  color: const Color(0xFFF6F7F9),
                  child: Column(
                    children: [
                      InformacionProducto(producto: widget.producto),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: TopRoundedContainer(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFF7643),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onPressed: () {
                final listasProvider =
                    Provider.of<ListasProvider>(context, listen: false);
                listasProvider.listas.isEmpty
                    ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  16), // Bordes redondeados opcionales
                            ),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: VentanaListas(
                                actualizarBanner: actualizarBanner,
                                perfil: widget.perfil,
                              ),
                            ),
                          );
                        },
                      )
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  16), // Bordes redondeados opcionales
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.8, // 80% del ancho de la pantalla
                              height: MediaQuery.of(context).size.height *
                                  0.4, // 40% del alto de la pantalla
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: VentanaAnadirListas(
                                  actualizarBanner: actualizarBanner,
                                  producto: widget.producto,
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
              child: const Text("Añadir a una lista"),
            ),
          ),
        ),
      ),
    );
  }

  void _editarProducto(BuildContext context) {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditarProducto(producto: widget.producto, perfil: widget.perfil),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Se realizó una actualización
    }
  }

  void _eliminarProducto(BuildContext context) {
    // Implementa la lógica para eliminar el producto
    // Por ejemplo, puedes mostrar un cuadro de diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Lógica para eliminar el producto
                // Por ejemplo, puedes llamar a un servicio para eliminar el producto
                final exito = await ServicioProductos()
                    .eliminarProducto(context, widget.producto.Id);
                if (exito) {
                  // Inicializar la carga de productos
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final productoProvider =
                        Provider.of<ProductosProvider>(context, listen: false);
                    productoProvider.cargarProductos(
                        context, widget.perfil.UsuarioId, widget.perfil.Id);
                  });
                  Navigator.of(context)
                      .pop(); // Cerrar el diálogo de confirmación
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Almacen(perfil: widget.perfil),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin =
                          Offset(1.0, 0.0); // Comienza desde la derecha
                      const end = Offset.zero; // Termina en la posición final
                      const curve = Curves.easeInOut; // Curva de animación

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ));
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
}

class TopRoundedContainer extends StatelessWidget {
  const TopRoundedContainer({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: child,
    );
  }
}

class ProductoCard extends StatelessWidget {
  const ProductoCard({
    super.key,
    required this.producto,
    this.pressOnSeeMore,
    required Function() onTap,
  });

  final Productos producto;
  final GestureTapCallback? pressOnSeeMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            producto.Nombre,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 64,
          ),
          child: Text(
            "Se encuentra en la tienda: ${producto.Tienda}",
            maxLines: 3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            children: [
              const Text("Precio: "),
              Text(
                "${producto.Precio}€",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF7643),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InformacionProducto extends StatelessWidget {
  const InformacionProducto({
    super.key,
    required this.producto,
  });

  final Productos producto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Producto visible para los perfiles:"),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                producto.Visible.length,
                (index) => Column(
                  children: [
                    IconoPerfil(
                      idPerfil: producto.Visible[index],
                      esCreador:
                          producto.IdPerfilCreador == producto.Visible[index],
                    ),
                    const SizedBox(height: 4),
                    NombrePerfil(idPerfil: producto.Visible[index]),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class IconoPerfil extends StatelessWidget {
  const IconoPerfil({
    super.key,
    required this.idPerfil,
    this.esCreador = false,
  });

  final int idPerfil;
  final bool esCreador;

  Future<Widget> loadProfileIcon(BuildContext context) async {
    final perfilesProvider =
        Provider.of<PerfilesProvider>(context, listen: false);
    Perfiles? perfilAux = perfilesProvider.perfiles
        .firstWhere((element) => element.Id == idPerfil);
    final imageFile =
        await ServicioPerfiles().obtenerImagen(context, perfilAux.FotoPerfil);
    return Image.file(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: loadProfileIcon(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.red);
        } else {
          return Container(
            margin: const EdgeInsets.only(
                right: 4), // Ajusta el margen si es necesario
            padding: const EdgeInsets.all(8),
            height: 60, // Aumenta el tamaño del contenedor
            width: 60, // Aumenta el tamaño del contenedor
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                  color:
                      esCreador ? const Color(0xFFFF7643) : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: snapshot.data!,
            ),
          );
        }
      },
    );
  }
}

class NombrePerfil extends StatelessWidget {
  const NombrePerfil({
    super.key,
    required this.idPerfil,
  });

  final int idPerfil;

  Future<String> loadProfileName(BuildContext context) async {
    final perfilesProvider =
        Provider.of<PerfilesProvider>(context, listen: false);
    Perfiles? perfilAux = perfilesProvider.perfiles
        .firstWhere((element) => element.Id == idPerfil);
    return perfilAux.Nombre;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: loadProfileName(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text(
            'Error',
            style: TextStyle(color: Colors.red),
          );
        } else {
          return Text(snapshot.data!);
        }
      },
    );
  }
}

class RoundedIconBtn extends StatelessWidget {
  const RoundedIconBtn({
    super.key,
    required this.icon,
    required this.press,
    this.showShadow = false,
  });

  final IconData icon;
  final GestureTapCancelCallback press;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (showShadow)
            BoxShadow(
              offset: const Offset(0, 6),
              blurRadius: 10,
              color: const Color(0xFFB0B0B0).withOpacity(0.2),
            ),
        ],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF7643),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        onPressed: press,
        child: Icon(icon),
      ),
    );
  }
}
