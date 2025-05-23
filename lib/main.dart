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
      home: const LoginScreen(), // Tela inicial
    );
  }
}

// Tela de Login
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fundo com gradiente verde
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade700], // Cores do gradiente
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Espaçamento interno
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Centraliza os widgets verticalmente
            children: [
              Image.asset('assets/images/Logo.png', height: 200), // Logo do app
              SizedBox(height: 100), // Espaço entre logo e campo de usuário


              // Campo de texto para o usuário
              TextField(
  decoration: InputDecoration(
    hintText: 'Digite seu usuário',
    hintStyle: TextStyle(
      color: Colors.white,  // Cor do hint text
      fontSize: 16,
    ),
    prefixIcon: Icon(
      Icons.person,
      color: Colors.white,  // Cor do ícone
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.2),
  ),
),


              SizedBox(height: 15), // Espaço entre os campos

TextField(
  obscureText: true,
  decoration: InputDecoration(
    hintText: 'Digite sua senha',
    hintStyle: TextStyle(
      color: Colors.white,  // Cor do hint text
      fontSize: 16,
    ),
    prefixIcon: Icon(
      Icons.lock,
      color: Colors.white,  // Cor do ícone
    ),
    suffixIcon: Icon(
      Icons.visibility,
      color: Colors.white,  // Cor do ícone
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.2),
  ),
),


              SizedBox(height: 20), // Espaço antes do botão

              // Botão de "Entrar"
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(), // Bordas arredondadas estilo "pílula"
                  backgroundColor: Colors.orange, // Cor do botão
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50), // Ocupa toda a largura
                ),
                  
                onPressed: () {}, // Ação ao clicar (vazio por enquanto)
                child: Text('Entrar'),
              ),

              SizedBox(height: 30), // Espaço entre os campos


              Text(
                'Primeira vez aqui ?',
                style: TextStyle(color: Colors.white),
                ),


              // Botão de "Cadastrar-se"
              TextButton(
                onPressed: () {}, // Ação ao clicar
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  
                ),
                child: Text(
                  'Cadastrar-se',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
