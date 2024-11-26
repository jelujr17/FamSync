import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/modulos.dart';

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
    this.bgColor = Colors.blue,
    this.textColor = Colors.white,
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
        title: 'Welcome, ${widget.perfil.Nombre}!',
        description: 'We are glad to have you here.',
        image: 'assets/welcome.png',  // Asegúrate de tener una imagen de bienvenida.
        bgColor: Colors.indigo,
      ),
    ];

    if (eventosDiarios.isNotEmpty) {
      pages.add(
        ResumenModelo(
          title: 'Eventos de hoy:',
          description: 'Your events for today.',
          image: '',
          bgColor: Colors.purple,
          textColor: Colors.white,
        ),
      );
    }

    if (listas.isNotEmpty) {
      pages.add(
        ResumenModelo(
          title: 'Tus listas',
          description: 'Manage your lists efficiently.',
          image: '',
          bgColor: Colors.teal,
          textColor: Colors.white,
        ),
      );
    }

    pages.add(
      ResumenModelo(
        title: 'You are ready!',
        description: 'Tap finish to start using the app.',
        image: '',
        bgColor: Colors.blueAccent,
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
                ? [pages[_currentPage].bgColor, Colors.blueAccent]
                : [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: item.image.isNotEmpty
                                ? Image.asset(item.image)
                                : const SizedBox(),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: item.textColor,
                                        )),
                              ),
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 280),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 8.0),
                                child: Text(item.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: item.textColor)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
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
                          "Skip",
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
                        _currentPage == pages.length - 1 ? "Finish" : "Next",
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
}
