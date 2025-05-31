import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ImagenPequena extends StatelessWidget {
  final bool esSeleccionada;
  final VoidCallback funcion;
  final String productoID;

  ImagenPequena({
    super.key,
    required this.esSeleccionada,
    required this.funcion,
    required this.productoID,
  });

  final user = FirebaseAuth.instance.currentUser;

  Future<Widget> loadImage() async {
    try {
      final archivos = await ServicioProductos()
          .getArchivosImagenesProducto(user!.uid, productoID);

      if (archivos == null || archivos.isEmpty) {
        throw Exception('El archivo de imagen está vacío o es nulo');
      }

      return Image.file(
        archivos[0],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error al cargar la imagen: $e');
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(
            Icons.broken_image,
            size: 40,
            color: Colors.grey,
          ),
        ),
      );
    }
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
          color: Colores.fondoAux,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colores.texto.withOpacity(esSeleccionada ? 1 : 0),
          ),
        ),
        child: FutureBuilder<Widget>(
          future: loadImage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Icon(Icons.error, color: Colores.eliminar);
            } else if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return const Icon(Icons.image_not_supported);
            }
          },
        ),
      ),
    );
  }
}
