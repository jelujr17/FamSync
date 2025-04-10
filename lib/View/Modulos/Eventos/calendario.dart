import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/Provider/Tareas_Provider.dart';
import 'package:famsync/View/Modulos/Tareas/Crear_Tarea.dart';
import 'package:famsync/components/colores.dart';
import 'package:famsync/components/iconos_SVG.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PerfilProvider extends InheritedWidget {
  final Perfiles perfil;

  const PerfilProvider({
    super.key,
    required this.perfil,
    required super.child,
  });

  static PerfilProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PerfilProvider>();
  }

  @override
  bool updateShouldNotify(PerfilProvider oldWidget) {
    return perfil != oldWidget.perfil;
  }
}

class Calendario extends StatefulWidget {
  const Calendario({super.key, required this.perfil});
  final Perfiles perfil;

  @override
  CalendarioState createState() => CalendarioState();
}

class CalendarioState extends State<Calendario> {
  bool modo = false; // Modo de vista de tareas (false = "Baja", true = "Media")

  void _cambiarModo(bool nuevoModo) {
    setState(() {
      modo = nuevoModo; // Cambiar el modo al nuevo valor
    });
  }

  bool isSearching = false; // Bandera para saber si se está buscando

  bool isLoading = true;
  String errorMessage = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Color getContrastingTextColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo usando la fórmula de luminancia relativa
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Si el color es oscuro, usar texto blanco; si es claro, usar texto fondoAux
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Perfiles get perfil => widget.perfil;

  void _crearTarea(BuildContext context) async {
    // Implementa la lógica para editar el producto
    // Por ejemplo, puedes navegar a una página de edición de producto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearTarea(perfil: widget.perfil),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true); // Se realizó una actualización
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tareasProvider =
        Provider.of<TareasProvider>(context, listen: true); // Escuchar cambios
    final categoriasProvider =
        Provider.of<CategoriasProvider>(context, listen: true);

    // Actualizar los estados de las tareas cada vez que cambien

    final tareasAux = tareasProvider.tareas;
    final DateTime now = DateTime.now(); // Fecha actual
    final String diaSemana =
        DateFormat('EEEE', 'es_ES').format(now); // Día de la semana en español

    return PerfilProvider(
      perfil: widget.perfil,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Calendario",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colores.texto, fontWeight: FontWeight.bold),
                ),
              ),
              BarraCalendario(
                searchController: _searchController,
                crearTarea: _crearTarea,
                cambiarModo: (nuevoModo) {
                  _cambiarModo(nuevoModo); // Actualizar el modo
                },
                modo: modo,
              ),
              if (modo) const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  diaSemana, // Mostrar el día de la semana
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colores.texto,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarraCalendario extends StatelessWidget {
  const BarraCalendario({
    super.key,
    required this.searchController,
    required this.crearTarea,
    required this.cambiarModo,
    required this.modo,
  });

  final TextEditingController searchController;
  final Function(BuildContext) crearTarea;
  final Function(bool) cambiarModo; // Cambiar el modo con un valor booleano
  final bool modo; // Modo de vista de tareas

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón "Baja"
          _buildMododButton(context, 'Hoy', !modo, () {
            cambiarModo(false); // Cambiar a modo "Baja"
          }),
          // Botón "Media"
          _buildMododButton(context, 'Calendario', modo, () {
            cambiarModo(true); // Cambiar a modo "Media"
          }),
          const SizedBox(width: 16),
          IconoContador(
            svgSrc: Iconos_SVG.masIcono,
            press: () {
              crearTarea(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMododButton(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Llamar al callback al hacer clic
      child: Container(
        width: MediaQuery.of(context).size.width /
            4, // Una cuarta parte del ancho de la pantalla
        height: 50, // Altura fija para los botones
        decoration: BoxDecoration(
          color: isSelected ? Colores.fondoAux : Colores.fondo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colores.fondoAux : Colores.fondoAux,
            width: 2,
          ),
        ),
        child: Center(
          // Centrar el texto dentro del botón
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colores.texto : Colores.fondoAux,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class IconoContador extends StatelessWidget {
  const IconoContador({
    super.key,
    required this.svgSrc,
    required this.press,
  });

  final String svgSrc;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46, // Altura del contenedor
            width: 46, // Anchura del contenedor (más largo horizontalmente)
            decoration: BoxDecoration(
              color: Colores.fondoAux,
              borderRadius: BorderRadius.circular(
                  23), // Bordes redondeados para forma ovalada
            ),
            child: SvgPicture.string(
              svgSrc,
              color: Colores.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class TopRoundedContainer extends StatelessWidget {
  const TopRoundedContainer({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: child,
    );
  }
}
