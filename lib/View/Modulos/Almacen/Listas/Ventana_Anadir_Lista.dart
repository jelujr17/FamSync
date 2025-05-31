import 'package:famsync/Model/Almacen/Listas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/components/colores.dart';

class VentanaAnadirListas extends StatefulWidget {
  final VoidCallback actualizarBanner;
  final Productos producto;

  const VentanaAnadirListas({
    super.key,
    required this.actualizarBanner,
    required this.producto,
  });

  @override
  _VentanaAnadirListasState createState() => _VentanaAnadirListasState();
}

class _VentanaAnadirListasState extends State<VentanaAnadirListas> {
  @override
  Widget build(BuildContext context) {
    final listasProvider = Provider.of<ListasProvider>(context, listen: false);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16), // Bordes redondeados opcionales
      ),
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.5, // 80% del ancho de la pantalla
        height: MediaQuery.of(context).size.height *
            0.4, // 40% del alto de la pantalla
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colores.fondo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colores.texto, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Seleccionar Lista',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colores.texto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              color: Colores.fondoAux,
              thickness: 1,
              height: 20,
            ),
            const SizedBox(height: 10),
            // Contenido de las listas
            listasProvider.listas.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: listasProvider.listas.length,
                      itemBuilder: (context, index) {
                        final lista = listasProvider.listas[index];

                        return Card(
                          color: lista.productos
                                  .contains(widget.producto.ProductoID)
                              ? Colores.fondoAux.withOpacity(0.2)
                              : Colores.fondoAux,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              lista.nombre,
                              style: const TextStyle(
                                color: Colores.texto,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            leading: lista.productos
                                    .contains(widget.producto.ProductoID)
                                ? const Icon(Icons.check_circle,
                                    color: Colores.hecho)
                                : const Icon(Icons.list_alt,
                                    color: Colores.fondoAux),
                            onTap: () {
                              _toggleProductoEnLista(lista);
                            },
                          ),
                        );
                      },
                    ),
                  )
                : Column(
                    children: const [
                      Icon(Icons.info_outline,
                          color: Colores.fondoAux, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'No hay listas disponibles. ¡Crea una nueva lista primero!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colores.texto,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            // Botón de cerrar
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra la ventana
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.fondoAux,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: Colores.texto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleProductoEnLista(lista) {
    final listasProvider = Provider.of<ListasProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      if (lista.productos.contains(widget.producto.ProductoID)) {
        lista.productos.remove(widget.producto.ProductoID);
      } else {
        lista.productos.add(widget.producto.ProductoID);
      }
    });
    ServiciosListas().actualizarLista(
        user!.uid, lista.ListaID, lista.nombre, lista.visible, lista.productos);
    listasProvider.actualizarLista(lista);
    widget.actualizarBanner();
  }
}
