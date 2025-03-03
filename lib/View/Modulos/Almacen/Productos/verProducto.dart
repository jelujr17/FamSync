import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/editarProducto.dart';
import 'package:flutter/material.dart';

class DetallesProducto extends StatelessWidget {
  const DetallesProducto({
    super.key,
    required this.producto,
    required this.perfil,
  });

  final Productos producto;
  final Perfiles perfil;

  @override
  Widget build(BuildContext context) {
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
                      Navigator.pop(context,
                          false); // No se realizó ninguna actualización
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
                      const PopupMenuItem<String>(
                        value: 'Editar',
                        child: Text('Editar'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Eliminar',
                        child: Text('Eliminar'),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ImagenesProducto(producto: producto),
          TopRoundedContainer(
            color: Colors.white,
            child: Column(
              children: [
                ProductoCard(
                  producto: producto,
                  pressOnSeeMore: () {},
                ),
                TopRoundedContainer(
                  color: const Color(0xFFF6F7F9),
                  child: Column(
                    children: [
                      InformacionProducto(producto: producto),
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
              onPressed: () {},
              child: const Text("Añadir a una lista"),
            ),
          ),
        ),
      ),
    );
  }

  void _editarProducto(BuildContext context) async {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditarProducto(producto: producto, perfil: perfil),
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
              onPressed: () {
                // Lógica para eliminar el producto
                // Por ejemplo, puedes llamar a un servicio para eliminar el producto
                ServicioProductos().eliminarProducto(producto.Id);
                Navigator.of(context).pop();
                Navigator.pop(context, true); // Se realizó una actualización
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

class ImagenesProducto extends StatefulWidget {
  const ImagenesProducto({
    super.key,
    required this.producto,
  });

  final Productos producto;

  @override
  _ImagenesProductoState createState() => _ImagenesProductoState();
}

class _ImagenesProductoState extends State<ImagenesProducto> {
  late Future<List<Widget>> _imagenesFuture;

  @override
  void initState() {
    super.initState();
    _imagenesFuture = loadImages();
  }

  Future<List<Widget>> loadImages() async {
    List<Widget> imagenes = [];
    for (String urlImagen in widget.producto.Imagenes) {
      final imageFile = await ServicioProductos().obtenerImagen(urlImagen);
      imagenes.add(Image.file(imageFile));
    }
    return imagenes;
  }

  int selectedImage = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _imagenesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error al cargar las imágenes');
        } else {
          final imagenes = snapshot.data!;
          return Column(
            children: [
              SizedBox(
                width: 238,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: imagenes[selectedImage],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    imagenes.length,
                    (index) => ImagenPequena(
                      esSeleccionada: index == selectedImage,
                      funcion: () {
                        setState(() {
                          selectedImage = index;
                        });
                      },
                      urlImagen: widget.producto.Imagenes[index],
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

class ImagenPequena extends StatelessWidget {
  const ImagenPequena({
    super.key,
    required this.esSeleccionada,
    required this.funcion,
    required this.urlImagen,
  });

  final bool esSeleccionada;
  final VoidCallback funcion;
  final String urlImagen;

  Future<Widget> loadImage() async {
    final imageFile = await ServicioProductos().obtenerImagen(urlImagen);
    return Image.file(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: funcion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFF7643).withOpacity(esSeleccionada ? 1 : 0),
          ),
        ),
        child: FutureBuilder<Widget>(
          future: loadImage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Icon(Icons.error, color: Colors.red);
            } else {
              return snapshot.data!;
            }
          },
        ),
      ),
    );
  }
}

class ProductoCard extends StatelessWidget {
  const ProductoCard({
    super.key,
    required this.producto,
    this.pressOnSeeMore,
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
                (index) => IconoPerfil(
                  idPerfil: producto.Visible[index],
                  esCreador:
                      producto.IdPerfilCreador == producto.Visible[index],
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

  Future<Widget> loadProfileIcon() async {
    Perfiles? perfilAux = await ServicioPerfiles().getPerfilById(idPerfil);
    final imageFile =
        await ServicioPerfiles().obtenerImagen(perfilAux!.FotoPerfil);
    return Image.file(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: loadProfileIcon(),
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
