import 'dart:math';

import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Almacen/tiendas.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/home.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/verProducto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  List<Productos> productos = [];
  List<Productos> productosFiltrados = [];

  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerListas();
    obtenerTiendas();
    obtenerProductos();
    _searchController.addListener(_filterProductos);
  }

  Perfiles get perfil => widget.perfil;

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      productosFiltrados = productos
          .where((producto) => producto.Nombre.toLowerCase().contains(query))
          .toList();
    });
  }

  void obtenerListas() async {
    try {
      listas = await ServiciosListas()
          .getListas(widget.perfil.UsuarioId, widget.perfil.Id);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al obtener las listas: $e';
      });
    }
  }

  void obtenerTiendas() async {
    try {
      tiendas = await ServiciosTiendas().getTiendas(widget.perfil.UsuarioId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al obtener las tiendas: $e';
      });
    }
  }

  void obtenerProductos() async {
    try {
      productos = await ServicioProductos()
          .getProductos(widget.perfil.UsuarioId, widget.perfil.Id);
      productosFiltrados =
          productos; // Inicialmente, mostrar todos los productos
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al obtener los productos: $e';
      });
    }
  }

  void _navigateToDetallesProducto(Productos producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(
          perfil: perfil,
          initialPage: 1, // Índice de la página de Almacen
          child: DetallesProducto(
            producto: producto,
            perfil: perfil,
          ),
        ),
      ),
    );

    if (result == true) {
      obtenerProductos(); // Actualiza la lista de productos
    }
  }

  @override
  Widget build(BuildContext context) {
    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Almacén",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                BarraAlmacen(searchController: _searchController),
                ListasBanner(listas: listas, productos: productos),
                ProductosRecientes(
                  productos: (productosFiltrados.length > 10
                          ? productosFiltrados
                              .sublist(productosFiltrados.length - 10)
                          : productosFiltrados)
                      .reversed
                      .toList(),
                  onTap: _navigateToDetallesProducto,
                ),
                const SizedBox(height: 20),
                for (var tienda in tiendas)
                  ProductosPorTienda(
                    tienda: tienda,
                    productos: productosFiltrados
                        .where((p) => p.Tienda == tienda.Nombre)
                        .toList(),
                    onTap: _navigateToDetallesProducto,
                  ),
                const SizedBox(height: 20),
                ProductosTotales(
                  productos: productosFiltrados,
                  onTap: _navigateToDetallesProducto,
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
  const BarraAlmacen({super.key, required this.searchController});
  final TextEditingController searchController;

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
            svgSrc: filtroIcono,
            numOfitem: 2,

            press: () {},
          ),
          const SizedBox(width: 8),
          IconoContador(
            svgSrc: masIcono,
            press: () {},
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

class BarraBusqueda extends StatelessWidget {
  const BarraBusqueda({super.key, required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          filled: true,
          hintStyle: const TextStyle(color: Color(0xFF757575)),
          fillColor: const Color(0xFF979797).withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintText: "Buscar producto",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class ListasBanner extends StatefulWidget {
  final List<Listas> listas;
  final List<Productos> productos;

  const ListasBanner({
    super.key,
    required this.listas,
    required this.productos,
  });

  @override
  _ListasBannerState createState() => _ListasBannerState();
}

class _ListasBannerState extends State<ListasBanner> {
  void actualizarBanner() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String titulo =
        widget.listas.isNotEmpty ? "Tus listas:" : "No tienes listas aún";
    String contenido = widget.listas.isNotEmpty
        ? widget.listas.map((e) => e.Nombre).join(", ")
        : "¡Crea una nueva!";

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return VentanaListas(
              listas: widget.listas,
              productos: widget.productos,
              actualizarBanner: actualizarBanner,
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3298),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: Colors.white),
            children: [
              TextSpan(text: "$titulo\n"),
              TextSpan(
                text: contenido,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VentanaListas extends StatefulWidget {
  final List<Listas> listas;
  final List<Productos> productos;
  final VoidCallback actualizarBanner;

  const VentanaListas({
    super.key,
    required this.listas,
    required this.productos,
    required this.actualizarBanner,
  });

  @override
  _VentanaListasState createState() => _VentanaListasState();
}

class _VentanaListasState extends State<VentanaListas> {
  Map<int, Widget> imageWidgets = {};

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() {
    for (var lista in widget.listas) {
      for (var productoId in lista.Productos) {
        var producto = widget.productos.firstWhere((p) => p.Id == productoId);
        ServicioProductos()
            .obtenerImagen(producto.Imagenes[0])
            .then((imageFile) {
          setState(() {
            imageWidgets[productoId] =
                Image.file(imageFile, width: 50, height: 50, fit: BoxFit.cover);
          });
        }).catchError((error) {
          setState(() {
            imageWidgets[productoId] =
                const Icon(Icons.error, color: Colors.red);
          });
        });
      }
    }
  }

  void editarLista(Listas lista) async {
    TextEditingController nombreController =
        TextEditingController(text: lista.Nombre);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Editar Lista'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la lista',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin guardar
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Crear una nueva instancia de Listas con el nombre actualizado
                  Listas listaActualizada = Listas(
                    Id: lista.Id,
                    Nombre: nombreController.text,
                    Visible: lista.Visible,
                    Productos: lista.Productos,
                    IdPerfil: lista.IdPerfil,
                    IdUsuario: lista.IdUsuario,
                  );

                  // Reemplazar la instancia antigua en la lista
                  int index = widget.listas.indexWhere((l) => l.Id == lista.Id);
                  if (index != -1) {
                    widget.listas[index] = listaActualizada;
                  }

                  // Guarda los cambios en la base de datos o backend
                  ServiciosListas().actualizarLista(
                    listaActualizada.Id,
                    listaActualizada.Nombre,
                    listaActualizada.Visible,
                    listaActualizada.Productos,
                  );

                  // Actualizar el estado del widget Almacen
                  setState(() {});
                });
                widget.actualizarBanner();
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarProductoDeLista(Listas lista, int productoId) {
    setState(() {
      lista.Productos.remove(productoId);
      ServiciosListas().actualizarLista(
        lista.Id,
        lista.Nombre,
        lista.Visible,
        lista.Productos,
      );
    });
    widget.actualizarBanner();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      title: const Text(
        'Tus Listas',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A3298),
        ),
      ),
      content: widget.listas.isNotEmpty
          ? SizedBox(
              width: double.maxFinite,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: widget.listas.map((lista) {
                    List<Productos> productosFiltrados = widget.productos
                        .where(
                            (producto) => lista.Productos.contains(producto.Id))
                        .toList();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ExpansionTile(
                        title: Text(
                          lista.Nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        leading:
                            const Icon(Icons.list, color: Color(0xFF4A3298)),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.edit, color: Color(0xFF4A3298)),
                          onPressed: () {
                            editarLista(lista); // Abre el formulario de edición
                          },
                        ),
                        children: productosFiltrados.isNotEmpty
                            ? productosFiltrados.map((producto) {
                                return ListTile(
                                  title: Text(producto.Nombre),
                                  leading: imageWidgets[producto.Id] ??
                                      const CircularProgressIndicator(),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      eliminarProductoDeLista(
                                          lista, producto.Id);
                                    },
                                  ),
                                );
                              }).toList()
                            : [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "No hay productos en esta lista",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'No tienes listas aún. ¡Crea una nueva!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para crear una nueva lista
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Crear Lista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3298),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cerrar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3298),
            ),
          ),
        ),
      ],
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

class ProductosRecientes extends StatefulWidget {
  final List<Productos> productos;
  final Function(Productos) onTap;

  const ProductosRecientes({
    super.key,
    required this.productos,
    required this.onTap,
  });

  @override
  State<ProductosRecientes> createState() => _ProductosRecientesState();
}

class _ProductosRecientesState extends State<ProductosRecientes> {
  late int cantidad;
  bool pulsado = true;

  @override
  void initState() {
    super.initState();
    cantidad = min(
        4, widget.productos.length); // Se calcula antes de construir el widget
  }

  @override
  void didUpdateWidget(ProductosRecientes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productos != widget.productos) {
      setState(() {
        cantidad = min(4, widget.productos.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
              titulo: "Recien añadidos",
              accion: () {
                setState(() {
                  if (pulsado) {
                    cantidad = widget.productos.length;
                  } else {
                    cantidad = min(4, widget.productos.length);
                  }
                  pulsado = !pulsado;
                });
              },
              pulsado: pulsado),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cantidad,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return ProductoCard(
                producto: widget.productos[index],
                onTap: () => widget.onTap(widget.productos[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProductosPorTienda extends StatefulWidget {
  final Tiendas tienda;
  final List<Productos> productos;
  final Function(Productos) onTap;

  const ProductosPorTienda({
    super.key,
    required this.tienda,
    required this.productos,
    required this.onTap,
  });

  @override
  State<ProductosPorTienda> createState() => _ProductosPorTiendaState();
}

class _ProductosPorTiendaState extends State<ProductosPorTienda> {
  late int cantidad;
  bool pulsado = true;

  @override
  void initState() {
    super.initState();
    cantidad = min(
        4, widget.productos.length); // Se calcula antes de construir el widget
  }

  @override
  void didUpdateWidget(ProductosPorTienda oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productos != widget.productos) {
      setState(() {
        cantidad = min(4, widget.productos.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
              titulo: widget.tienda.Nombre,
              accion: () {
                setState(() {
                  if (pulsado) {
                    cantidad = widget.productos.length;
                  } else {
                    cantidad = min(4, widget.productos.length);
                  }
                  pulsado = !pulsado;
                });
              },
              pulsado: pulsado),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cantidad,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return ProductoCard(
                producto: widget.productos[index],
                onTap: () => widget.onTap(widget.productos[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProductosTotales extends StatefulWidget {
  final List<Productos> productos;
  final Function(Productos) onTap;

  const ProductosTotales({
    super.key,
    required this.productos,
    required this.onTap,
  });

  @override
  State<ProductosTotales> createState() => _ProductosTotalesState();
}

class _ProductosTotalesState extends State<ProductosTotales> {
  late int cantidad;
  bool pulsado = true;

  @override
  void initState() {
    super.initState();
    cantidad = min(
        4, widget.productos.length); // Se calcula antes de construir el widget
  }

  @override
  void didUpdateWidget(ProductosTotales oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productos != widget.productos) {
      setState(() {
        cantidad = min(4, widget.productos.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
              titulo: "Todos los Productos",
              accion: () {
                setState(() {
                  if (pulsado) {
                    cantidad = widget.productos.length;
                  } else {
                    cantidad = min(4, widget.productos.length);
                  }
                  pulsado = !pulsado;
                });
              },
              pulsado: pulsado),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cantidad,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return ProductoCard(
                producto: widget.productos[index],
                onTap: () => widget.onTap(widget.productos[index]),
              );
            },
          ),
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

const heartIcon =
    '''<svg width="18" height="16" viewBox="0 0 18 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M16.5266 8.61383L9.27142 15.8877C9.12207 16.0374 8.87889 16.0374 8.72858 15.8877L1.47343 8.61383C0.523696 7.66069 0 6.39366 0 5.04505C0 3.69644 0.523696 2.42942 1.47343 1.47627C2.45572 0.492411 3.74438 0 5.03399 0C6.3236 0 7.61225 0.492411 8.59454 1.47627C8.81857 1.70088 9.18143 1.70088 9.40641 1.47627C11.3691 -0.491451 14.5629 -0.491451 16.5266 1.47627C17.4763 2.42846 18 3.69548 18 5.04505C18 6.39366 17.4763 7.66165 16.5266 8.61383Z" fill="#DBDEE4"/>
</svg>
''';

const masIcono =
    '''<svg width="22" height="22" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M12 10V2C12 1.44772 11.5523 1 11 1C10.4477 1 10 1.44772 10 2V10H2C1.44772 10 1 10.4477 1 11C1 11.5523 1.44772 12 2 12H10V20C10 20.5523 10.4477 21 11 21C11.5523 21 12 20.5523 12 20V12H20C20.5523 12 21 11.5523 21 11C21 10.4477 20.5523 10 20 10H12Z" fill="#7C7C7C"/>
</svg>
''';

const String description =
    "Wireless Controller for PS4™ gives you what you want in your gaming from over precision control your games to sharing …";

const corritoIcono =
    '''<svg width="22" height="18" viewBox="0 0 22 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M18.4524 16.6669C18.4524 17.403 17.8608 18 17.1302 18C16.3985 18 15.807 17.403 15.807 16.6669C15.807 15.9308 16.3985 15.3337 17.1302 15.3337C17.8608 15.3337 18.4524 15.9308 18.4524 16.6669ZM11.9556 16.6669C11.9556 17.403 11.3631 18 10.6324 18C9.90181 18 9.30921 17.403 9.30921 16.6669C9.30921 15.9308 9.90181 15.3337 10.6324 15.3337C11.3631 15.3337 11.9556 15.9308 11.9556 16.6669ZM20.7325 5.7508L18.9547 11.0865C18.6413 12.0275 17.7685 12.6591 16.7846 12.6591H10.512C9.53753 12.6591 8.66784 12.0369 8.34923 11.1095L6.30162 5.17154H20.3194C20.4616 5.17154 20.5903 5.23741 20.6733 5.35347C20.7563 5.47058 20.7771 5.61487 20.7325 5.7508ZM21.6831 4.62051C21.3697 4.18031 20.858 3.91682 20.3194 3.91682H5.86885L5.0002 1.40529C4.70961 0.564624 3.92087 0 3.03769 0H0.621652C0.278135 0 0 0.281266 0 0.62736C0 0.974499 0.278135 1.25472 0.621652 1.25472H3.03769C3.39158 1.25472 3.70812 1.48161 3.82435 1.8183L4.83311 4.73657C4.83622 4.74598 4.83934 4.75434 4.84245 4.76375L7.17339 11.5215C7.66531 12.9518 9.00721 13.9138 10.512 13.9138H16.7846C18.304 13.9138 19.6511 12.9383 20.1347 11.4859L21.9135 6.14917C22.0847 5.63369 21.9986 5.06175 21.6831 4.62051Z" fill="#7C7C7C"/>
</svg>
''';

const filtroIcono = '''
<svg width="22" height="22" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M2 4C2 3.44772 2.44772 3 3 3H19C19.5523 3 20 3.44772 20 4C20 4.55228 19.5523 5 19 5H3C2.44772 5 2 4.55228 2 4ZM5 10C5 9.44772 5.44772 9 6 9H16C16.5523 9 17 9.4477 17 10C17 10.5523 16.5523 11 16 11H6C5.44772 11 5 10.5523 5 10ZM9 16C9 15.4477 9.44772 15 10 15H12C12.5523 15 13 15.4477 13 16C13 16.5523 12.5523 17 12 17H10C9.44772 17 9 16.5523 9 16Z" fill="#7C7C7C"/>
</svg>
''';
