import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_ID/Imagenes_Pequena_Producto.dart';
import 'package:flutter/material.dart';

class ImagenesProducto extends StatefulWidget {
  const ImagenesProducto({
    super.key,
    required this.producto,
  });

  final Productos producto;

  @override
  _ImagenesProductoState createState() => _ImagenesProductoState();
}

class _ImagenesProductoState extends State<ImagenesProducto> {
  int selectedImage = 0;

  @override
  Widget build(BuildContext context) {
    final imagenes = widget.producto.imagenes;

    if (imagenes.isEmpty) {
      return const Center(child: Text('Sin imágenes'));
    }

    return Column(
      children: [
        SizedBox(
          width: 238,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imagenes[selectedImage],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 60),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              imagenes.length,
              (index) => ImagenPequena(
                esSeleccionada: index == selectedImage,
                funcion: () {
                  setState(() {
                    selectedImage = index;
                  });
                },
                productoID: widget.producto.ProductoID,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
