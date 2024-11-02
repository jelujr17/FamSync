import 'dart:io';
import 'package:famsync/View/Modulos/Almacen/Productos/verProducto.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';
import 'package:image_picker/image_picker.dart';

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
  List<File> _nuevasImagenes = []; // Lista para almacenar nuevas imágenes
  List<String> _imagenesExistentes =
      []; // Lista para almacenar imágenes existentes
  List<int> _perfilSeleccionado = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.Nombre);
    _tiendaController = TextEditingController(text: widget.producto.Tienda);
    _precioController =
        TextEditingController(text: widget.producto.Precio.toString());
    _perfilSeleccionado = widget.producto.Visible;
    _imagenesExistentes = List.from(widget.producto.Imagenes);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tiendaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images =
        await picker.pickMultiImage(); // Selección múltiple de imágenes
    setState(() {
      _nuevasImagenes = images.map((image) => File(image.path)).toList();
    });
  }

  Future<void> _editarProducto() async {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final tienda = _tiendaController.text;
      final precio = double.tryParse(_precioController.text);

      if (precio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, ingresa un precio válido.')),
        );
        return;
      }

      // Aquí podrías subir las imágenes nuevas al servidor
      // y obtener las URLs de las nuevas imágenes

      final nuevoProducto = Productos(
        Id: widget.producto.Id,
        Nombre: nombre,
        Tienda: tienda,
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
      print("++++++++++++++++++++++++++++++++++++++++++++++");
      print(nuevoProducto);
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
          pageBuilder: (context, animation, secondaryAnimation) => VerProducto(
            producto: producto!,
            perfil: widget.perfil,
          ),
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colores.principal,
          title: const Text('Editar Producto'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Sección para mostrar imágenes existentes y nuevas
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Mostrar imágenes existentes
                    ..._imagenesExistentes.map(
                      (imagen) => Stack(
                        children: [
                          Image.file(
                            File(
                                'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\$imagen'),
                            width: 175,
                            height: 175,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _eliminarImagenExistente(imagen),
                              child:
                                  const Icon(Icons.delete, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mostrar nuevas imágenes seleccionadas
                    ..._nuevasImagenes.map(
                      (imagen) => Stack(
                        children: [
                          Image.file(imagen, width: 100, height: 100),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _eliminarImagenNueva(imagen),
                              child:
                                  const Icon(Icons.delete, color: Colors.red),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tiendaController,
                  decoration: const InputDecoration(labelText: 'Tienda'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una tienda.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _precioController,
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
                // Mantén el FutureBuilder para los perfiles
                Expanded(
                  child: FutureBuilder<List<Perfiles>>(
                    future:
                        ServicioPerfiles().getPerfiles(widget.perfil.UsuarioId),
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
                          final perfil = perfiles[index +
                              1]; // Obtenemos el perfil a partir del segundo

                          return ListTile(
                            title: Text(
                              perfil.Nombre,
                              style: const TextStyle(
                                color: Colores.texto,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            leading: perfil.FotoPerfil.isNotEmpty &&
                                    File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')
                                        .existsSync()
                                ? Stack(
                                    children: [
                                      CircleAvatar(
                                        radius:
                                            25, // Puedes ajustar el radio según tu necesidad
                                        backgroundImage: FileImage(File(
                                            'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')),
                                      ),
                                      if (_perfilSeleccionado
                                          .contains(perfil.Id))
                                        const Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Icon(Icons.check_circle,
                                              color: Colors.green),
                                        ),
                                    ],
                                  )
                                : const Icon(Icons.image_not_supported),
                            tileColor: _perfilSeleccionado.contains(perfil.Id)
                                ? Colores.principal.withOpacity(0.2)
                                : null,
                            onTap: () {
                              setState(() {
                                if (_perfilSeleccionado.contains(perfil.Id)) {
                                  _perfilSeleccionado.remove(perfil.Id);
                                } else {
                                  _perfilSeleccionado.add(perfil.Id);
                                }
                              });
                              print(
                                  'Perfil seleccionado: $_perfilSeleccionado');
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _editarProducto,
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ));
  }
}
