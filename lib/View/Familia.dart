import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart'; // Asegúrate de que este archivo tenga el método getPerfilById
import 'package:smart_family/View/navegacion.dart';
import 'package:smart_family/components/colores.dart';

class FamiliaScreen extends StatefulWidget {
  final int IdUsuario;
  final int Id;

  const FamiliaScreen({super.key, required this.IdUsuario, required this.Id});

  @override
  FamiliaScreenState createState() => FamiliaScreenState();
}

class FamiliaScreenState extends State<FamiliaScreen> {
  int _selectedIndex = 2;
    List<Perfiles>? _perfilesFamilia; // Cambiado a una lista de perfiles

  @override
  void initState() {
    super.initState();
    _loadPerfil(); // Cargar los datos del perfil cuando la pantalla se inicializa
  }

  Future<void> _loadPerfil() async {
    // Cargar la lista de perfiles
    List<Perfiles>? perfilesFamilia =
        await ServicioPerfiles().getPerfiles(widget.Id);
    setState(() {
      _perfilesFamilia =
          perfilesFamilia; // Actualizamos el estado con la lista de perfiles
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Perfiles?>>(
        future: ServicioPerfiles().getPerfiles(widget.Id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No profiles available'));
          } else {
            List<Perfiles?> perfilesFamilia = snapshot.data!;
            return ListView.builder(
              itemCount: perfilesFamilia.length,
              itemBuilder: (context, index) {
                Perfiles? perfil = perfilesFamilia[index];
                return Column(
                  children: [
                    const SizedBox(height: 150, child: _TopPortion()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            perfil!.Nombre,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {},
                                heroTag: 'follow_$index',
                                elevation: 0,
                                label: const Text("Follow"),
                                icon: const Icon(Icons.person_add_alt_1),
                              ),
                              const SizedBox(width: 16.0),
                              FloatingActionButton.extended(
                                onPressed: () {},
                                heroTag: 'message_$index',
                                elevation: 0,
                                backgroundColor: Colors.red,
                                label: const Text("Message"),
                                icon: const Icon(Icons.message_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _ProfileInfoRow(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: FloatingNavigationBar(
        onTabSelected: _onTabSelected,
        initialIndex: _selectedIndex,
        IdUsuario: widget.IdUsuario,
        Id: widget.Id
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({Key? key}) : super(key: key);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("Posts", 900),
    ProfileInfoItem("Followers", 120),
    ProfileInfoItem("Following", 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (_items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            item.title,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xff0043ba), Color(0xff006df1)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80')),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
