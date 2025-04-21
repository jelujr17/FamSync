import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendario siempre visible
          Text(
            'Fecha',
            style: const TextStyle(fontSize: 16, color: Colores.texto),
          ),
          const SizedBox(height: 8),
          // Calendario más pequeño y con colores personalizados
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colores.texto, // Color de selección
                onPrimary: Colors.white, // Color del texto seleccionado
                surface: Colores.fondoAux, // Fondo del calendario
                onSurface: Colores.texto, // Color de los días normales
              ),
              textTheme: Theme.of(context).textTheme.copyWith(
                    bodyMedium:
                        const TextStyle(fontSize: 12), // Tamaño de los días
                  ),
            ),
            child: SizedBox(
              height: 260, // Ajusta la altura para hacerlo más pequeño
              width: 100,
              child: CalendarDatePicker(
                initialDate: fecha ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: onFechaChanged,
                currentDate: DateTime.now(),
                selectableDayPredicate: (_) => true,
              ),
            ),
          ),
          if (validatorFecha != null)
            Builder(
              builder: (context) {
                final error = validatorFecha!(fecha);
                if (error != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8),
                    child:
                        Text(error, style: const TextStyle(color: Colors.red)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          const SizedBox(height: 20),
          // Switch "Todo el día"
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
          // Horas solo si no es todo el día
          if (!todoElDia) ...[
            Text(
              'Hora de inicio',
              style: const TextStyle(fontSize: 16, color: Colores.texto),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  _selectTime(context, horaInicio, onHoraInicioChanged),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Selecciona la hora de inicio',
                    prefixIcon:
                        const Icon(Icons.access_time, color: Colores.texto),
                    filled: true,
                    fillColor: Colores.fondoAux,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                  ),
                  controller: TextEditingController(
                    text: horaInicio != null
                        ? "${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}"
                        : '',
                  ),
                  style: const TextStyle(color: Colores.texto),
                  validator: (_) => validatorHoraInicio?.call(horaInicio),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Hora de fin',
              style: const TextStyle(fontSize: 16, color: Colores.texto),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectTime(context, horaFin, onHoraFinChanged),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Selecciona la hora de fin',
                    prefixIcon:
                        const Icon(Icons.access_time, color: Colores.texto),
                    filled: true,
                    fillColor: Colores.fondoAux,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                  ),
                  controller: TextEditingController(
                    text: horaFin != null
                        ? "${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}"
                        : '',
                  ),
                  style: const TextStyle(color: Colores.texto),
                  validator: (_) => validatorHoraFin?.call(horaFin),
                  readOnly: true,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
