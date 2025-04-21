import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class CampoFechasCrearEvento extends StatelessWidget {
  final DateTime? fecha;
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFin;
  final bool todoElDia;
  final void Function(DateTime?) onFechaChanged;
  final void Function(TimeOfDay?) onHoraInicioChanged;
  final void Function(TimeOfDay?) onHoraFinChanged;
  final void Function(bool) onTodoElDiaChanged;
  final String? Function(DateTime?)? validatorFecha;
  final String? Function(TimeOfDay?)? validatorHoraInicio;
  final String? Function(TimeOfDay?)? validatorHoraFin;

  const CampoFechasCrearEvento({
    super.key,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.todoElDia,
    required this.onFechaChanged,
    required this.onHoraInicioChanged,
    required this.onHoraFinChanged,
    required this.onTodoElDiaChanged,
    this.validatorFecha,
    this.validatorHoraInicio,
    this.validatorHoraFin,
  });

  Future<void> _selectTime(BuildContext context, TimeOfDay? initialTime,
      void Function(TimeOfDay?) onChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 0, minute: 0),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.fondoAux, // Fondo fondoAux para toda la sección
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        padding: const EdgeInsets.all(12), // Espaciado interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha',
              style: const TextStyle(fontSize: 16, color: Colores.texto),
            ),
            const SizedBox(height: 8),
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.single,
                selectedDayHighlightColor: Colores.texto,
                selectedDayTextStyle: const TextStyle(
                  color: Colores
                      .fondoAux, // <-- Color del número del día seleccionado
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                weekdayLabelTextStyle: const TextStyle(
                  color: Colores.texto,
                  fontWeight: FontWeight.bold,
                ),
                dayTextStyle: const TextStyle(
                  color: Colores.texto,
                  fontSize: 12,
                ),
                controlsTextStyle: const TextStyle(
                  color: Colores.texto,
                  fontWeight: FontWeight.bold,
                ),
                // Puedes ajustar más estilos aquí según tu diseño
              ),
              value: fecha != null ? [fecha!] : [],
              onValueChanged: (dates) {
                onFechaChanged(dates.isNotEmpty ? dates.first : null);
              },
            ),
            if (validatorFecha != null)
              Builder(
                builder: (context) {
                  final error = validatorFecha!(fecha);
                  if (error != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(error,
                          style: const TextStyle(color: Colors.red)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Switch(
                  value: todoElDia,
                  onChanged: onTodoElDiaChanged,
                  activeColor: Colores.texto,
                ),
                const Text(
                  "Todo el día",
                  style: TextStyle(fontSize: 16, color: Colores.texto),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!todoElDia) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hora de inicio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hora de inicio',
                          style: TextStyle(fontSize: 14, color: Colores.texto),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colores.texto,
                            side: BorderSide(
                                color: Colores.texto.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _selectTime(
                              context, horaInicio, onHoraInicioChanged),
                          child: Text(
                            horaInicio != null
                                ? "${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}"
                                : " Selecciona hora ",
                            style: const TextStyle(
                                fontSize: 16, color: Colores.fondoAux),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hora de fin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hora de fin',
                          style: TextStyle(fontSize: 14, color: Colores.texto),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colores.texto,
                            side: BorderSide(
                                color: Colores.texto.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: horaInicio == null
                              ? null
                              : () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: horaFin ??
                                        const TimeOfDay(hour: 0, minute: 0),
                                  );
                                  if (picked != null) {
                                    // Solo permitir si la hora de fin es después de la de inicio
                                    final inicio = horaInicio!;
                                    final fin = picked;
                                    final inicioMinutes =
                                        inicio.hour * 60 + inicio.minute;
                                    final finMinutes =
                                        fin.hour * 60 + fin.minute;
                                    if (finMinutes > inicioMinutes) {
                                      onHoraFinChanged(picked);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'La hora de fin debe ser posterior a la de inicio'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: Text(
                            horaFin != null
                                ? "${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}"
                                : " Selecciona hora ",
                            style: const TextStyle(
                                fontSize: 16, color: Colores.fondoAux),
                          ),
                        ),
                        // Mensaje de error visual si la hora de fin es anterior o igual a la de inicio
                        if (horaInicio != null && horaFin != null)
                          if ((horaFin!.hour * 60 + horaFin!.minute) <=
                              (horaInicio!.hour * 60 + horaInicio!.minute))
                            const Padding(
                              padding: EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                'La hora de fin debe ser posterior a la de inicio',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
