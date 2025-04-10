import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoTiendaEditar extends StatefulWidget {
  final String? Function(String?)? validator;
  final List<String> nombresTienda;
  final Function(String) onTiendaSeleccionada;
  final Productos producto;

  const CampoTiendaEditar({
    super.key,
    required this.validator,
    required this.nombresTienda,
    required this.onTiendaSeleccionada,
    required this.producto,
  });

  @override
  CampoTiendaEditarState createState() => CampoTiendaEditarState();
}

class CampoTiendaEditarState extends State<CampoTiendaEditar> {
  late TextEditingController _tiendaController;
  String? tiendaSeleccionada;

  @override
  void initState() {
    super.initState();
    _tiendaController = TextEditingController(text: widget.producto.Tienda);
    tiendaSeleccionada = widget.producto.Tienda;
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
          labelStyle: const TextStyle(fontSize: 16, color: Colores.texto),
          hintText: 'Ingresa una tienda para el producto',
          hintStyle: TextStyle(color: Colores.texto),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.store, color: Colores.texto),
          filled: true,
          fillColor: Colores.fondoAux, // Fondo del campo de entrada
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colores.texto, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        dropdownColor: Colores.fondoAux, // Fondo del menú desplegable
        items: widget.nombresTienda.map((String tienda) {
          return DropdownMenuItem<String>(
            value: tienda,
            child: Text(
              tienda,
              style: const TextStyle(color: Colores.texto), // Color del texto
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
          color: Colores.texto, // Color del texto seleccionado
        ),
        validator: widget.validator,
      ),
    );
  }
}