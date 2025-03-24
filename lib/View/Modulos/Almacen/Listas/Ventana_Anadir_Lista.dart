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
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título de la ventana
            Text(
              'Seleccionar Lista',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colores.principal,
              ),
            ),
            const SizedBox(height: 10),
            // Divider para separar el título del contenido
            const Divider(
              color: Colors.grey,
              thickness: 1,
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

                        return ListTile(
                          title: Text(
                            lista.Nombre,
                            style: const TextStyle(
                              color: Colores.texto,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          leading: lista.Productos.contains(widget.producto.Id)
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.list_alt,
                                  color: Colors.grey,
                                ),
                          tileColor:
                              lista.Productos.contains(widget.producto.Id)
                                  ? Colores.principal.withOpacity(0.2)
                                  : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            _toggleProductoEnLista(lista);
                          },
                        );
                      },
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'No hay listas disponibles. ¡Crea una nueva lista primero!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            // Botón de cerrar
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra la ventana
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.principal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleProductoEnLista(lista) {
    final listasProvider = Provider.of<ListasProvider>(context, listen: false);

    setState(() {
      if (lista.Productos.contains(widget.producto.Id)) {
        lista.Productos.remove(widget.producto.Id);
      } else {
        lista.Productos.add(widget.producto.Id);
      }
    });

    listasProvider.actualizarLista(lista);
    widget.actualizarBanner();
  }
}
