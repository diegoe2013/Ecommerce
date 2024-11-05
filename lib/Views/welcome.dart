import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'create_account.dart';
import 'login.dart';

class Welcome extends StatelessWidget {
    const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de la tienda 
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.orange[50],
                child: SvgPicture.asset(
                  'assets/icons/shopp_icon.svg',
                  width: 40, 
                  height: 40,
                ),
              ),
              const SizedBox(height: 24),
              
             
              const Text(
                'ShopHub',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtítulo
              const Text(
                'Discover Better Deals,\nAll in One Place',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Botón "Let's get started"
              ElevatedButton(
                onPressed: () {
                  // Navegación a la pantalla de crear cuenta
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateAccount()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cambiado de primary a backgroundColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                ),
                child: const Text(
                  "Let's get started",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Texto "I already have an account" con icono de flecha
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "I already have an account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navegación a la pantalla de login
                    
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}