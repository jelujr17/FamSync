import 'package:famsync/Model/usuario.dart';
import 'package:famsync/View/Inicio/Seleccion_Perfil.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Crear_Cuenta_Formulario extends StatefulWidget {
  const Crear_Cuenta_Formulario({super.key});

  @override
  State<Crear_Cuenta_Formulario> createState() =>
      Crear_Cuenta_Formulario_State();
}

class Crear_Cuenta_Formulario_State extends State<Crear_Cuenta_Formulario> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isShowLoading = false;
  bool isShowConfetti = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late SMITrigger error;
  late SMITrigger success;
  late SMITrigger reset;
  late SMITrigger confetti;

  void _onCheckRiveInit(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    error = controller.findInput<bool>('Error') as SMITrigger;
    success = controller.findInput<bool>('Check') as SMITrigger;
    reset = controller.findInput<bool>('Reset') as SMITrigger;
  }

  void _onConfettiRiveInit(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);
    confetti = controller.findInput<bool>("Trigger explosion") as SMITrigger;
  }

  void signUp(BuildContext context) async {
    setState(() {
      isShowConfetti = true;
      isShowLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (_formKey.currentState!.validate()) {
      String nombre = _nombreController.text;
      String email = _emailController.text;
      String telefono = _telefonoController.text;
      String password = _passwordController.text;

      // Aquí implementa la lógica para registrar al usuario
      ServicioUsuarios servicioUsuarios = ServicioUsuarios();
      int? IdUsuario = await servicioUsuarios.registrarUsuario(
          context, int.parse(telefono), email, nombre, password);
      final SharedPreferences preferencias =
          await SharedPreferences.getInstance();

      if (IdUsuario != null) {
        preferencias.setInt('IdUsuario', IdUsuario);
        success.fire();
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          isShowLoading = false;
        });

        confetti.fire();

        Future.delayed(const Duration(seconds: 1), () {
          if (!context.mounted) return;

          // Navegar a la selección de perfil después del registro exitoso
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeleccionPerfil(IdUsuario: IdUsuario),
            ),
          );
        });
      } else {
        error.fire();
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          isShowLoading = false;
        });

        reset.fire();
      }
    } else {
      error.fire();
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        isShowLoading = false;
      });

      reset.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              const Text(
                "Nombre",
                style: TextStyle(color: Colores.texto),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _nombreController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Por favor ingrese su nombre";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colores.texto),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.person_outline, color: Colores.texto),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .fondoAux, // Color del borde cuando está habilitado
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .texto, // Color del borde cuando está enfocado
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Email
              const Text(
                "Email",
                style: TextStyle(color: Colores.texto),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Por favor ingrese su correo electrónico";
                    }
                    // Validación de formato de email
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return "Por favor ingrese un correo electrónico válido";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colores.texto),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SvgPicture.asset("assets/icons/email.svg"),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .fondoAux, // Color del borde cuando está habilitado
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .texto, // Color del borde cuando está enfocado
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Teléfono
              const Text(
                "Teléfono",
                style: TextStyle(color: Colores.texto),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _telefonoController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Por favor ingrese su número de teléfono";
                    }
                    // Validar formato de teléfono (solo números)
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return "Por favor ingrese solo números";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colores.texto),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.phone, color: Colores.texto),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .fondoAux, // Color del borde cuando está habilitado
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .texto, // Color del borde cuando está enfocado
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Contraseña
              const Text(
                "Contraseña",
                style: TextStyle(color: Colores.texto),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Por favor ingrese una contraseña";
                    }
                    // Validar fuerza de contraseña
                    if (value.length < 6) {
                      return "La contraseña debe tener al menos 6 caracteres";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colores.texto),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SvgPicture.asset("assets/icons/password.svg"),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .fondoAux, // Color del borde cuando está habilitado
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .texto, // Color del borde cuando está enfocado
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colores.texto,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Confirmar Contraseña
              const Text(
                "Confirmar Contraseña",
                style: TextStyle(color: Colores.texto),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Por favor confirme su contraseña";
                    }
                    if (value != _passwordController.text) {
                      return "Las contraseñas no coinciden";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colores.texto),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SvgPicture.asset("assets/icons/password.svg"),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .fondoAux, // Color del borde cuando está habilitado
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bordes redondeados
                      borderSide: const BorderSide(
                        color: Colores
                            .texto, // Color del borde cuando está enfocado
                        width: 2.0,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colores.texto,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Botón de Registro
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    signUp(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.fondoAux,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                  icon: const Icon(
                    CupertinoIcons.arrow_right,
                    color: Colores.texto,
                  ),
                  label: Text(
                    "Crear Cuenta",
                    style: TextStyle(color: Colores.texto),
                  ),
                ),
              ),
            ],
          ),
        ),
        isShowLoading
            ? CustomPositioned(
                child: RiveAnimation.asset(
                  'assets/RiveAssets/check.riv',
                  fit: BoxFit.cover,
                  onInit: _onCheckRiveInit,
                ),
              )
            : const SizedBox(),
        isShowConfetti
            ? CustomPositioned(
                scale: 6,
                child: RiveAnimation.asset(
                  "assets/RiveAssets/confetti.riv",
                  onInit: _onConfettiRiveInit,
                  fit: BoxFit.cover,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, this.scale = 1, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 100,
            width: 100,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
