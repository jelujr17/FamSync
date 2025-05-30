import 'dart:io';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Editar/Editar_Imagenes_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Editar/Editar_Nombre_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Editar/Editar_Perfiles_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Editar/Editar_Precio_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Editar/Editar_Tienda_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_Producto.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Model/Almacen/Tiendas.dart';

class EditarProducto extends StatefulWidget {
  final Productos producto;
  final Perfiles perfil;

  const EditarProducto(
      {super.key, required this.producto, required this.perfil});

  @override
  _EditarProductoState createState() => _EditarProductoState();
}

class _EditarProductoState extends State<EditarProducto> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _tiendaController;
  late TextEditingController _precioController;
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();

  final List<File> _nuevasImagenes = []; // Lista para almacenar nuevas imágenes
  List<String> _imagenesExistentes =
      []; // Lista para almacenar imágenes existentes
  List<String> _perfilSeleccionado = [];
  List<Tiendas> tiendasDisponibles = [];
  String? tiendaSeleccionada;
  List<String> nombresTienda = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(text: widget.producto.nombre);
    _tiendaController = TextEditingController(text: widget.producto.TiendaID);
    _precioController =
        TextEditingController(text: widget.producto.precio.toString());
    _perfilSeleccionado = widget.producto.visible;
    _imagenesExistentes = List.from(widget.producto.imagenes);
    tiendaSeleccionada = widget.producto.TiendaID;

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
    tiendasDisponibles = await ServiciosTiendas().getTiendas(user!.uid);
    obtenerNombresTiendas();
    setState(() {
      tiendaSeleccionada ??= widget.producto.TiendaID;
    });
  }

  void obtenerNombresTiendas() {
    nombresTienda = tiendasDisponibles.map((e) => e.nombre).toList();
  }

  Future<void> _editarProducto() async {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final tienda = tiendaSeleccionada;
      final precio = double.tryParse(_precioController.text);

      if (precio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, ingresa un precio válido.')),
        );
        return;
      }
      print("Tienda: $tienda");

      // Combinar las imágenes existentes y nuevas en una lista de archivos
      final List<File> imagenesCompletas = [
        ..._imagenesExistentes.map((e) => File(e)), // Convertir a File
        ..._nuevasImagenes,
      ];

      final nuevoProducto = Productos(
        ProductoID: widget.producto.ProductoID,
        nombre: nombre,
        TiendaID: tienda!,
        precio: precio,
        PerfilID: widget.producto.PerfilID,
        imagenes:
            imagenesCompletas.map((e) => e.path).toList(), // Convertir a String
        visible: widget.producto.visible,
      );

      final exito = await ServicioProductos().actualizarProducto(
          user!.uid,
          widget.producto.ProductoID,
          nombre,
          _imagenesExistentes,
          _nuevasImagenes, // Enviar lista de archivos
          tienda,
          precio,
          nuevoProducto.visible,
          widget.producto);

      if (exito) {
        Productos? producto = await ServicioProductos()
            .getProductoById(user!.uid, widget.producto.ProductoID);

        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DetallesProducto(producto: producto!, perfil: widget.perfil),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el producto.')),
        );
      }
    }
  }

  void _eliminarImagenExistente(String imagen) {
    setState(() {
      _imagenesExistentes.remove(imagen);
    });
  }

  void _eliminarImagenNueva(File imagen) {
    setState(() {
      _nuevasImagenes.remove(imagen);
    });
  }

  void _nuevasImagenesSeleccionadas(List<File> nuevasImagenes) {
    setState(() {
      _nuevasImagenes.addAll(nuevasImagenes);
    });
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
                    "Editar Producto",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                FormularioEditarProducto(
                  producto: widget.producto,
                  perfil: widget.perfil,
                  formKey: _formKey,
                  nombreController: _nombreController,
                  precioController: _precioController,
                  dropdownSearchFieldController: _dropdownSearchFieldController,
                  nuevasImagenes: _nuevasImagenes,
                  imagenesExistentes: _imagenesExistentes,
                  perfilSeleccionado: _perfilSeleccionado,
                  tiendasDisponibles: tiendasDisponibles,
                  tiendaSeleccionada: tiendaSeleccionada,
                  nombresTienda: nombresTienda,
                  suggestionBoxController: suggestionBoxController,
                  onEliminarImagenExistente: _eliminarImagenExistente,
                  onEliminarImagenNueva: _eliminarImagenNueva,
                  onNuevasImagenesSeleccionadas: _nuevasImagenesSeleccionadas,
                  onGuardar: _editarProducto,
                  onTiendaSeleccionada: (String? tienda) {
                    setState(() {
                      tiendaSeleccionada = tienda;
                    });
                  },
                ),
              ],
            ),
          ),
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
                  foregroundColor: Colores.fondo,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                onPressed: _editarProducto,
                child: Text("Guardar Cambios",
                    style: TextStyle(color: Colores.fondoAux)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FormularioEditarProducto extends StatefulWidget {
  final Productos producto;
  final Perfiles perfil;
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController precioController;
  final TextEditingController dropdownSearchFieldController;
  final List<String> imagenesExistentes;
  final List<File> nuevasImagenes;
  final List<String> perfilSeleccionado;
  final List<Tiendas> tiendasDisponibles;
  String? tiendaSeleccionada;
  final List<String> nombresTienda;
  final SuggestionsBoxController suggestionBoxController;
  final Function(String) onEliminarImagenExistente;
  final Function(File) onEliminarImagenNueva;
  final Function(List<File>) onNuevasImagenesSeleccionadas;
  final Function() onGuardar;
  final Function(String) onTiendaSeleccionada;

  FormularioEditarProducto({
    super.key,
    required this.producto,
    required this.perfil,
    required this.formKey,
    required this.nombreController,
    required this.precioController,
    required this.dropdownSearchFieldController,
    required this.imagenesExistentes,
    required this.nuevasImagenes,
    required this.perfilSeleccionado,
    required this.tiendasDisponibles,
    required this.tiendaSeleccionada,
    required this.nombresTienda,
    required this.suggestionBoxController,
    required this.onEliminarImagenExistente,
    required this.onEliminarImagenNueva,
    required this.onNuevasImagenesSeleccionadas,
    required this.onGuardar,
    required this.onTiendaSeleccionada,
  });

  @override
  _FormularioEditarProductoState createState() =>
      _FormularioEditarProductoState();
}

class _FormularioEditarProductoState extends State<FormularioEditarProducto> {
  late Future<List<Perfiles>> futurePerfiles;
  List<Perfiles> perfiles = [];
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    futurePerfiles = ServicioPerfiles().getPerfiles(user!.uid);
    futurePerfiles.then((data) {
      setState(() {
        perfiles = data;
        // Eliminar el perfil del widget de la lista de perfiles disponibles
        perfiles
            .removeWhere((perfil) => perfil.PerfilID == widget.perfil.PerfilID);
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
            child: ImagenesProductoEditar(
              imagenesTotales: widget.imagenesExistentes,
              onEliminarImagenExistente: widget.onEliminarImagenExistente,
              onEliminarImagenNueva: widget.onEliminarImagenNueva,
              onNuevasImagenesSeleccionadas:
                  widget.onNuevasImagenesSeleccionadas,
              producto: widget.producto,
            ),
          ),
          const SizedBox(height: 16),
          CampoNombreEditar(
            nombreController: widget.nombreController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, ingresa un nombre válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CampoPrecioEditar(
            precioController: widget.precioController,
            validator: (value) {
              if (value == null || double.parse(value) < 0) {
                return 'Por favor, ingresa un precio válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CampoTiendaEditar(
            validator: (value) =>
                value!.isEmpty ? 'Por favor selecciona una tienda' : null,
            nombresTienda: widget.nombresTienda,
            onTiendaSeleccionada: (tienda) {
              widget.onTiendaSeleccionada(tienda);
            },
            producto: widget.producto,
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

              return CampoPerfilesEditar(
                perfiles: perfiles,
                perfilSeleccionado: widget.perfilSeleccionado,
                onPerfilSeleccionado: (PerfilID) {
                  setState(() {
                    if (widget.perfilSeleccionado.contains(PerfilID)) {
                      widget.perfilSeleccionado.remove(PerfilID);
                    } else {
                      widget.perfilSeleccionado.add(PerfilID);
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
