import 'package:famsync/Model/listas.dart';
import 'package:famsync/Model/producto.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class DetallesListaDialog extends StatefulWidget {
  final Listas lista; // Recibe la lista seleccionada

  const DetallesListaDialog({super.key, required this.lista, required void Function() onEdit, required void Function() onDelete});

  @override
  _ListasViewState createState() => _ListasViewState();
}

class _ListasViewState extends State<DetallesListaDialog>
    with SingleTickerProviderStateMixin {
  List<Productos> productosLista = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    obtenerProductos(widget.lista.Productos);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> obtenerProductos(List<int> idsProductos) async {
    if (idsProductos.isNotEmpty) {
      List<Productos?> productos = await Future.wait(
        idsProductos
            .map((id) async => await ServicioProductos().getProductoById(id)),
      );

      setState(() {
        productosLista = productos
            .whereType<Productos>()
            .toList(); // Filtra los productos nulos
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colores.fondo, // Color de fondo del diálogo
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lista.Nombre,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colores.texto),
            ),
            const Divider(color: Colores.principal), // Separador
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: productosLista.length,
                itemBuilder: (context, index) {
                  var elemento = productosLista[index]; // Obtén cada elemento
                  return Card(
                    color: Colores.botones, // Color de las tarjetas
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        elemento.Nombre, // Muestra el nombre del elemento
                        style: const TextStyle(
                          color: Colores.texto, // Color del texto
                          fontWeight: FontWeight.bold,
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
    );
  }
}
