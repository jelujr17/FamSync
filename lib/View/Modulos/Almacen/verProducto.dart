import 'dart:io';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/producto.dart';

class VerProducto extends StatefulWidget {
  final Productos producto;
  final Perfiles perfil;

  const VerProducto({Key? key, required this.producto, required this.perfil})
      : super(key: key);

  @override
  DetallesProducto createState() => DetallesProducto();
}

class DetallesProducto extends State<VerProducto>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto.Nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar la imagen del producto
            widget.producto.Imagenes.isNotEmpty
                ? Image.file(
                    File(widget.producto.Imagenes[0]),
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16),
            Text(
              'Tienda: ${widget.producto.Tienda}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Precio: ${widget.producto.Precio.toStringAsFixed(2)}€', // Formato a 2 decimales
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Creador del Perfil ID: ${widget.producto.IdPerfilCreador}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Creador del Usuario ID: ${widget.producto.IdUsuarioCreador}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Visibilidad: ${widget.producto.Visible.join(", ")}', // Mostrar perfiles visibles
              style: const TextStyle(fontSize: 16),
            ),
            // Aquí puedes agregar más detalles según sea necesario
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
          pageController: PageController(), pagina: 1, perfil: widget.perfil),
    );
  }
}
