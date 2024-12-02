import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:untitled/Controllers/auth.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'choose_account_type.dart';
import 'welcome.dart';

class CreateAccount extends StatefulWidget {
  CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool obscureText = true; // Estado para mostrar/ocultar contraseña.
  late String autoincrementIndex;
  final dbHelper = DBHelper();

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
              const SizedBox(height: 60), // Margen superior para el título.
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  // Acción al presionar el icono de la cámara
                },
                child: SvgPicture.asset(
                  'assets/icons/camera_icon.svg',
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(height: 24),
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'name',
                      decoration: InputDecoration(
                        hintText: 'Name',
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'El nombre es obligatorio',
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      obscureText: obscureText, // Controla la visibilidad.
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
                              obscureText =
                                  !obscureText; // Alternar visibilidad.
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'La contraseña es obligatoria',
                        ),
                        FormBuilderValidators.minLength(6,
                            errorText:
                                'La contraseña debe tener al menos 6 caracteres'),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'phone',
                      decoration: InputDecoration(
                        hintText: 'Your number',
                        fillColor: Colors.grey[200],
                        filled: true,
                        prefixIcon: const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: FormBuilderValidators.required(
                        errorText: 'El número es obligatorio',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderDateTimePicker(
                      name: 'birthDate',
                      inputType: InputType.date,
                      decoration: InputDecoration(
                        hintText: 'Birthdate',
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      validator: FormBuilderValidators.required(
                        errorText: 'La fecha de nacimiento es obligatoria',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() == true) {
                      final formData = _formKey.currentState?.value;

                      final result = await _auth.createAcount(
                        formData?['email'],
                        formData?['password'],
                      );

                      if (result == 1) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Text('Error'),
                            content: Text('La contraseña es demasiado débil'),
                          ),
                        );
                      } else if (result == 2) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Text('Error'),
                            content: Text('El correo ya está en uso'),
                          ),
                        );
                      } else if (result != null) {
                        final birthDate = formData?['birthDate'];

                        //Datos para fireStore
                        autoincrementIndex =
                            await dbHelper.autoIncrement('users');

                        final userData = {
                          "birthDate": birthDate,
                          "createdAt": DateTime.now().toIso8601String(),
                          "updatedAt": DateTime.now().toIso8601String(),
                          "email": formData?['email'],
                          "favorites": [],
                          "id": result,
                          // 'id': autoincrementIndex, 
                          "name": formData?['name'],
                          // "password": formData?['password'], este dato esta de mas
                          "paymentMethods": {},
                          "phone": formData?['phone'],
                          "profileImageUrl": "img.png",
                          "settings": {
                            "deliveryStatusChange": false,
                            "newArrivals": false,
                            "sales": false,
                          },
                          "userType": "customer",
                        };

                        // Guardar en Firestore
                        await dbHelper.addData("users/$result", userData);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  ChooseAccountType(),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, completa todos los campos correctamente'),
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
                    'Done',
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
                    Navigator.pop(
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
