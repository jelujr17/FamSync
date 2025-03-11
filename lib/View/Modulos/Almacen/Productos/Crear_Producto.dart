import 'dart:io';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Crear/Crear_Imagenes_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Crear/Crear_Nombre_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Crear/Crear_Perfiles_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Crear/Crear_Precio_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Crear/Crear_Tienda_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/Almacen/tiendas.dart';

class CrearProducto extends StatefulWidget {
  final Perfiles perfil;

  const CrearProducto({super.key, required this.perfil});

  @override
  _CrearProductoState createState() => _CrearProductoState();
}

class _CrearProductoState extends State<CrearProducto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tiendaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();

  final List<File> _nuevasImagenes = [];
  final List<int> _perfilSeleccionado = [];
  List<Tiendas> tiendasDisponibles = [];
  String? tiendaSeleccionada;
  List<String> nombresTienda = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  @override
  void initState() {
    super.initState();
    obtenerTiendas();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tiendaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void obtenerTiendas() async {
    tiendasDisponibles =
        await ServiciosTiendas().getTiendas(widget.perfil.UsuarioId);
    obtenerNombresTiendas();
    print("Tiendas disponibles: $tiendasDisponibles");
  }

  void obtenerNombresTiendas() {
    nombresTienda = tiendasDisponibles.map((e) => e.Nombre).toList();
    print("Nombres de tiendas: $nombresTienda");
  }

  Future<void> _crearProducto() async {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final tienda = tiendaSeleccionada;
      final precioTexto = _precioController.text.replaceAll(',', '.');
      final precio = double.tryParse(precioTexto);

      // Agregar prints para depuración
      print("Nombre del producto: $nombre");
      print("Tienda seleccionada: $tienda");
      print("Precio del producto: $precio");
      print("Perfiles seleccionados: $_perfilSeleccionado");

      if (precio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, ingresa un precio válido.')),
        );
        return;
      }

      if (tienda == null || tienda.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una tienda.')),
        );
        return;
      }

      // Imprimir las listas de imágenes para depuración
      print("Nuevas imágenes: ${_nuevasImagenes.map((e) => e.path).toList()}");

      final nuevoProducto = Productos(
        Id: 0,
        Nombre: nombre,
        Tienda: tienda,
        Precio: precio,
        IdPerfilCreador: widget.perfil.Id,
        IdUsuarioCreador: widget.perfil.UsuarioId,
        Imagenes:
            _nuevasImagenes.map((e) => e.path).toList(), // Convertir a String
        Visible: [],
      );

      print("Nuevo producto: $nuevoProducto");

      final exito = await ServicioProductos().registrarProducto(
        nombre,
        _nuevasImagenes, // Enviar lista de archivos
        tienda,
        precio,
        widget.perfil.Id,
        widget.perfil.UsuarioId,
        _perfilSeleccionado,
      );

      if (exito) {
        print("Producto creado con éxito");
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Almacen(perfil: widget.perfil),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Comienza desde la derecha
            const end = Offset.zero; // Termina en la posición final
            const curve = Curves.easeInOut; // Curva de animación

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        )); // Regresa a la página anterior
      } else {
        print("Error al crear el producto");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el producto.')),
        );
      }
    }
  }

  void _eliminarImagenNueva(File imagen) {
    setState(() {
      _nuevasImagenes.remove(imagen);
    });
    print("Imagen eliminada: ${imagen.path}");
  }

  void _nuevasImagenesSeleccionadas(List<File> nuevasImagenes) {
    setState(() {
      _nuevasImagenes.addAll(nuevasImagenes);
    });
    print(
        "Nuevas imágenes seleccionadas: ${nuevasImagenes.map((e) => e.path).toList()}");
  }

  @override
  Widget build(BuildContext context) {
    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(100), // Aumenta la altura del AppBar
          child: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false, // Desactiva el botón por defecto
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(
                  left: 0, top: 100), // Ajusta la posición
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
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Crear Producto",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                FormularioCrearProducto(
                  perfil: widget.perfil,
                  formKey: _formKey,
                  nombreController: _nombreController,
                  precioController: _precioController,
                  dropdownSearchFieldController: _dropdownSearchFieldController,
                  nuevasImagenes: _nuevasImagenes,
                  perfilSeleccionado: _perfilSeleccionado,
                  tiendasDisponibles: tiendasDisponibles,
                  tiendaSeleccionada: tiendaSeleccionada,
                  nombresTienda: nombresTienda,
                  suggestionBoxController: suggestionBoxController,
                  onEliminarImagenNueva: _eliminarImagenNueva,
                  onNuevasImagenesSeleccionadas: _nuevasImagenesSeleccionadas,
                  onGuardar: _crearProducto,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: TopRoundedContainer(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color.fromARGB(255, 255, 195, 67),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                onPressed: _crearProducto,
                child: const Text("Registrar Producto"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FormularioCrearProducto extends StatefulWidget {
  final Perfiles perfil;
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController precioController;
  final TextEditingController dropdownSearchFieldController;
  final List<File> nuevasImagenes;
  final List<int> perfilSeleccionado;
  final List<Tiendas> tiendasDisponibles;
  String? tiendaSeleccionada;
  final List<String> nombresTienda;
  final SuggestionsBoxController suggestionBoxController;
  final Function(File) onEliminarImagenNueva;
  final Function(List<File>) onNuevasImagenesSeleccionadas;
  final Function() onGuardar;

  FormularioCrearProducto({
    super.key,
    required this.perfil,
    required this.formKey,
    required this.nombreController,
    required this.precioController,
    required this.dropdownSearchFieldController,
    required this.nuevasImagenes,
    required this.perfilSeleccionado,
    required this.tiendasDisponibles,
    required this.tiendaSeleccionada,
    required this.nombresTienda,
    required this.suggestionBoxController,
    required this.onEliminarImagenNueva,
    required this.onNuevasImagenesSeleccionadas,
    required this.onGuardar,
  });

  @override
  _FormularioCrearProductoState createState() =>
      _FormularioCrearProductoState();
}

class _FormularioCrearProductoState extends State<FormularioCrearProducto> {
  late Future<List<Perfiles>> futurePerfiles;
  List<Perfiles> perfiles = [];

  @override
  void initState() {
    super.initState();
    futurePerfiles = ServicioPerfiles().getPerfiles(widget.perfil.UsuarioId);
    futurePerfiles.then((data) {
      setState(() {
        perfiles = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ImagenesProductoCrear(
              onEliminarImagenNueva: widget.onEliminarImagenNueva,
              onNuevasImagenesSeleccionadas:
                  widget.onNuevasImagenesSeleccionadas,
            ),
          ),
          const SizedBox(height: 16),
          CampoNombreCrear(
            nombreController: widget.nombreController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, ingresa un nombre válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CampoPrecioCrear(
            precioController: widget.precioController,
            validator: (value) {
              if (value == null || double.parse(value) < 0) {
                return 'Por favor, ingresa un precio válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CampoTiendaCrear(
            validator: (value) =>
                value!.isEmpty ? 'Por favor selecciona una tienda' : null,
            nombresTienda: widget.nombresTienda,
            onTiendaSeleccionada: (tienda) {
              widget.tiendaSeleccionada = tienda;
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Perfiles>>(
            future: futurePerfiles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No hay perfiles disponibles.'));
              }

              List<Perfiles> perfiles = snapshot.data!;

              return CampoPerfilesCrear(
                perfiles: perfiles,
                perfilSeleccionado: widget.perfilSeleccionado,
                onPerfilSeleccionado: (perfilId) {
                  setState(() {
                    if (widget.perfilSeleccionado.contains(perfilId)) {
                      widget.perfilSeleccionado.remove(perfilId);
                    } else {
                      widget.perfilSeleccionado.add(perfilId);
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
