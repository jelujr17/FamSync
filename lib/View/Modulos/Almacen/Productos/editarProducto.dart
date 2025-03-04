import 'dart:io';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/verProducto.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';
import 'package:image_picker/image_picker.dart';
import 'package:famsync/Model/Almacen/tiendas.dart';

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
  List<int> _perfilSeleccionado = [];
  List<Tiendas> tiendasDisponibles = [];
  String? tiendaSeleccionada;
  List<String> nombresTienda = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  @override
  void initState() {
    super.initState();

    _nombreController = TextEditingController(text: widget.producto.Nombre);
    _tiendaController = TextEditingController(text: widget.producto.Tienda);
    _precioController =
        TextEditingController(text: widget.producto.Precio.toString());
    _perfilSeleccionado = widget.producto.Visible;
    _imagenesExistentes = List.from(widget.producto.Imagenes);
    tiendaSeleccionada = widget.producto.Tienda;

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
    setState(() {
      tiendaSeleccionada = widget.producto.Tienda;
    });
  }

  void obtenerNombresTiendas() {
    nombresTienda = tiendasDisponibles.map((e) => e.Nombre).toList();
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

      final nuevoProducto = Productos(
        Id: widget.producto.Id,
        Nombre: nombre,
        Tienda: tienda!,
        Precio: precio,
        IdPerfilCreador: widget.producto.IdPerfilCreador,
        IdUsuarioCreador: widget.producto.IdUsuarioCreador,
        Imagenes: [
          ..._imagenesExistentes, // Imágenes existentes (actualizadas)
          ..._nuevasImagenes.map((e) => e.path), // Nuevas imágenes
        ],
        Visible: widget.producto.Visible,
      );

      List<File> fotosNuevas = [];
      if (_imagenesExistentes.isNotEmpty) {
        for (int i = 0; i < _imagenesExistentes.length; i++) {
          fotosNuevas.add(File(
              'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\${_imagenesExistentes[i]}'));
        }
      }
      if (_nuevasImagenes.isNotEmpty) {
        for (int i = 0; i < _nuevasImagenes.length; i++) {
          fotosNuevas.add(_nuevasImagenes[i]);
        }
      }

      final exito = await ServicioProductos().actualizarProducto(
          widget.producto.Id,
          nombre,
          fotosNuevas,
          tienda,
          precio,
          nuevoProducto.Visible);

      if (exito) {
        Productos? producto =
            await ServicioProductos().getProductoById(widget.producto.Id);

        Navigator.of(context).push(PageRouteBuilder(
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
                  onGuardar: _editarProducto,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImagenesProductoEditar extends StatefulWidget {
  const ImagenesProductoEditar({
    super.key,
    required this.producto,
    required this.onEliminarImagenExistente,
    required this.onEliminarImagenNueva,
  });

  final Productos producto;
  final Function(String) onEliminarImagenExistente;
  final Function(File) onEliminarImagenNueva;

  @override
  _ImagenesProductoStateEditar createState() => _ImagenesProductoStateEditar();
}

class _ImagenesProductoStateEditar extends State<ImagenesProductoEditar> {
  late Future<List<Widget>> _imagenesFuture;
  List<File> _nuevasImagenes = [];

  @override
  void initState() {
    super.initState();
    _imagenesFuture = loadImages();
  }

  Future<List<Widget>> loadImages() async {
    List<Widget> imagenes = [];
    for (String urlImagen in widget.producto.Imagenes) {
      final imageFile = await ServicioProductos().obtenerImagen(urlImagen);
      imagenes.add(
        Stack(
          children: [
            Image.file(imageFile, width: 100, height: 100, fit: BoxFit.cover),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => widget.onEliminarImagenExistente(urlImagen),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
    return imagenes;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    setState(() {
      _nuevasImagenes = images.map((image) => File(image.path)).toList();
    });
  }

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
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...imagenes,
                  ..._nuevasImagenes.map(
                    (imagen) => Stack(
                      children: [
                        Image.file(imagen,
                            width: 100, height: 100, fit: BoxFit.cover),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => widget.onEliminarImagenNueva(imagen),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Añadir Imágenes'),
              ),
            ],
          );
        }
      },
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
  final List<File> nuevasImagenes;
  final List<String> imagenesExistentes;
  final List<int> perfilSeleccionado;
  final List<Tiendas> tiendasDisponibles;
  String? tiendaSeleccionada;
  final List<String> nombresTienda;
  final SuggestionsBoxController suggestionBoxController;
  final Function(String) onEliminarImagenExistente;
  final Function(File) onEliminarImagenNueva;
  final Function() onGuardar;

  FormularioEditarProducto({
    super.key,
    required this.producto,
    required this.perfil,
    required this.formKey,
    required this.nombreController,
    required this.precioController,
    required this.dropdownSearchFieldController,
    required this.nuevasImagenes,
    required this.imagenesExistentes,
    required this.perfilSeleccionado,
    required this.tiendasDisponibles,
    required this.tiendaSeleccionada,
    required this.nombresTienda,
    required this.suggestionBoxController,
    required this.onEliminarImagenExistente,
    required this.onEliminarImagenNueva,
    required this.onGuardar,
  });

  @override
  _FormularioEditarProductoState createState() =>
      _FormularioEditarProductoState();
}

class _FormularioEditarProductoState extends State<FormularioEditarProducto> {
  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(widget.nombresTienda);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          ImagenesProductoEditar(
            producto: widget.producto,
            onEliminarImagenExistente: widget.onEliminarImagenExistente,
            onEliminarImagenNueva: widget.onEliminarImagenNueva,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un nombre.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.precioController,
            decoration: const InputDecoration(labelText: 'Precio'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un precio.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DropDownSearchFormField(
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                labelText: widget.tiendaSeleccionada ?? 'Selecciona una tienda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.store),
              ),
              controller: widget.dropdownSearchFieldController,
            ),
            suggestionsCallback: (pattern) {
              return getSuggestions(pattern);
            },
            itemBuilder: (context, String suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            itemSeparatorBuilder: (context, index) {
              return const Divider();
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (String suggestion) {
              widget.dropdownSearchFieldController.text = suggestion;
              setState(() {
                widget.tiendaSeleccionada = suggestion;
              });
            },
            suggestionsBoxController: widget.suggestionBoxController,
            validator: (value) =>
                value!.isEmpty ? 'Por favor selecciona una tienda' : null,
            displayAllSuggestionWhenTap: true,
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Perfiles>>(
            future: ServicioPerfiles().getPerfiles(widget.perfil.UsuarioId),
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

              return ListView.builder(
                shrinkWrap: true,
                itemCount: perfiles.length > 1
                    ? perfiles.length - 1
                    : 0, // Restamos 1 si hay más de un perfil
                itemBuilder: (context, index) {
                  final perfil = perfiles[index + 1];
                
                  return ListTile(
                    title: Text(
                      perfil.Nombre,
                      style: const TextStyle(
                        color: Colores.texto,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    leading: perfil.FotoPerfil.isNotEmpty
                        ? FutureBuilder<File>(
                            future: ServicioPerfiles().obtenerImagen(perfil.FotoPerfil),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else if (!snapshot.hasData) {
                                return const Icon(Icons.image_not_supported);
                              } else {
                                return Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: FileImage(snapshot.data!),
                                    ),
                                    if (widget.perfilSeleccionado.contains(perfil.Id))
                                      const Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Icon(Icons.check_circle, color: Colors.green),
                                      ),
                                  ],
                                );
                              }
                            },
                          )
                        : const Icon(Icons.image_not_supported),
                    tileColor: widget.perfilSeleccionado.contains(perfil.Id)
                        ? Colores.principal.withOpacity(0.2)
                        : null,
                    onTap: () {
                      setState(() {
                        if (widget.perfilSeleccionado.contains(perfil.Id)) {
                          widget.perfilSeleccionado.remove(perfil.Id);
                        } else {
                          widget.perfilSeleccionado.add(perfil.Id);
                        }
                      });
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onGuardar,
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }
}
