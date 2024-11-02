import 'dart:io';
import 'package:famsync/Model/listas.dart';
import 'package:famsync/Model/producto.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class DetallesListaDialog extends StatefulWidget {
  final Listas lista;

  const DetallesListaDialog({
    super.key,
    required this.lista,
    required void Function() onEdit,
    required void Function() onDelete,
  });

  @override
  _DetallesListaDialogState createState() => _DetallesListaDialogState();
}

class _DetallesListaDialogState extends State<DetallesListaDialog> {
  List<Productos> productosLista = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerProductos(widget.lista.Productos);
  }

  Future<void> obtenerProductos(List<int> idsProductos) async {
    if (idsProductos.isNotEmpty) {
      List<Productos?> productos = await Future.wait(
        idsProductos
            .map((id) async => await ServicioProductos().getProductoById(id)),
      );

      setState(() {
        productosLista = productos.whereType<Productos>().toList();
        isLoading = false;
      });
    }
  }

  void quitarProducto(Productos producto) async {
    List<int> productos = widget.lista.Productos;
    productos.remove(producto.Id);
    bool result = await ServiciosListas().actualizarLista(
        widget.lista.Id, widget.lista.Nombre, widget.lista.Visible, productos);
    if (result) {
      obtenerProductos(productos);
    } else {
      print('Error al editar la lista');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo colorido detrás del contenedor
          Container(
            decoration: BoxDecoration(
              color: Colores.principal.withOpacity(0.5), // Color de fondo
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Contenedor principal con borde
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco para el contenedor
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.lista.Nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 71, 51, 71),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colores.eliminar),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colores.texto, thickness: 1),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: ListView.builder(
                            itemCount: productosLista.length,
                            itemBuilder: (context, index) {
                              var elemento = productosLista[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colores.principal.withOpacity(0.6),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: elemento.Imagenes.isNotEmpty &&
                                          File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\${elemento.Imagenes[0]}')
                                              .existsSync()
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            File(
                                                'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Productos\\${elemento.Imagenes[0]}'),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.image_not_supported,
                                          color: Colores.texto),
                                  title: Text(
                                    elemento.Nombre,
                                    style: const TextStyle(
                                      color: Colores.texto,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '\$${elemento.Precio.toStringAsFixed(2)}',
                                    style:
                                        const TextStyle(color: Colores.texto),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () => quitarProducto(elemento),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colores.eliminar.withOpacity(0.85),
                                      side: const BorderSide(
                                          color: Colores.texto, width: 1),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colores.fondo),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
