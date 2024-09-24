// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/Model/usuario.dart';
import 'package:smart_family/View/Inicio/register.dart';
import 'package:smart_family/View/Inicio/seleccionPerfil.dart';
import 'package:smart_family/View/Modulos/resumen.dart';
import 'package:smart_family/components/background.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_family/components/colores.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const Text(
                "LOGIN",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colores.texto, // Naranja
                    fontSize: 36),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _emailOrPhoneController,
                decoration: const InputDecoration(
                    labelText: "Correo o número de teléfono",
                    labelStyle: TextStyle(color: Colores.texto), // Gris Oscuro
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colores.texto), // Gris Oscuro
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colores.texto), // Gris Oscuro
                    )),
                style: const TextStyle(color: Colores.texto), // Gris Oscuro
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  labelStyle:
                      const TextStyle(color: Colores.texto), // Gris Oscuro
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colores.texto), // Gris Oscuro
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colores.texto), // Gris Oscuro
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colores.texto, // Gris Oscuro
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                style: const TextStyle(color: Colores.texto), // Gris Oscuro
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: const Text(
                "No recuerdo mi contraseña",
                style: TextStyle(fontSize: 12, color: Colores.texto), // Naranja
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  padding: const EdgeInsets.all(0),
                  textStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  width: size.width * 0.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      color: Colores.botones), // Fondo Naranja
                  padding: const EdgeInsets.all(0),
                  child: const Text(
                    "INICIAR SESIÓN",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white), // Texto Blanco
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()))
                },
                child: const Text(
                  "¿No tienes una cuenta? Registrate ahora",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colores.texto), // Naranja
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _login() async {
    String emailOrPhone = _emailOrPhoneController.text;
    String password = _passwordController.text;

    ServicioUsuarios servicioUsuarios = ServicioUsuarios();
    Usuario? usuario = await servicioUsuarios.login(emailOrPhone, password);
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    if (usuario != null) {
      if (preferencias.getInt('IdUsuario') == null) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: SeleccionPerfil(IdUsuario: usuario.Id),
          ),
        );
      } else {
        int? preferenciaPerfil = preferencias.getInt('IdUsuario');
        print("preferenciaPerfil = $preferenciaPerfil");
        Perfiles? perfil;
        if (preferenciaPerfil != null) {
          perfil = await ServicioPerfiles().getPerfilById(preferenciaPerfil);
        }
        if (perfil != null) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: ResumenScreen(perfil: perfil),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Correo, teléfono o contraseña incorrectos')),
      );
    }
  }
}
