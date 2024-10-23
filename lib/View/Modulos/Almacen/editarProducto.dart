// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:famsync/Model/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';

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
  File? _nuevaImagen;
  List<int> _perfilSeleccionado = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.Nombre);
    _tiendaController = TextEditingController(text: widget.producto.Tienda);
    _precioController =
        TextEditingController(text: widget.producto.Precio.toString());
    _perfilSeleccionado = widget.producto.Visible;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tiendaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Implementa tu lógica para seleccionar una nueva imagen
    // Por ejemplo, usando la biblioteca image_picker
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

      final nuevoProducto = Productos(
          Id: widget.producto.Id,
          Nombre: nombre,
          Tienda: tienda,
          Precio: precio,
          IdPerfilCreador: widget.producto.IdPerfilCreador,
          IdUsuarioCreador: widget.producto.IdUsuarioCreador,
          Imagenes: widget.producto.Imagenes,
          Visible: widget.producto.Visible);

      final exito = await ServicioProductos().actualizarProducto(nuevoProducto);

      if (exito) {
        Navigator.of(context).pop(true); // Regresa a la página anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el producto.')),
        );
      }
    }
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
              GestureDetector(
                onTap: _pickImage,
                child: _nuevaImagen != null
                    ? Image.file(_nuevaImagen!)
                    : (widget.producto.Imagenes.isNotEmpty &&
                            File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\${widget.producto.Imagenes[0]}')
                                .existsSync())
                        ? Image.file(File(
                            'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\${widget.producto.Imagenes[0]}'))
                        : const Icon(Icons.image_not_supported, size: 100),
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
                      itemCount: perfiles.length,
                      itemBuilder: (context, index) {
                        final perfil = perfiles[index];

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
                                    if (_perfilSeleccionado.contains(perfil.Id))
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
                            print('Perfil seleccionado: $_perfilSeleccionado');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _editarProducto,
                child: const Text('Actualizar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
