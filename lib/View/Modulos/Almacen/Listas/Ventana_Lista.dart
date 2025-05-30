import 'dart:io';

import 'package:famsync/Model/Almacen/Listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VentanaListas extends StatefulWidget {
  final VoidCallback actualizarBanner;
  final Perfiles perfil;

  const VentanaListas({
    super.key,
    required this.actualizarBanner,
    required this.perfil,
  });

  @override
  _VentanaListasState createState() => _VentanaListasState();
}

class _VentanaListasState extends State<VentanaListas> {
  Map<String, Widget> imageWidgets = {};
  List<String> perfilesSeleccionados = [];
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      perfilesProvider.cargarPerfiles(user!.uid);

      final productoProvider =
          Provider.of<ProductosProvider>(context, listen: false);
      productoProvider.cargarProductos(user!.uid, widget.perfil.PerfilID);

      final listasProvider =
          Provider.of<ListasProvider>(context, listen: false);
      listasProvider.cargarListas(user!.uid, widget.perfil.PerfilID);
    });
  }

  void loadImages() {
    final listasProvider = Provider.of<ListasProvider>(context, listen: false);
    final productoProvider =
        Provider.of<ProductosProvider>(context, listen: false);

    for (var lista in listasProvider.listas) {
      for (var productoId in lista.productos) {
        var producto = productoProvider.productos
            .firstWhere((p) => p.PerfilID == productoId);
        ServicioProductos()
            .getArchivosImagenesProducto(user!.uid, productoId)
            .then((imageFile) {
          setState(() {
            imageWidgets[productoId] = Image.file(imageFile!.first,
                width: 50, height: 50, fit: BoxFit.cover);
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
        TextEditingController(text: lista.nombre);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colores.fondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Editar Lista',
            style: TextStyle(color: Colores.texto),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'nombre de la Lista',
                  labelStyle:
                      const TextStyle(fontSize: 16, color: Colores.texto),
                  hintText: 'Ingresa un nombre para la Lista',
                  hintStyle: const TextStyle(color: Colores.texto),
                  prefixIcon:
                      const Icon(Icons.shopping_bag, color: Colores.texto),
                  filled: true,
                  fillColor: Colores.fondoAux,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none, // Sin borde inicial
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colores.fondoAux, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colores.texto, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                ),
                style: const TextStyle(
                    color: Colores.texto), // Cambia el color del texto aquí
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin guardar
              },
              child: const Text('Cancelar',
                  style: TextStyle(color: Colores.fondoAux)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Crear una nueva instancia de Listas con el nombre actualizado
                  Listas listaActualizada = Listas(
                    ListaID: lista.ListaID,
                    nombre: nombreController.text,
                    visible: lista.visible,
                    productos: lista.productos,
                    PerfilID: lista.PerfilID,
                  );
                  final listasProvider =
                      Provider.of<ListasProvider>(context, listen: false);

                  // Reemplazar la instancia antigua en la lista
                  int index = listasProvider.listas
                      .indexWhere((l) => l.ListaID == lista.ListaID);
                  if (index != -1) {
                    listasProvider.listas[index] = listaActualizada;
                  }

                  // Guarda los cambios en la base de datos o backend
                  ServiciosListas().actualizarLista(
                    user!.uid,
                    listaActualizada.ListaID,
                    listaActualizada.nombre,
                    listaActualizada.visible,
                    listaActualizada.productos,
                  );
                  listasProvider.actualizarLista(listaActualizada);

                  // Actualizar el estado del widget Almacen
                  setState(() {});
                });
                widget.actualizarBanner();
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child:
                  const Text('Guardar', style: TextStyle(color: Colores.texto)),
            ),
          ],
        );
      },
    );
  }

  void eliminarLista(Listas lista) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colores.fondo,
        title: const Text('Eliminar Lista',
            style: TextStyle(color: Colores.texto)),
        content: Text(
            '¿Estás seguro de que quieres eliminar la lista ${lista.nombre}?',
            style: TextStyle(color: Colores.texto)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar',
                style: TextStyle(color: Colores.fondoAux)),
          ),
          TextButton(
            onPressed: () async {
              await ServiciosListas().eliminarLista(user!.uid, lista.ListaID);

              final listasProvider =
                  Provider.of<ListasProvider>(context, listen: false);

              // Recargar las listas desde el backend
              await listasProvider.cargarListas(
                user!.uid,
                widget.perfil.PerfilID,
              );
              setState(() {});

              widget.actualizarBanner();
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colores.eliminar)),
          ),
        ],
      ),
    );
  }

  void eliminarProductoDeLista(Listas lista, String productoId) {
    setState(() {
      lista.productos.remove(productoId);
      ServiciosListas().actualizarLista(
        user!.uid,
        lista.ListaID,
        lista.nombre,
        lista.visible,
        lista.productos,
      );
    });
    final listasProvider = Provider.of<ListasProvider>(context, listen: false);
    listasProvider.actualizarLista(lista);
    widget.actualizarBanner();
  }

  void crearNuevaLista() {
    TextEditingController nombreController = TextEditingController();
    List<String> perfilesSeleccionados = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el BottomSheet ocupe más espacio
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colores.fondo,
      builder: (context) {
        final perfilesProvider =
            Provider.of<PerfilesProvider>(context, listen: false);
        final perfiles = perfilesProvider.perfiles
            .where((perfil) => perfil.PerfilID != widget.perfil.PerfilID)
            .toList(); // Filtrar el perfil del usuario actual

        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colores.fondo, // Fondo fondoAux para toda la sección
              borderRadius: BorderRadius.circular(8), // Bordes redondeados
            ),
            padding: const EdgeInsets.all(12), // Espaciado interno

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list_alt, color: Colores.texto),
                    const SizedBox(width: 8),
                    const Text(
                      'Crear Nueva Lista',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colores.texto,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'nombre de la Lista',
                    labelStyle:
                        const TextStyle(fontSize: 16, color: Colores.texto),
                    hintText: 'Ingresa un nombre para la Lista',
                    hintStyle: const TextStyle(color: Colores.texto),
                    prefixIcon:
                        const Icon(Icons.shopping_bag, color: Colores.texto),
                    filled: true,
                    fillColor: Colores.fondoAux,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none, // Sin borde inicial
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colores.fondoAux, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Colores.texto, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                  ),
                  style: const TextStyle(
                      color: Colores.texto), // Cambia el color del texto aquí
                ),
                const SizedBox(height: 20),
                Text(
                  'Selecciona los perfiles:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colores.texto,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colores
                          .fondoAux, // Fondo fondoAux para toda la sección
                      borderRadius:
                          BorderRadius.circular(8), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.all(12), // Espaciado interno
                    child: Column(
                      children: perfiles.map((perfil) {
                        return ListTile(
                          title: Text(
                            perfil.nombre,
                            style: const TextStyle(
                              color: Colores.texto,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          leading: perfil.FotoPerfil.isNotEmpty
                              ? FutureBuilder<File>(
                                  future: ServicioPerfiles()
                                      .getFotoPerfil(user!.uid, perfil.PerfilID)
                                      .then((file) => file ?? File('')),
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
                                              .contains(perfil.PerfilID))
                                            Positioned(
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
                          tileColor:
                              perfilesSeleccionados.contains(perfil.PerfilID)
                                  ? Colores.fondoAux
                                  : null,
                          onTap: () {
                            setState(() {
                              if (perfilesSeleccionados
                                  .contains(perfil.PerfilID)) {
                                perfilesSeleccionados.remove(perfil.PerfilID);
                              } else {
                                perfilesSeleccionados.add(perfil.PerfilID);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el BottomSheet
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colores.eliminar,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Crear una nueva lista en el backend
                        final nuevaLista = Listas(
                          ListaID: "0", // Generar un ID único
                          nombre: nombreController.text,
                          visible: perfilesSeleccionados,
                          productos: [],
                          PerfilID: widget.perfil.PerfilID,
                        );

                        final listasProvider =
                            Provider.of<ListasProvider>(context, listen: false);

                        await ServiciosListas().registrarLista(
                          user!.uid,
                          nuevaLista.nombre,
                          widget.perfil.PerfilID,
                          nuevaLista.visible,
                        );

                        // Recargar las listas desde el backend
                        await listasProvider.cargarListas(
                          user!.uid,
                          widget.perfil.PerfilID,
                        );
                        setState(() {});

                        widget.actualizarBanner();
                        Navigator.of(context).pop(); // Cerrar el BottomSheet
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.fondoAux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colores.texto,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfilesProvider = Provider.of<PerfilesProvider>(context);
    final perfiles = perfilesProvider.perfiles
        .where((perfil) => perfil.PerfilID != widget.perfil.PerfilID)
        .toList(); // Filtrar el perfil del usuario actual
    final listasProvider = Provider.of<ListasProvider>(context, listen: false);
    final productoProvider =
        Provider.of<ProductosProvider>(context, listen: false);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colores.fondo,
      title: const Text(
        'Tus Listas',
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colores.texto),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          listasProvider.listas.isNotEmpty
              ? SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: listasProvider.listas.map((lista) {
                        List<Productos> productosFiltrados = productoProvider
                            .productos
                            .where((producto) =>
                                lista.productos.contains(producto.ProductoID))
                            .toList();

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: Colores.fondoAux,
                          child: ExpansionTile(
                            title: Text(
                              lista.nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colores.texto,
                              ),
                            ),
                            leading:
                                const Icon(Icons.list, color: Colores.texto),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colores.texto),
                                  onPressed: () {
                                    editarLista(lista);
                                  },
                                ),
                                const SizedBox(
                                    width: 8), // Espaciado entre los íconos
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colores.eliminar),
                                  onPressed: () {
                                    eliminarLista(lista);
                                  },
                                ),
                              ],
                            ),
                            children: productosFiltrados.isNotEmpty
                                ? productosFiltrados.map((producto) {
                                    return ListTile(
                                      title: Text(producto.nombre),
                                      leading:
                                          imageWidgets[producto.ProductoID] ??
                                              const CircularProgressIndicator(),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colores.eliminar),
                                        onPressed: () {
                                          eliminarProductoDeLista(
                                              lista, producto.ProductoID);
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
                                          color: Colores.texto,
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
              : const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'No tienes listas aún. ¡Crea una nueva!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colores.texto,
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          // Botón para crear una nueva lista
          ElevatedButton.icon(
            onPressed: crearNuevaLista,
            icon: const Icon(Icons.add, color: Colores.texto),
            label: const Text('Crear Lista',
                style: TextStyle(color: Colores.texto)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.fondoAux,
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
              color: Colores.fondoAux,
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
