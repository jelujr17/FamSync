import 'package:flutter/material.dart';
import 'package:famsync/Model/usuario.dart';
import 'package:famsync/View/Inicio/login.dart';
import 'package:famsync/components/background.dart';
import 'package:famsync/components/colores.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _obscureText1 = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _togglePasswordVisibility1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: const Text(
                  "REGISTRO",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colores.texto,
                      fontSize: 36),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: "Nombre",
                      labelStyle:
                          TextStyle(color: Colores.texto), // Gris Oscuro
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colores.texto), // Gris Oscuro
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colores.texto), // Gris Oscuro
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu nombre';
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colores.texto), // Gris Oscuro
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: "Número de Teléfono",
                      labelStyle:
                          TextStyle(color: Colores.texto), // Gris Oscuro
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colores.texto), // Gris Oscuro
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colores.texto), // Gris Oscuro
                      )),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu número de teléfono';
                    }
                    if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                      return 'El número de teléfono debe tener 9 dígitos';
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colores.texto), // Gris Oscuro
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: "Correo Electrónico",
                      labelStyle:
                          TextStyle(color: Colores.texto), // Gris Oscuro
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colores.texto), // Gris Oscuro
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colores.texto), // Gris Oscuro
                      )),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Por favor, ingresa un correo válido';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    labelStyle:
                        const TextStyle(color: Colores.texto), // Gris Oscuro
                    enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colores.texto), // Gris Oscuro
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colores.texto), // Gris Oscuro
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colores.texto, // Gris Oscuro
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                      return 'La contraseña debe tener al menos una mayúscula';
                    }
                    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                      return 'La contraseña debe tener al menos una minúscula';
                    }
                    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                      return 'La contraseña debe tener al menos un número';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirmar Contraseña",
                    labelStyle:
                        const TextStyle(color: Colores.texto), // Gris Oscuro
                    enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colores.texto), // Gris Oscuro
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colores.texto), // Gris Oscuro
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText1 ? Icons.visibility : Icons.visibility_off,
                        color: Colores.texto, // Gris Oscuro
                      ),
                      onPressed: _togglePasswordVisibility1,
                    ),
                  ),
                  obscureText: _obscureText1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Container(
                alignment: Alignment.centerRight,
                margin:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      /*bool registrado = await ServicioUsuarios()
                          .registrarUsuario(
                              int.parse(_phoneController.text),
                              _emailController.text,
                              _nameController.text,
                              _passwordController.text);

                      if (registrado) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Usuario registrado exitosamente')),
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'El correo o el teléfono ya están registrados')),
                        );
                      }*/
                    }
                  },
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
                      "REGISTRARSE",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white), // Texto Blanco
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                margin:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()))
                  },
                  child: const Text(
                    "¿Ya tienes una cuenta? Inicia sesión",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colores.texto),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
