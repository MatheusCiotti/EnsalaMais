import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// App principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ensala+',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

// Tela de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Fundo com imagem
            Positioned.fill(
              child: Image.asset(
                'assets/images/tela.png',
                fit: BoxFit.cover,
              ),
            ),

            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.1),

                        // Logo
                        Image.asset(
                          'assets/images/Logo.png',
                          height: screenHeight * 0.2,
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // Campo de usuário
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Digite seu usuário',
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Campo de senha com ícone de olho funcional
                        TextField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Digite sua senha',
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Botão de "Entrar"
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                            minimumSize: Size(screenWidth, 50),
                          ),
                          onPressed: () {},
                          child: const Text('Entrar'),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        const Text(
                          'Primeira vez aqui?',
                          style: TextStyle(color: Colors.white),
                        ),

                        TextButton(
                          onPressed: () {
                            // Aqui coloca a navegação para cadastro
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Cadastrar-se',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
