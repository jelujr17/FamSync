import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:flutter/material.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';

class ResumenModelo {
  final String title;
  final String description;
  final String image;
  final Color bgColor;
  final Color textColor;

  ResumenModelo({
    required this.title,
    required this.description,
    required this.image,
    this.bgColor = Colores.principal,
    this.textColor = Colores.texto,
  });
}

class Resumen extends StatefulWidget {
  final Perfiles perfil;

  const Resumen({super.key, required this.perfil});

  @override
  ResumenState createState() => ResumenState();
}

class ResumenState extends State<Resumen> {
  List<ResumenModelo> pages = [];
  List<Eventos> eventosDiarios = [];
  List<Listas> listas = [];

  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    obtenerEventosDiarios();
    obtenerListas();
  }

  void crearPaginas() {
    pages = [
      ResumenModelo(
        title: 'Bienvenido, ${widget.perfil.Nombre}!',
        description: 'Nos alegramos de verte por aquí.',
        image: 'assets/images/main.png',
        bgColor: Colores.principal,
      ),
    ];

    if (eventosDiarios.isNotEmpty) {
      pages.add(
        ResumenModelo(
          title: '',
          description: 'Tus eventos para hoy.',
          image: '',
          bgColor: Colores.botones,
          textColor: Colors.white,
        ),
      );
    }

    if (listas.isNotEmpty) {
      pages.add(
        ResumenModelo(
          title: '',
          description: 'Gestiona tus listas de manera eficiente.',
          image: '',
          bgColor: Colores.botonesSecundarios,
          textColor: Colors.white,
        ),
      );
    }

    pages.add(
      ResumenModelo(
        title: '¡Estás listo!',
        description: 'Toca terminar para comenzar a usar la app.',
        image: '',
        bgColor: Colores.principal,
      ),
    );
  }

  void obtenerEventosDiarios() async {
    List<Eventos> eventos = await ServicioEventos()
        .getEventosDiarios(widget.perfil.UsuarioId, widget.perfil.Id);
    setState(() {
      eventosDiarios = eventos;
      crearPaginas(); // Actualizar páginas tras obtener datos
    });
  }

  void obtenerListas() async {
    List<Listas> listas = await ServiciosListas()
        .getListas(widget.perfil.UsuarioId, widget.perfil.Id);
    setState(() {
      this.listas = listas;
      crearPaginas(); // Actualizar páginas tras obtener datos
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: pages.isNotEmpty
                ? [pages[_currentPage].bgColor, Colores.principal]
                : [Colores.botones, Colores.botonesSecundarios],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Aquí no usamos Expanded en el PageView.builder
              SizedBox(
                height: MediaQuery.of(context).size.height -
                    200, // Ajusta el tamaño
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = pages[idx];

                    return Column(
                      children: [
                        // Ajuste aquí, quitamos Expanded y ajustamos padding
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: item.image.isNotEmpty
                              ? Image.asset(item.image)
                              : const SizedBox(),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: item.textColor,
                                      ),
                                ),
                              ),
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 280),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 8.0),
                                child: idx == 1 // Página de eventos
                                    ? eventPageContent()
                                    : idx == 2 // Página de listas
                                        ? listPageContent()
                                        : Text(item.description,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: item.textColor)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(), // Esto empujará los botones hacia abajo

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pages
                    .map((item) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: _currentPage == pages.indexOf(item) ? 20 : 4,
                          height: 4,
                          margin: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                        ))
                    .toList(),
              ),

              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Modulos(
                                      perfil: widget.perfil,
                                    )),
                          );
                        },
                        child: const Text(
                          "Saltar",
                          style: TextStyle(color: Colors.white),
                        )),
                    TextButton(
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Modulos(
                                      perfil: widget.perfil,
                                    )),
                          );
                        } else {
                          _pageController.animateToPage(_currentPage + 1,
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 250));
                        }
                      },
                      child: Text(
                        _currentPage == pages.length - 1
                            ? "Terminar"
                            : "Siguiente",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Método para mostrar los eventos
  Widget eventPageContent() {
    if (eventosDiarios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No hay eventos para hoy.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Eventos de Hoy',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí están tus eventos programados para hoy.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              // Listado de eventos
              Column(
                children: eventosDiarios.map((evento) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(
                        evento.Nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(evento.FechaFin),
                      trailing:
                          const Icon(Icons.event_note, color: Colores.botones),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Método para mostrar las listas
  Widget listPageContent() {
    if (listas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No hay listas disponibles.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white),
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tus Listas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí están tus listas actuales.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              // Listado de listas
              Column(
                children: listas.map((lista) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(
                        lista.Nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${lista.Productos.length} productos',
                      ),
                      trailing:
                          const Icon(Icons.list_alt, color: Colores.botones),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }
  }
}
