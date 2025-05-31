import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Anadir_Lista.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Lista.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Editar_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_ID/Imagen_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productoProvider =
          Provider.of<ProductosProvider>(context, listen: false);
      productoProvider.cargarProductos(user!.uid, widget.perfil.PerfilID);

      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      perfilesProvider.cargarPerfiles(user!.uid);

      final listasProvider =
          Provider.of<ListasProvider>(context, listen: false);
      listasProvider.cargarListas(user!.uid, widget.perfil.PerfilID);
    });
    void actualizarBanner() {
      setState(() {});
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colores.fondo,
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
                      backgroundColor: Colores.fondoAux,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colores.texto,
                      size: 20,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    color: Colores.fondoAux,
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
                            Icon(Icons.edit, color: Colores.texto),
                            SizedBox(width: 8),
                            Text(
                              'Editar',
                              style: TextStyle(color: Colores.texto),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Eliminar',
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colores.eliminar),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colores.eliminar),
                            ),
                          ],
                        ),
                      ),
                    ],
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colores.fondoAux,
                    ),
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colores.texto,
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
            color: Colores.fondoAux,
            child: Column(
              children: [
                ProductoCard(
                  producto: widget.producto,
                  onTap: () {},
                ),
                TopRoundedContainer(
                  color: Colores.fondo,
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
        color: Colores.fondo,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colores.texto,
                foregroundColor: Colores.fondoAux,
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
              child: Text("Añadir a una lista"),
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
          backgroundColor: Colores.fondo,
          title:
              Text('Eliminar Producto', style: TextStyle(color: Colores.texto)),
          content: Text('¿Estás seguro de que deseas eliminar este producto?',
              style: TextStyle(color: Colores.texto)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  Text('Cancelar', style: TextStyle(color: Colores.fondoAux)),
            ),
            TextButton(
              onPressed: () async {
                // Lógica para eliminar el producto
                // Por ejemplo, puedes llamar a un servicio para eliminar el producto
                final exito = await ServicioProductos()
                    .eliminarProducto(user!.uid, widget.producto.ProductoID);
                if (exito) {
                  // Inicializar la carga de productos
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final productoProvider =
                        Provider.of<ProductosProvider>(context, listen: false);
                    productoProvider.cargarProductos(
                        user!.uid, widget.perfil.PerfilID);
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
              child: const Text('Eliminar',
                  style: TextStyle(color: Colores.eliminar)),
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
            producto.nombre,
            style: TextStyle(
              color: Colores.texto,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 64,
          ),
          child: Text(
            "Se encuentra en la tienda: ${producto.TiendaID}",
            maxLines: 3,
            style: const TextStyle(
              fontSize: 18,
              color: Colores.texto,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            children: [
              Text(
                "precio: ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colores.texto,
                ),
              ),
              Text(
                "${producto.precio}€",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colores.hecho,
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
          const Text("Producto visible para los perfiles:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                producto.visible.length,
                (index) => Column(
                  children: [
                    IconoPerfil(
                      idPerfil: producto.visible[index],
                      esCreador: producto.PerfilID == producto.visible[index],
                    ),
                    const SizedBox(height: 4),
                    NombrePerfil(idPerfil: producto.visible[index]),
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
   IconoPerfil({
    super.key,
    required this.idPerfil,
    this.esCreador = false,
  });

  final String idPerfil;
  final bool esCreador;
    final user = FirebaseAuth.instance.currentUser;

  Future<Widget> loadProfileIcon(BuildContext context) async {
    final perfilesProvider =
        Provider.of<PerfilesProvider>(context, listen: false);
    Perfiles? perfilAux = perfilesProvider.perfiles
        .firstWhere((element) => element.PerfilID == idPerfil);
    final imageFile =
        await ServicioPerfiles().getFotoPerfil(user!.uid, idPerfil);
    return Image.file(imageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: loadProfileIcon(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colores.eliminar);
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
                  color: esCreador ? Colores.fondoAux : Colors.transparent),
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

  final String idPerfil;

  Future<String> loadProfileName(BuildContext context) async {
    final perfilesProvider =
        Provider.of<PerfilesProvider>(context, listen: false);
    Perfiles? perfilAux = perfilesProvider.perfiles
        .firstWhere((element) => element.PerfilID == idPerfil);
    return perfilAux.nombre;
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
            style: TextStyle(color: Colores.eliminar),
          );
        } else {
          return Text(snapshot.data!,
              style: const TextStyle(
                fontSize: 12,
                color: Colores.fondoAux,
              ));
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
              color: Colores.fondoAux.withOpacity(0.2),
            ),
        ],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colores.texto,
          padding: EdgeInsets.zero,
          backgroundColor: Colores.fondo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        onPressed: press,
        child: Icon(icon),
      ),
    );
  }
}
