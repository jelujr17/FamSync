import 'package:famsync/Model/Almacen/Listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Almacen/Tiendas.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Banner_Listas_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Anadir_Lista.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Lista.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Crear_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Barra_Busqueda_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Recientes_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Tienda_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Totales_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_Producto.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/components/iconos_SVG.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PerfilProvider extends InheritedWidget {
  final Perfiles perfil;

  const PerfilProvider({
    super.key,
    required this.perfil,
    required super.child,
  });

  static PerfilProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PerfilProvider>();
  }

  @override
  bool updateShouldNotify(PerfilProvider oldWidget) {
    return perfil != oldWidget.perfil;
  }
}

class Almacen extends StatefulWidget {
  const Almacen({super.key, required this.perfil});
  final Perfiles perfil;

  @override
  AlmacenState createState() => AlmacenState();
}

class AlmacenState extends State<Almacen> {
  List<Listas> listas = [];
  List<Tiendas> tiendas = [];
  List<Productos> productosFiltrados = [];

  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    obtenerListas();
    obtenerTiendas();

    // Inicializar la carga de productos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productoProvider =
          Provider.of<ProductosProvider>(context, listen: false);
      productoProvider.cargarProductos(user!.uid, widget.perfil.PerfilID);

      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      perfilesProvider.cargarPerfiles(user!.uid);
    });
    _searchController.addListener(_filterProductos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Perfiles get perfil => widget.perfil;

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    final productoProvider =
        Provider.of<ProductosProvider>(context, listen: false);

    setState(() {
      productosFiltrados = productoProvider.productos
          .where((producto) => producto.nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  void obtenerListas() async {
    try {
      listas =
          await ServiciosListas().getListas(user!.uid, widget.perfil.PerfilID);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al obtener las listas: $e';
        });
      }
    }
  }

  void obtenerTiendas() async {
    try {
      tiendas = await ServiciosTiendas().getTiendas(user!.uid);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al obtener las tiendas: $e';
        });
      }
    }
  }

  void _navigateToDetallesProducto(Productos producto) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetallesProducto(
          perfil: widget.perfil,
          producto: producto,
        ),
      ),
    );

    if (result == true) {
      // Recargar la lista de productos si se realizó una actualización
      final productoProvider =
          Provider.of<ProductosProvider>(context, listen: false);
      productoProvider.cargarProductos(user!.uid, widget.perfil.PerfilID);
    }
  }

  List<Tiendas> ObtenerTiendasConProductos() {
    List<Tiendas> tiendasConProductos = [];
    for (var tienda in tiendas) {
      for (var producto in productosFiltrados) {
        if (producto.TiendaID == tienda.TiendaID) {
          tiendasConProductos.add(tienda);
          break;
        }
      }
    }
    return tiendasConProductos;
  }

  void _crearProducto(BuildContext context) async {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearProducto(perfil: perfil),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Se realizó una actualización
    }
  }

  @override
  Widget build(BuildContext context) {
    final productoProvider = Provider.of<ProductosProvider>(context);
    final productos = productoProvider.productos;

    // Actualizar productos filtrados cuando cambian los productos
    if (_searchController.text.isEmpty) {
      productosFiltrados = productos;
    } else {
      _filterProductos();
    }

    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Almacén",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colores.texto, fontWeight: FontWeight.bold),
                ),
              ),
              BarraAlmacen(
                searchController: _searchController,
                crearProducto: _crearProducto,
              ),
              ListasBanner(perfil: perfil),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      productos.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  "No hay productos disponibles",
                                  style: TextStyle(color: Colores.texto),
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProductosRecientes(
                                  productos: (productosFiltrados.length > 10
                                          ? productosFiltrados.sublist(
                                              productosFiltrados.length - 10)
                                          : productosFiltrados)
                                      .reversed
                                      .toList(),
                                  onTap: (producto) =>
                                      _navigateToDetallesProducto(producto),
                                  perfil: perfil,
                                ),
                                const SizedBox(height: 20),
                                for (var tienda in ObtenerTiendasConProductos())
                                  ProductosPorTienda(
                                    tienda: tienda,
                                    productos: productosFiltrados
                                        .where((p) =>
                                            p.TiendaID == tienda.TiendaID)
                                        .toList(),
                                    onTap: (producto) =>
                                        _navigateToDetallesProducto(producto),
                                    perfil: widget.perfil,
                                  ),
                                const SizedBox(height: 20),
                                ProductosTotales(
                                  productos: productosFiltrados,
                                  onTap: (producto) =>
                                      _navigateToDetallesProducto(producto),
                                  perfil: perfil,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarraAlmacen extends StatelessWidget {
  const BarraAlmacen(
      {super.key, required this.searchController, required this.crearProducto});
  final TextEditingController searchController;
  final Function(BuildContext) crearProducto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: BarraBusqueda(
            searchController: searchController,
          )),
          const SizedBox(width: 16),
          IconoContador(
            // numOfitem: 3,
            svgSrc: Iconos_SVG.filtroIcono,
            numOfitem: 2,

            press: () {},
          ),
          const SizedBox(width: 8),
          IconoContador(
            svgSrc: Iconos_SVG.masIcono,
            press: () {
              crearProducto(context);
            },
          ),
        ],
      ),
    );
  }
}

