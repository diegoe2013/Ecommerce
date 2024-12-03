import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untitled/Controllers/auth.dart';
import 'home.dart';
import 'welcome.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService(); 
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool obscureText = true; // ocultar o mostrar la contraseña.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // Margen superior.
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Good to see you back!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'email',
                      decoration: InputDecoration(
                        hintText: 'Email',
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'El correo es obligatorio',
                        ),
                        FormBuilderValidators.email(
                          errorText: 'Ingrese un correo válido',
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'password',
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        fillColor: Colors.grey[200],
                        filled: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText; // Cambiar el estado.
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'La contraseña es obligatoria',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // onPressed: () async {
                  //   if (_formKey.currentState?.saveAndValidate() == true) {
                  //     final formData = _formKey.currentState?.value;
                  //     final result = await _auth.signInEmailAndPassword(
                  //       formData?['email'],
                  //       formData?['password'],
                  //     );

                  //     if (result == 1) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(
                  //           content: Text('Usuario no encontrado.'),
                  //           backgroundColor: Colors.red,
                  //         ),
                  //       );
                  //     } else if (result == 2) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(
                  //           content: Text('Contraseña incorrecta.'),
                  //           backgroundColor: Colors.red,
                  //         ),
                  //       );
                  //     } else if (result != null) {
                  //       Navigator.pushNamed(context, '/home');
                  //     }
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         content: Text(
                  //             'Por favor, completa todos los campos correctamente.'),
                  //         backgroundColor: Colors.orange,
                  //       ),
                  //     );
                  //   }
                  // },
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() == true) {
                      final formData = _formKey.currentState?.value;
                      final result = await _auth.signInEmailAndPassword(
                        formData?['email'],
                        formData?['password'],
                      );

                      debugPrint('Resultado del login: $result');

                      if (result == 1) {
                        // Usuario no encontrado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario no encontrado.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (result == 2) {
                        // Contraseña incorrecta
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contraseña incorrecta.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (result == 3 || result == 4) {
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuario o contraseña incorrecto'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (result != null) {
                        // Login exitoso
                        Navigator.pushNamed(context, '/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error desconocido, intente nuevamente.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, completa todos los campos correctamente'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Welcome(),
                      ),
                    );
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54),
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
