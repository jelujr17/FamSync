import 'package:famsync/components/Inicio/FirebaseAuthService.dart';
import 'package:famsync/View/Inicio/Seleccion_Perfil.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isShowLoading = false;
  bool isShowConfetti = false;
  bool _isPasswordVisible =
      false; // Variable para controlar la visibilidad de la contraseña
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

  void signIn(BuildContext context) async {
    setState(() {
      isShowConfetti = true;
      isShowLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      // Usar FirebaseAuthService en lugar de ServicioUsuarios
      FirebaseAuthService authService = FirebaseAuthService();

      // Llamar al método login del nuevo servicio
      final result = await authService.login(email, password);

      
      if (result['success']) {
        // Login exitoso
        final user = result['user'];

        // Guardar el ID del usuario (ahora usando el UID de Firebase)

        // Animación de éxito
        success.fire();
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          isShowLoading = false;
        });

        confetti.fire();

        Future.delayed(const Duration(seconds: 1), () async {
          if (!context.mounted) return;

          // Si no se encuentra el perfil, ir a selección
          Navigator.push(
            context,
            MaterialPageRoute(
              // Usar el UID de Firebase como ID de usuario
              builder: (context) => SeleccionPerfil(UID: user.uid),
            ),
          );
        });
      } else {
        // Login fallido
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );

        error.fire();
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          isShowLoading = false;
        });

        reset.fire();
      }
    } else {
      // Formulario inválido
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
              const Text(
                "Contraseña",
                style: TextStyle(color: Colores.texto),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText:
                      !_isPasswordVisible, // Controla la visibilidad de la contraseña
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Por favor ingrese su contraseña";
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
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    signIn(context);
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
                  label: const Text("Iniciar Sesión",
                      style: TextStyle(color: Colores.texto)),
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
