
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/View/Modulos/Almacen/Productos/Ver_ID/Imagenes_Pequena_Producto.dart';
import 'package:flutter/material.dart';

class ImagenesProducto extends StatefulWidget {
  const ImagenesProducto({
    super.key,
    required this.producto,
  });

  final Productos producto;

  @override
  _ImagenesProductoState createState() => _ImagenesProductoState();
}

class _ImagenesProductoState extends State<ImagenesProducto> {
  late Future<List<Widget>> _imagenesFuture;

  @override
  void initState() {
    super.initState();
    _imagenesFuture = loadImages();
  }

  Future<List<Widget>> loadImages() async {
    List<Widget> imagenes = [];
    for (String urlImagen in widget.producto.Imagenes) {
      final imageFile = await ServicioProductos().obtenerImagen(context, urlImagen);
      imagenes.add(Image.file(imageFile));
    }
    return imagenes;
  }

  int selectedImage = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _imagenesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error al cargar las imágenes');
        } else {
          final imagenes = snapshot.data!;
          return Column(
            children: [
              SizedBox(
                width: 238,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: imagenes[selectedImage],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    imagenes.length,
                    (index) => ImagenPequena(
                      esSeleccionada: index == selectedImage,
                      funcion: () {
                        setState(() {
                          selectedImage = index;
                        });
                      },
                      urlImagen: widget.producto.Imagenes[index],
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}