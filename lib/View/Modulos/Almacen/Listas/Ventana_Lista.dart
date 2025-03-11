import 'dart:io';

import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VentanaListas extends StatefulWidget {
  final List<Listas> listas;
  final List<Productos> productos;
  final VoidCallback actualizarBanner;
  final Perfiles perfil;

  const VentanaListas({
    super.key,
    required this.listas,
    required this.productos,
    required this.actualizarBanner,
    required this.perfil,
  });

  @override
  _VentanaListasState createState() => _VentanaListasState();
}

class _VentanaListasState extends State<VentanaListas> {
  Map<int, Widget> imageWidgets = {};
  List<int> perfilesSeleccionados = [];

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

  void crearNuevaLista() {
    TextEditingController nombreController = TextEditingController();
    List<int> perfilesSeleccionados = [];

    showDialog(
      context: context,
      builder: (context) {
        final perfilesProvider =
            Provider.of<PerfilesProvider>(context, listen: false);
        final perfiles = perfilesProvider.perfiles;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Crear Nueva Lista'),
          content: SizedBox(
            height: 400, // Ajustar la altura según sea necesario
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la lista',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selecciona los perfiles:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: perfiles.length,
                    itemBuilder: (context, index) {
                      final perfil = perfiles[index];
                      return ListTile(
                        title: Text(perfil.Nombre),
                        leading: perfil.FotoPerfil.isNotEmpty
                            ? FutureBuilder<File>(
                                future: ServicioPerfiles()
                                    .obtenerImagen(perfil.FotoPerfil),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Icon(Icons.error);
                                  } else if (!snapshot.hasData) {
                                    return const Icon(
                                        Icons.image_not_supported);
                                  } else {
                                    return Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              FileImage(snapshot.data!),
                                        ),
                                        if (perfilesSeleccionados
                                            .contains(perfil.Id))
                                          const Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Icon(Icons.check_circle,
                                                color: Colors.green),
                                          ),
                                      ],
                                    );
                                  }
                                },
                              )
                            : const Icon(Icons.image_not_supported),
                        tileColor: perfilesSeleccionados.contains(perfil.Id)
                            ? Colores.principal.withOpacity(0.2)
                            : null,
                        onTap: () {
                          setState(() {
                            if (perfilesSeleccionados.contains(perfil.Id)) {
                              perfilesSeleccionados.remove(perfil.Id);
                            } else {
                              perfilesSeleccionados.add(perfil.Id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
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
                  // Crear una nueva instancia de Listas
                  Listas nuevaLista = Listas(
                    Id: DateTime.now()
                        .millisecondsSinceEpoch, // Generar un ID único
                    Nombre: nombreController.text,
                    Visible: perfilesSeleccionados,
                    Productos: [],
                    IdPerfil: 0, // Ajustar según sea necesario
                    IdUsuario: 0, // Ajustar según sea necesario
                  );

                  // Agregar la nueva lista a la lista existente
                  widget.listas.add(nuevaLista);

                  // Guarda la nueva lista en la base de datos o backend
                  ServiciosListas().registrarLista(
                    nuevaLista.Nombre,
                    widget.perfil.Id,
                    widget.perfil.UsuarioId,
                    nuevaLista.Visible
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
                  onPressed: crearNuevaLista,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Crear Lista',
                      style: TextStyle(color: Colors.white)),
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
          child: pulsado ? const Text("Ver más") : const Text("Ver menos"),
        ),
      ],
    );
  }
}
