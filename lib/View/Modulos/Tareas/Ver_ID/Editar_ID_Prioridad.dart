import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class CampoPrioridadEditarTarea extends StatefulWidget {
  final int prioridadSeleccionada;
  final Function(int) onPrioridadSeleccionada;

  const CampoPrioridadEditarTarea({
    super.key,
    required this.prioridadSeleccionada,
    required this.onPrioridadSeleccionada,
  });

  @override
  State<CampoPrioridadEditarTarea> createState() =>
      _CampoPrioridadEditarState();
}

class _CampoPrioridadEditarState extends State<CampoPrioridadEditarTarea> {
  late int prioridadSeleccionada;

  @override
  void initState() {
    super.initState();
    // Inicializar el estado local con el valor recibido del widget padre
    prioridadSeleccionada = widget.prioridadSeleccionada;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.fondoAux, // Fondo fondoAux
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        padding: const EdgeInsets.all(12), // Espaciado interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'prioridad',
              style: TextStyle(
                color: Colores.texto, // Texto texto
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón de prioridad "Baja"
                _buildPrioridadButton(1, 'Baja', Colores.hecho),
                // Botón de prioridad "Media"
                _buildPrioridadButton(2, 'Media', Colores.naranja),
                // Botón de prioridad "Alta"
                _buildPrioridadButton(3, 'Alta', Colores.eliminar),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioridadButton(int prioridad, String label, Color color) {
    final bool isSelected = prioridadSeleccionada == prioridad;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Actualizar el estado local
          prioridadSeleccionada = prioridad;
        });
        // Propagar el valor al widget padre
        widget.onPrioridadSeleccionada(prioridad);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : Colores.fondoAux,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colores.fondoAux : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
