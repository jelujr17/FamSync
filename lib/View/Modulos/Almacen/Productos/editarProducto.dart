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
      tiendaSeleccionada ??= widget.producto.Tienda;
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
    print("Eliminar imagen existente: $imagen");
    setState(() {
      _imagenesExistentes.remove(imagen);
    });
  }

  void _eliminarImagenNueva(File imagen) {
    print("Eliminar imagen nueva: ${imagen.path}");
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
                onPressed: _editarProducto,
                child: const Text("Guardar cambios"),
              ),
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
    required this.imagenesTotales,
    required this.onEliminarImagenExistente,
    required this.onEliminarImagenNueva,
  });

  final List<String> imagenesTotales;
  final Function(String) onEliminarImagenExistente;
  final Function(File) onEliminarImagenNueva;

  @override
  _ImagenesProductoStateEditar createState() => _ImagenesProductoStateEditar();
}

class _ImagenesProductoStateEditar extends State<ImagenesProductoEditar> {
  final List<File> _nuevasImagenes = [];
  List<File> _imagenesCargadas = [];

  @override
  void initState() {
    super.initState();
    _cargarImagenes();
  }

  Future<void> _cargarImagenes() async {
    List<File> imagenes = [];
    for (String urlImagen in widget.imagenesTotales) {
      print(urlImagen); // Para verificar que la URL sea correcta
      final imageFile = await ServicioProductos().obtenerImagen(urlImagen);
      imagenes.add(imageFile);
    }

    setState(() {
      _imagenesCargadas = imagenes;
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      setState(() {
        _nuevasImagenes.addAll(images.map((image) => File(image.path)));
      });
    } catch (e) {
      print("Error al seleccionar imágenes: $e");
    }
  }

  void _eliminarImagenExistente(int index) {
    String urlImagen = widget.imagenesTotales[index];

    // Notificamos al padre para eliminar la imagen del backend si es necesario
    widget.onEliminarImagenExistente(urlImagen);

    setState(() {
      widget.imagenesTotales.removeAt(index);
      _imagenesCargadas.removeAt(index);
    });
  }

  void _eliminarImagenNueva(int index) {
    setState(() {
      _nuevasImagenes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Imágenes existentes
            ...List.generate(widget.imagenesTotales.length, (index) {
              return Stack(
                children: [
                  Image.file(_imagenesCargadas[index], width: 175, height: 175),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => _eliminarImagenExistente(index),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
                ],
              );
            }),
            // Nuevas imágenes seleccionadas
            ...List.generate(_nuevasImagenes.length, (index) {
              return Stack(
                children: [
                  Image.file(_nuevasImagenes[index], width: 175, height: 175),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => _eliminarImagenNueva(index),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        TopRoundedContainer(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color.fromARGB(195, 32, 69, 235),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                onPressed: _pickImage,
                child: const Text("Añadir imágenes"),
              ),
            ),
          ),
        ),
      ],
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
    required this.imagenesExistentes,
    required this.nuevasImagenes,
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
  late Future<List<Perfiles>> futurePerfiles;

  @override
  void initState() {
    super.initState();
    futurePerfiles = ServicioPerfiles().getPerfiles(widget.perfil.UsuarioId);
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
            ),
          ),
          const SizedBox(height: 16),
          CampoNombre(
            nombreController: widget.nombreController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, ingresa un nombre válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CampoPrecio(
            precioController: widget.precioController,
            validator: (value) {
              if (value == null || double.parse(value) < 0) {
                return 'Por favor, ingresa un precio válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CampoTienda(
            dropdownSearchFieldController: widget.dropdownSearchFieldController,
            onSuggestionSelected: (String suggestion) {
              widget.dropdownSearchFieldController.text = suggestion;
              setState(() {
                widget.tiendaSeleccionada = suggestion;
              });
            },
            suggestionBoxController: widget.suggestionBoxController,
            validator: (value) =>
                value!.isEmpty ? 'Por favor selecciona una tienda' : null,
            nombresTienda: widget.nombresTienda,
            onTiendaSeleccionada: (tienda) {
              setState(() {
                widget.tiendaSeleccionada = tienda;
              });
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

              return CampoPerfiles(
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

class CampoNombre extends StatelessWidget {
  final TextEditingController nombreController;
  final String? Function(String?)? validator;

  const CampoNombre({
    super.key,
    required this.nombreController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: nombreController,
        decoration: InputDecoration(
          labelText: 'Nombre del producto',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          hintText: 'Ingresa un nombre para el producto',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon:
              const Icon(Icons.shopping_bag, color: Colors.blue),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Sin borde inicial
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }
}

class CampoPrecio extends StatelessWidget {
  final TextEditingController precioController;
  final String? Function(String?)? validator;

  const CampoPrecio({
    super.key,
    required this.precioController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: precioController,
        keyboardType: const TextInputType.numberWithOptions(
            decimal: true), // Permite decimales
        decoration: InputDecoration(
          labelText: 'Precio',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          hintText: 'Ingresa un precio para el producto',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.euro,
              color: Colors.green.shade700), // Ícono verde más oscuro
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Sin borde inicial
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }
}

class CampoTienda extends StatelessWidget {
  final TextEditingController dropdownSearchFieldController;
  final Function(String) onSuggestionSelected;
  final SuggestionsBoxController suggestionBoxController;
  final String? Function(String?)? validator;
  final List<String> nombresTienda;
  final Function(String) onTiendaSeleccionada;

  const CampoTienda({
    super.key,
    required this.dropdownSearchFieldController,
    required this.onSuggestionSelected,
    required this.suggestionBoxController,
    required this.validator,
    required this.nombresTienda,
    required this.onTiendaSeleccionada,
  });

  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(nombresTienda);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropDownSearchFormField(
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            labelText: 'Selecciona una tienda',
            labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            hintText: 'Busca o selecciona una tienda',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.store, color: Colors.brown),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Sin borde inicial
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.brown, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          controller: dropdownSearchFieldController,
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
        onSuggestionSelected: onSuggestionSelected,
        suggestionsBoxController: suggestionBoxController,
        validator: validator,
        displayAllSuggestionWhenTap: true,
      ),
    );
  }
}

class CampoPerfiles extends StatelessWidget {
  final List<Perfiles> perfiles;
  final List<int> perfilSeleccionado;
  final Function(int) onPerfilSeleccionado;

  const CampoPerfiles({
    super.key,
    required this.perfiles,
    required this.perfilSeleccionado,
    required this.onPerfilSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
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
                            if (perfilSeleccionado.contains(perfil.Id))
                              const Positioned(
                                right: 0,
                                bottom: 0,
                                child: Icon(Icons.check_circle,
                                    color: Colors.green),
                              ),
                          ],
                        );
                      }
                    },
                  )
                : const Icon(Icons.image_not_supported),
            tileColor: perfilSeleccionado.contains(perfil.Id)
                ? Colores.principal.withOpacity(0.2)
                : null,
            onTap: () {
              onPerfilSeleccionado(perfil.Id);
            },
          );
        },
      ),
    );
  }
}
