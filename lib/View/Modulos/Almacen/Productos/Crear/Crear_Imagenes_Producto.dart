import 'dart:io';

import 'package:famsync/View/Modulos/Almacen/Productos/Ver_Producto.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagenesProductoCrear extends StatefulWidget {
  const ImagenesProductoCrear({
    super.key,
    required this.onEliminarImagenNueva,
    required this.onNuevasImagenesSeleccionadas,
  });

  final Function(File) onEliminarImagenNueva;
  final Function(List<File>) onNuevasImagenesSeleccionadas;

  @override
  _ImagenesProductoStateCrear createState() => _ImagenesProductoStateCrear();
}

class _ImagenesProductoStateCrear extends State<ImagenesProductoCrear> {
  final List<File> _nuevasImagenes = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        setState(() {
          _nuevasImagenes.addAll(images.map((image) => File(image.path)));
        });
        widget.onNuevasImagenesSeleccionadas(_nuevasImagenes);
      }
    } catch (e) {
      print("Error al seleccionar imágenes: $e");
    }
  }

  void _eliminarImagenNueva(int index) {
    File imagen = _nuevasImagenes[index];
    setState(() {
      _nuevasImagenes.removeAt(index);
    });
    widget.onEliminarImagenNueva(imagen);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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
          color: Colores.fondoAux,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colores.fondoAux,
                  foregroundColor: Colores.fondo,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                onPressed: _pickImage,
                child: const Text("Añadir imágenes",
                    style: TextStyle(color: Colores.texto)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
