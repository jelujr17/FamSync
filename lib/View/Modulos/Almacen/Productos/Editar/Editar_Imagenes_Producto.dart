import 'dart:io';

import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_Producto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

    if (mounted) {
      setState(() {
        _imagenesCargadas = imagenes;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        setState(() {
          _nuevasImagenes.addAll(images.map((image) => File(image.path)));
        });
      }
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
