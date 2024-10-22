import 'dart:io';
import 'package:flutter/material.dart';
import 'package:famsync/Model/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';

class EditarProducto extends StatefulWidget {
  final Productos producto;
  final Perfiles perfil;

  const EditarProducto({Key? key, required this.producto, required this.perfil})
      : super(key: key);

  @override
  _EditarProductoState createState() => _EditarProductoState();
}

class _EditarProductoState extends State<EditarProducto> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _tiendaController;
  late TextEditingController _precioController;
  File? _nuevaImagen;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.Nombre);
    _tiendaController = TextEditingController(text: widget.producto.Tienda);
    _precioController =
        TextEditingController(text: widget.producto.Precio.toString());
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
