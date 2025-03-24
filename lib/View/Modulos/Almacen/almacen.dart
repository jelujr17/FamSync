import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Almacen/tiendas.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Banner_Listas_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Crear_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Barra_Busqueda_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Recientes_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Tienda_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver/Totales_Productos.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_Producto.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:famsync/components/iconos_SVG.dart';
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

  @override
  void initState() {
    super.initState();
    obtenerListas();
    obtenerTiendas();

    // Inicializar la carga de productos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productoProvider =
          Provider.of<ProductosProvider>(context, listen: false);
      productoProvider.cargarProductos(
          widget.perfil.UsuarioId, widget.perfil.Id);

      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      perfilesProvider.cargarPerfiles(widget.perfil.UsuarioId);
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
          .where((producto) => producto.Nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  void obtenerListas() async {
    try {
      listas = await ServiciosListas()
          .getListas(widget.perfil.UsuarioId, widget.perfil.Id);
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
      tiendas = await ServiciosTiendas().getTiendas(widget.perfil.UsuarioId);
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
      productoProvider.cargarProductos(
          widget.perfil.UsuarioId, widget.perfil.Id);
    }
  }

  List<Tiendas> ObtenerTiendasConProductos(){
    List<Tiendas> tiendasConProductos = [];
    for (var tienda in tiendas){
      for (var producto in productosFiltrados){
        if (producto.Tienda == tienda.Nombre){
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Almacén",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      BarraAlmacen(
                          searchController: _searchController,
                          crearProducto: _crearProducto),
                      ListasBanner(perfil: perfil),
                      productos.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                  child: Text("No hay productos disponibles")),
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
                                ),
                                const SizedBox(height: 20),
                                for (var tienda in ObtenerTiendasConProductos())
                                  ProductosPorTienda(
                                    tienda: tienda,
                                    productos: productosFiltrados
                                        .where((p) => p.Tienda == tienda.Nombre)
                                        .toList(),
                                    onTap: (producto) =>
                                        _navigateToDetallesProducto(producto),
                                  ),
                                const SizedBox(height: 20),
                                ProductosTotales(
                                  productos: productosFiltrados,
                                  onTap: (producto) =>
                                      _navigateToDetallesProducto(producto),
                                ),
                              ],
                            ),
                    ],
                  ),
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

  Color getContrastingTextColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo usando la fórmula de luminancia relativa
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Si el color es oscuro, usar texto blanco; si es claro, usar texto negro
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

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
              color: const Color(0xFF979797).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(svgSrc),
          ),
          if (numOfitem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    "$numOfitem",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: accion,
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
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
  });

  final double width, aspectRetio;
  final Productos producto;
  final VoidCallback onTap;

  @override
  _ProductoCardState createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  Widget? imageWidget;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  void loadImage() async {
    final imageFile =
        await ServicioProductos().obtenerImagen(widget.producto.Imagenes[0]);
    setState(() {
      imageWidget = Image.file(imageFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.02,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF979797).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageWidget ?? const CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.producto.Nombre,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.producto.Precio}€",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF7643),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

