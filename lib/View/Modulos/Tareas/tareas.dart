import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/tareas.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class TareasPage extends StatefulWidget {
  final Perfiles perfil; // Identificador del perfil del usuario
  const TareasPage({super.key, required this.perfil});

  @override
  State<TareasPage> createState() => TareasState();
}

class TareasState extends State<TareasPage> {
  List<Tareas> tareas = [];

  @override
  void initState() {
    super.initState();
    cargarTareas(); // Cargar tareas al iniciar
  }

  Future<void> cargarTareas() async {
    try {
      
      List<Tareas> tareasObtenidas =
          await ServicioTareas().getTareas(widget.perfil.Id);
      print("Número de tareas obtenidas: ${tareasObtenidas.length}");

      setState(() {
        tareas = tareasObtenidas;
      });
    } catch (e) {
      print('Error al cargar las tareas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondoAux,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipPath(
          clipper: CurvedAppBarClipper(),
          child: AppBar(
            backgroundColor: Colores.botonesSecundarios,
            title: const Center(
              child: Text(
                'Tareas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: const BoxDecoration(
                  color: Colores.fondo,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colores.texto),
                  onPressed: _showPopup,
                ),
              ),
            ],
            leading: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: const BoxDecoration(
                color: Colores.fondo,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.checklist_outlined, color: Colores.texto),
                onPressed: _showPopup,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Usted tiene ${tareas.length} tareas",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: tareas.isNotEmpty
                  ? ListView.builder(
                      itemCount: tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = tareas[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CartaTarea(
                            title: tarea.Nombre,
                            company: "ID: ${tarea.Id}",
                            date: "Prioridad: ${tarea.Prioridad}",
                            progress: tarea.Progreso,
                            remainingTime: "Estado: ${tarea.Descripcion}",
                            avatars: const [
                              "https://randomuser.me/api/portraits/women/1.jpg"
                            ],
                          ),
                        );
                      },
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "¡No tienes tareas pendientes!",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Crea tu primera tarea ahora.",
                          style: TextStyle(fontSize: 14, color: Colors.black38),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      
    );
  }

  void _showPopup() {}
}

class CartaTarea extends StatelessWidget {
  final String title;
  final String company;
  final String date;
  final int progress;
  final String remainingTime;
  final List<String> avatars;

  const CartaTarea({
    super.key,
    required this.title,
    required this.company,
    required this.date,
    required this.progress,
    required this.remainingTime,
    required this.avatars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.more_vert),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            company,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: avatars
                .map((url) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(url),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey.shade300,
                  color: Colores.botones,
                ),
              ),
              const SizedBox(width: 8),
              Text("$progress%", style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            remainingTime,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
