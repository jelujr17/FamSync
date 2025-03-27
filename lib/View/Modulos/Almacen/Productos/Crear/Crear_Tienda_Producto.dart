import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoTiendaCrear extends StatefulWidget {
  final String? Function(String?)? validator;
  final List<String> nombresTienda;
  final Function(String) onTiendaSeleccionada;

  const CampoTiendaCrear({
    super.key,
    required this.validator,
    required this.nombresTienda,
    required this.onTiendaSeleccionada,
  });

  @override
  CampoTiendaCrearState createState() => CampoTiendaCrearState();
}

class CampoTiendaCrearState extends State<CampoTiendaCrear> {
  late TextEditingController _tiendaController;
  String? tiendaSeleccionada;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tiendaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: tiendaSeleccionada,
        decoration: InputDecoration(
          labelText: 'Selecciona una tienda',
          labelStyle: const TextStyle(fontSize: 16, color: Colores.amarillo),
          hintText: 'Ingresa una tienda para el producto',
          hintStyle: const TextStyle(color: Colores.negro),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.store, color: Colores.amarillo),
          filled: true,
          fillColor: Colores.negro, // Fondo del campo de entrada
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colores.amarillo, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        dropdownColor: Colores.negro, // Fondo del menú desplegable
        items: widget.nombresTienda.map((String tienda) {
          return DropdownMenuItem<String>(
            value: tienda,
            child: Text(
              tienda,
              style:
                  const TextStyle(color: Colores.amarillo), // Color del texto
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null && newValue != tiendaSeleccionada) {
            setState(() {
              tiendaSeleccionada = newValue;
            });
            widget.onTiendaSeleccionada(newValue);
          }
        },
        style: const TextStyle(
          color: Colores.amarillo, // Color del texto seleccionado
        ),
        validator: widget.validator,
      ),
    );
  }
}