class IconoContador extends StatelessWidget {
  const IconoContador({
    super.key,
    required this.svgSrc,
    this.numOfitem = 0,
    required this.press,
  });

  final String svgSrc;
  final int numOfitem;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colores.fondoAux,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(
              svgSrc,
              color: Colores.texto,
            ),
          ),
          if (numOfitem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: Colores.texto,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colores.fondoAux),
                ),
                child: Center(
                  child: Text(
                    "$numOfitem",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colores.fondoAux,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.titulo,
    required this.accion,
    required this.pulsado,
  });

  final String titulo;
  final GestureTapCallback accion;
  final bool pulsado;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colores.texto,
          ),
        ),
        TextButton(
          onPressed: accion,
          style: TextButton.styleFrom(foregroundColor: Colores.texto),
          child: pulsado ? Text("Ver más") : Text("Ver menos"),
        ),
      ],
    );
  }
}

class ProductoCard extends StatefulWidget {
  const ProductoCard({
    super.key,
    this.width = 0,
    this.aspectRetio = 1.02,
    required this.producto,
    required this.onTap,
    required this.perfil,
  });

  final double width, aspectRetio;
  final Productos producto;
  final VoidCallback onTap;
  final Perfiles perfil;

  @override
  _ProductoCardState createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  Widget? imageWidget;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  void loadImage() async {
    try {
      final imageFile = await ServicioProductos()
          .getArchivosImagenesProducto(user!.uid, widget.producto.ProductoID);

      // Verifica si el archivo tiene contenido válido
      if (imageFile == null || imageFile.isEmpty) {
        throw Exception('El archivo de imagen está vacío o es nulo');
      }

      setState(() {
        imageWidget = Image.file(
          imageFile[0],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            );
          },
        );
      });
    } catch (e) {
      print('Error al cargar la imagen: $e');
      setState(() {
        // Muestra un marcador de posición en caso de error
        imageWidget = Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey,
            ),
          ),
        );
      });
    }
  }

  void actualizarBanner() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colores.fondoAux,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            AspectRatio(
              aspectRatio: widget.aspectRetio,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageWidget ??
                    Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 8),

            // nombre del producto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.producto.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colores.texto,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // precio y detalles adicionales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.producto.precio}€",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF7643),
                    ),
                  ),
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colores.texto,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Spacer(),
            // Botón para añadir a la lista
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12), // Espaciado lateral
              child: SizedBox(
                width: double.infinity, // Ocupa todo el ancho disponible
                child: ElevatedButton(
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
                              return Container(
                                padding: const EdgeInsets.all(20),
                                child: VentanaAnadirListas(
                                  actualizarBanner: actualizarBanner,
                                  producto: widget.producto,
                                ),
                              );
                            },
                          );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.texto,
                    foregroundColor: Colores.fondoAux,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Añadir a la lista",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
