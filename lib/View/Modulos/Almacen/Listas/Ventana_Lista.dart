
import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:flutter/material.dart';

class VentanaListas extends StatefulWidget {
  final List<Listas> listas;
  final List<Productos> productos;
  final VoidCallback actualizarBanner;

  const VentanaListas({
    super.key,
    required this.listas,
    required this.productos,
    required this.actualizarBanner,
  });

  @override
  _VentanaListasState createState() => _VentanaListasState();
}

class _VentanaListasState extends State<VentanaListas> {
  Map<int, Widget> imageWidgets = {};

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() {
    for (var lista in widget.listas) {
      for (var productoId in lista.Productos) {
        var producto = widget.productos.firstWhere((p) => p.Id == productoId);
        ServicioProductos()
            .obtenerImagen(producto.Imagenes[0])
            .then((imageFile) {
          setState(() {
            imageWidgets[productoId] =
                Image.file(imageFile, width: 50, height: 50, fit: BoxFit.cover);
          });
        }).catchError((error) {
          setState(() {
            imageWidgets[productoId] =
                const Icon(Icons.error, color: Colors.red);
          });
        });
      }
    }
  }

  void editarLista(Listas lista) async {
    TextEditingController nombreController =
        TextEditingController(text: lista.Nombre);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Editar Lista'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la lista',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin guardar
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Crear una nueva instancia de Listas con el nombre actualizado
                  Listas listaActualizada = Listas(
                    Id: lista.Id,
                    Nombre: nombreController.text,
                    Visible: lista.Visible,
                    Productos: lista.Productos,
                    IdPerfil: lista.IdPerfil,
                    IdUsuario: lista.IdUsuario,
                  );

                  // Reemplazar la instancia antigua en la lista
                  int index = widget.listas.indexWhere((l) => l.Id == lista.Id);
                  if (index != -1) {
                    widget.listas[index] = listaActualizada;
                  }

                  // Guarda los cambios en la base de datos o backend
                  ServiciosListas().actualizarLista(
                    listaActualizada.Id,
                    listaActualizada.Nombre,
                    listaActualizada.Visible,
                    listaActualizada.Productos,
                  );

                  // Actualizar el estado del widget Almacen
                  setState(() {});
                });
                widget.actualizarBanner();
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarProductoDeLista(Listas lista, int productoId) {
    setState(() {
      lista.Productos.remove(productoId);
      ServiciosListas().actualizarLista(
        lista.Id,
        lista.Nombre,
        lista.Visible,
        lista.Productos,
      );
    });
    widget.actualizarBanner();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      title: const Text(
        'Tus Listas',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A3298),
        ),
      ),
      content: widget.listas.isNotEmpty
          ? SizedBox(
              width: double.maxFinite,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: widget.listas.map((lista) {
                    List<Productos> productosFiltrados = widget.productos
                        .where(
                            (producto) => lista.Productos.contains(producto.Id))
                        .toList();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ExpansionTile(
                        title: Text(
                          lista.Nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        leading:
                            const Icon(Icons.list, color: Color(0xFF4A3298)),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.edit, color: Color(0xFF4A3298)),
                          onPressed: () {
                            editarLista(lista); // Abre el formulario de edición
                          },
                        ),
                        children: productosFiltrados.isNotEmpty
                            ? productosFiltrados.map((producto) {
                                return ListTile(
                                  title: Text(producto.Nombre),
                                  leading: imageWidgets[producto.Id] ??
                                      const CircularProgressIndicator(),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      eliminarProductoDeLista(
                                          lista, producto.Id);
                                    },
                                  ),
                                );
                              }).toList()
                            : [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "No hay productos en esta lista",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'No tienes listas aún. ¡Crea una nueva!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para crear una nueva lista
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Crear Lista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3298),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cerrar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3298),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.titulo,
    required this.accion,
    required this.pulsado,
  });

  final String titulo;
  final GestureTapCallback accion;
  final bool pulsado;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: accion,
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: pulsado ? Text("Ver más") : Text("Ver menos"),
        ),
      ],
    );
  }
}