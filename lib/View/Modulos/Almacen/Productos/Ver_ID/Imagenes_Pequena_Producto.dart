
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:flutter/material.dart';

class ImagenPequena extends StatelessWidget {
  const ImagenPequena({
    super.key,
    required this.esSeleccionada,
    required this.funcion,
    required this.urlImagen,
  });

  final bool esSeleccionada;
  final VoidCallback funcion;
  final String urlImagen;

  Future<Widget> loadImage(BuildContext context) async {
    final imageFile = await ServicioProductos().obtenerImagen(context, urlImagen);
    return Image.file(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: funcion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFF7643).withOpacity(esSeleccionada ? 1 : 0),
          ),
        ),
        child: FutureBuilder<Widget>(
          future: loadImage(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Icon(Icons.error, color: Colors.red);
            } else {
              return snapshot.data!;
            }
          },
        ),
      ),
    );
  }
}