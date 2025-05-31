// ignore_for_file: file_names, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Paquete para seleccionar imágenes desde la galería o cámara
import 'dart:io'; // Para manejar archivos
import 'package:intl/intl.dart'; // Paquete para formatear fechas
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/View/Inicio/Seleccion_Perfil.dart';
import 'package:famsync/components/colores.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Perfiles perfil;

  const EditarPerfilScreen({super.key, required this.perfil});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  bool _isPinVisible = false; // Variable para controlar la visibilidad del PIN
  File? _imagenPerfil; // Cambiado a File? para almacenar la imagen
    final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.perfil.nombre;
    _fechaController.text = widget.perfil.FechaNacimiento;
    _cargarImagenPerfil(); // Llama a cargar la imagen al iniciar
  }

  // Método para cargar la imagen de perfil desde el servicio
  Future<void> _cargarImagenPerfil() async {
    if (widget.perfil.FotoPerfil.isNotEmpty) {
      File? imagen = await ServicioPerfiles()
          .getFotoPerfil(user!.uid, widget.perfil.PerfilID);
      setState(() {
        _imagenPerfil = imagen; // Actualiza el estado de la imagen
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenPerfil =
            File(pickedFile.path); // Actualiza la imagen seleccionada
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        DateTime localDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );
        _fechaController.text = DateFormat('dd/MM/yyyy').format(localDate);
      });
    }
  }

  Future<void> _editarPerfil() async {
    final String nombre = _nombreController.text;
    final String pin = _pinController.text;
    final String nuevopin = _newPinController.text;
    final String fechaNacimientoStr = _fechaController.text;
    final user = FirebaseAuth.instance.currentUser;

    if (nombre.isNotEmpty && pin.isNotEmpty && fechaNacimientoStr.isNotEmpty) {
      try {
        DateFormat format = DateFormat("dd/MM/yyyy");
        format.parse(fechaNacimientoStr);

        Perfiles? perfil = await ServicioPerfiles()
            .getPerfilByPID( user!.uid, widget.perfil.PerfilID);
        if (perfil != null) {
          int pin_actual = perfil.Pin;
          print("Imagen nueva: ${_imagenPerfil?.path}");
          if (pin_actual == int.parse(pin)) {
            bool editado = await ServicioPerfiles().editarPerfil(
                user.uid,
                widget.perfil.PerfilID,
                nombre,
                _imagenPerfil!.path.isNotEmpty
                    ? _imagenPerfil!
                    : null, // Si no hay imagen, se envía null
                int.parse(nuevopin),
                fechaNacimientoStr,
                perfil.FotoPerfil);
            if (editado) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil editado exitosamente')),
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SeleccionPerfil(
                            UID: user.uid,
                          )));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al editar un perfil')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN incorrecto')),
            );
          }
        } else {
          print('Perfil no encontrado.');
        }
      } catch (e) {
        print('Formato de fecha incorrecto: $e');
      }
    } else {
      print('Por favor completa todos los campos.');
    }
  }

  Future<void> _eliminarPerfil() async {
    /*
    // Mostrar ventana emergente de confirmación
    bool confirm = await _mostrarConfirmacionEliminar();
    if (confirm) {
      bool eliminado =
          await ServicioPerfiles().eliminarPerfil(widget.perfil.PerfilID);
      if (eliminado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil eliminado exitosamente')),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SeleccionPerfil(
                      IdUsuario: user!.uid,
                    )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar un perfil')),
        );
      }
    }*/
  }

  Future<bool> _mostrarConfirmacionEliminar() async {
        final user = FirebaseAuth.instance.currentUser;

    TextEditingController pinController = TextEditingController();
    Perfiles? perfilEliminar = await ServicioPerfiles()
        .getPerfilByPID( user!.uid, widget.perfil.PerfilID);

    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      '¿Estás seguro de que quieres eliminar este perfil? Esta acción no se puede deshacer.'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pinController,
                    decoration: const InputDecoration(
                      labelText: 'Ingresa el PIN para confirmar',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Eliminar cancelado
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (pinController.text.isNotEmpty &&
                        pinController.text == perfilEliminar!.Pin.toString()) {
                      Navigator.of(context).pop(true); // Confirmar eliminación
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN incorrecto')),
                      );
                    }
                  },
                  child: const Text('Eliminar',
                      style: TextStyle(color: Colores.eliminar)),
                ),
              ],
            );
          },
        ) ??
        false; // Si se cierra el diálogo sin respuesta, devolver false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Editar Perfil'),
        backgroundColor: Colores.principal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colores.principal,
                  backgroundImage: _imagenPerfil != null
                      ? FileImage(
                          _imagenPerfil!) // Muestra la imagen seleccionada
                      : widget.perfil.FotoPerfil.isNotEmpty
                          ? null // Muestra la imagen cargada si ya existe
                          : null,
                  child: _imagenPerfil == null &&
                          widget.perfil.FotoPerfil.isEmpty
                      ? Text(
                          widget.perfil
                              .nombre[0], // Inicial del nombre si no hay imagen
                          style: const TextStyle(
                            color: Colores.texto,
                            fontSize: 30,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'nombre del perfil',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'PIN Actual',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinVisible = !_isPinVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPinVisible,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPinController,
                decoration: InputDecoration(
                  labelText: 'Nuevo PIN',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinVisible = !_isPinVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPinVisible,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _fechaController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.botones, // Color del botón
                ),
                child: const Text('Guardar Cambios'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _eliminarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.eliminar, // Color del botón
                ),
                child: const Text('Eliminar Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
