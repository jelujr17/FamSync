import 'dart:io';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Almacen/tiendas.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

class ProductCreationCarousel extends StatefulWidget {
  final Perfiles perfil;

  const ProductCreationCarousel({super.key, required this.perfil});

  @override
  _ProductCreationCarouselState createState() =>
      _ProductCreationCarouselState();
}

class _ProductCreationCarouselState extends State<ProductCreationCarousel> {
  final PageController _pageController = PageController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();

  final List<XFile> _imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();
  int _currentPageIndex = 0;
  final List<int> _perfilSeleccionado = [];
  List<File> _imagenesFiles = [];
  List<Tiendas> tiendasDisponibles = [];
  String? tiendaSeleccionada;

  List<String> nombresTienda = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  Future<void> _seleccionarImagenes() async {
    final List<XFile> imagenes = await _picker.pickMultiImage();
    setState(() {
      _imagenesSeleccionadas.addAll(imagenes);
      _imagenesFiles = imagenes.map((xFile) => File(xFile.path)).toList();
      print('Imágenes seleccionadas: $_imagenesFiles');
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerTiendas();
    obtenerNombresTiendas();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.toInt();
      });
    });
  }

  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(
        nombresTienda); // Asegúrate de que nombresTienda esté correctamente poblada

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  void obtenerTiendas() async {
    tiendasDisponibles =
        await ServiciosTiendas().getTiendas(widget.perfil.UsuarioId);
    obtenerNombresTiendas(); // Asegúrate de que esto se llame después de obtener las tiendas

    setState(() {});
  }

  void obtenerNombresTiendas() {
    nombresTienda = tiendasDisponibles.map((e) => e.Nombre).toList();
    print(nombresTienda);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  bool _validarCampos() {
    if (_nombreController.text.isEmpty ||
        tiendaSeleccionada == null ||
        _precioController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void _mostrarAlerta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Campos incompletos'),
          content: const Text(
              'Por favor, complete todos los campos antes de continuar.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 550,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Crear Producto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colores.texto,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del producto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.shopping_cart),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // DropdownButton para seleccionar la tienda
                        DropDownSearchFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: InputDecoration(
                              labelText: 'Selecciona una tienda',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons
                                  .store), // Puedes cambiar el ícono si lo deseas
                            ),
                            controller: _dropdownSearchFieldController,
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(
                                pattern); // Debe devolver una lista de nombres de tienda
                          },
                          itemBuilder: (context, String suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          itemSeparatorBuilder: (context, index) {
                            return const Divider();
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (String suggestion) {
                            _dropdownSearchFieldController.text = suggestion;
                            tiendaSeleccionada =
                                suggestion; // Actualiza la variable de tienda seleccionada
                          },
                          suggestionsBoxController: suggestionBoxController,
                          validator: (value) => value!.isEmpty
                              ? 'Por favor selecciona una tienda'
                              : null,
                          displayAllSuggestionWhenTap: true,
                        ),

                        const SizedBox(height: 16),
                        TextField(
                          controller: _precioController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Segunda pantalla: Selección de perfiles
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selecciona los perfiles visibles:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: FutureBuilder<List<Perfiles>>(
                            future: ServicioPerfiles()
                                .getPerfiles(widget.perfil.UsuarioId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child:
                                        Text('No hay perfiles disponibles.'));
                              }

                              List<Perfiles> perfiles = snapshot.data!;
                              for (int i = 0; i < perfiles.length; i++) {
                                if (perfiles[i].Id == widget.perfil.Id) {
                                  perfiles.removeAt(i);
                                }
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: perfiles.length,
                                itemBuilder: (context, index) {
                                  final perfil = perfiles[index];

                                  return ListTile(
                                    title: Text(
                                      perfil.Nombre,
                                      style: const TextStyle(
                                        color: Colores.texto,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    leading: perfil.FotoPerfil.isNotEmpty &&
                                            File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')
                                                .existsSync()
                                        ? Stack(
                                            children: [
                                              CircleAvatar(
                                                radius:
                                                    25, // Puedes ajustar el radio según tu necesidad
                                                backgroundImage: FileImage(File(
                                                    'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')),
                                              ),
                                              if (_perfilSeleccionado
                                                  .contains(perfil.Id))
                                                const Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  child: Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green),
                                                ),
                                            ],
                                          )
                                        : const Icon(Icons.image_not_supported),
                                    tileColor:
                                        _perfilSeleccionado.contains(perfil.Id)
                                            ? Colores.principal.withOpacity(0.2)
                                            : null,
                                    onTap: () {
                                      setState(() {
                                        if (_perfilSeleccionado
                                            .contains(perfil.Id)) {
                                          _perfilSeleccionado.remove(perfil.Id);
                                        } else {
                                          _perfilSeleccionado.add(perfil.Id);
                                        }
                                      });
                                      print(
                                          'Perfil seleccionado: $_perfilSeleccionado');
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tercera pantalla: Selección de imágenes
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _seleccionarImagenes,
                          icon: const Icon(Icons.image),
                          label: const Text('Seleccionar imágenes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _imagenesSeleccionadas.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _imagenesSeleccionadas.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              File(_imagenesSeleccionadas[index]
                                                  .path),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  _imagenesSeleccionadas
                                                      .removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text(
                                'No hay imágenes seleccionadas.',
                                style: TextStyle(color: Colors.grey),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón "Atrás"
                  if (_currentPageIndex > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_currentPageIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).pop(); // Cerrar diálogo
                        }
                      },
                      label: const Text('Atrás'),
                      icon: const Icon(Icons.arrow_back),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),

                  // Spacer para empujar el botón "Siguiente" a la derecha en la primera página
                  if (_currentPageIndex == 0) const Spacer(),

                  // Botón "Siguiente"
                  if (_currentPageIndex < 2)
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_currentPageIndex == 0 && !_validarCampos()) {
                          _mostrarAlerta(); // Mostrar alerta si no se han completado los campos
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      label: const Text('Siguiente'),
                      icon: const Icon(Icons.arrow_forward),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),

                  // Botón "Guardar"
                  if (_currentPageIndex == 2)
                    ElevatedButton.icon(
                      onPressed: () async {
                        String nombre = _nombreController.text;

                        // Asegúrate de que el perfil actual se agrega solo una vez
                        if (!_perfilSeleccionado.contains(widget.perfil.Id)) {
                          _perfilSeleccionado.add(widget.perfil.Id);
                        }

                        double precio = double.parse(_precioController.text);

                        print(
                            'Producto: $nombre, Tienda: $tiendaSeleccionada, Precio: $precio, Perfil seleccionado: $_perfilSeleccionado, Imagenes seleccionadas: $_imagenesSeleccionadas');
                        if (_perfilSeleccionado.contains(widget.perfil.Id)) {
                          _perfilSeleccionado.remove(widget.perfil.Id);
                        }
                        bool creado =
                            await ServicioProductos().registrarProducto(
                                nombre,
                                _imagenesFiles,
                                tiendaSeleccionada!,
                                precio, // Aquí ahora se pasa como double
                                widget.perfil.Id,
                                widget.perfil.UsuarioId,
                                _perfilSeleccionado);

                        if (creado) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
