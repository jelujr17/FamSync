import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/Model/tareas.dart';

class ProgresarTareaDialog extends StatelessWidget {
  final Tareas tarea;
  final Function(int) onProgresoGuardado;
  final BuildContext context;

  const ProgresarTareaDialog({
    super.key,
    required this.tarea,
    required this.onProgresoGuardado,
    required this.context,
  });

  @override
  Widget build(context) {
    double progresoActual = tarea.Progreso.toDouble();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.fondo.withOpacity(0.95), // Fondo del diálogo
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colores.texto.withOpacity(0.3),
              offset: const Offset(0, 30),
              blurRadius: 60,
            ),
            const BoxShadow(
              color: Colores.texto,
              offset: Offset(0, 30),
              blurRadius: 60,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título del diálogo
                  Text(
                    'Modificar Progreso',
                    style: TextStyle(
                      color: Colores.texto,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Slider para modificar el progreso
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso actual: ${progresoActual.toInt()}%',
                        style: TextStyle(
                          color: Colores.texto,
                          fontSize: 14,
                        ),
                      ),
                      SfSlider(
                        min: 0.0,
                        max: 100.0,
                        value: progresoActual,
                        interval: 10,
                        showTicks: true,
                        showLabels: true,
                        activeColor: Colores.texto,
                        inactiveColor: Colores.fondoAux,
                        enableTooltip: true,
                        tooltipTextFormatterCallback:
                            (dynamic actualValue, String formattedText) {
                          return '${actualValue.toInt()}%';
                        },
                        onChanged: (dynamic value) {
                          setState(() {
                            progresoActual =
                                value; // Actualiza el progreso actual
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón para reiniciar el progreso
                      TextButton(
                        onPressed: () {
                          setState(() {
                            progresoActual = 0; // Reinicia el progreso
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colores.eliminar, width: 2),
                          ),
                          child: Text(
                            "Reiniciar",
                            style: TextStyle(
                              color: Colores.eliminar,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Botón para completar el progreso
                      TextButton(
                        onPressed: () {
                          setState(() {
                            progresoActual = 100; // Completa el progreso
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colores.hecho, width: 2),
                          ),
                          child: Text(
                            "Completar",
                            style: TextStyle(
                              color: Colores.hecho,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botones para guardar o cancelar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(this.context).pop(); // Cerrar el diálogo
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colores.fondoAux,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (Navigator.canPop(this.context)) {
                            onProgresoGuardado(progresoActual.toInt());
                          }
                        },
                        child: Text(
                          'Guardar',
                          style: TextStyle(
                            color: Colores.hecho,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
