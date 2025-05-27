// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName; // Armazena o nome do usuário
  //bool _isLoading = false; // Controla o estado de carregamento para logout

@override
void initState() {
  super.initState();
  _initializeDateFormattingAndLoadUser();
}

Future<void> _initializeDateFormattingAndLoadUser() async {
  await initializeDateFormatting('pt_BR', null);  // aguarde a inicialização correta
  _loadUserData();
}


  // Função para carregar os dados do usuário logado
  Future<void> _loadUserData() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['full_name'] as String? ?? 'Usuário';
      });
    }
  }
/*
  // Função para realizar o logout
  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    //final double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Fundo com imagem personalizada
            Positioned.fill(
              child: Image.asset(
                'assets/images/tela.png',
                fit: BoxFit.cover,
              ),
            ),

            // Conteúdo da tela
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho com logo e nome do usuário
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/Logo.png',
                        height: 80,
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Bem-vindo,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            _userName ?? 'Carregando...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

// Envolva o Text com o widget Center
Center(
  child: Text(
    // A data formatada dinamicamente
    DateFormat('EEEE, d \'de\' MMMM', 'pt_BR').format(DateTime.now()),
    style: const TextStyle(
      color: Color.fromRGBO(8, 66, 66, 1),
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
  ),
),


                  // Filtros
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildDropdownButton('Disciplina'),
                      _buildDropdownButton('Sala', selected: true),
                      _buildDropdownButton('Curso'),
                      _buildDropdownButton('Professor'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Lista de aulas
                  Expanded(
                    child: ListView.builder(
                      itemCount: 4, // Quantidade de aulas
                      itemBuilder: (context, index) => _buildClassCard(),
                    ),
                  ),

/*                  // Botão de logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _isLoading ? null : _handleLogout,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sair'),
                    ),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown personalizado com destaque opcional
  Widget _buildDropdownButton(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.3),
        border: selected ? Border.all(color: Colors.blue) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
               color: Color.fromRGBO(8, 66, 66, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_down, color: Color.fromRGBO(8, 66, 66, 1)),
        ],
      ),
    );
  }

  // Card que representa uma aula
  Widget _buildClassCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Parte esquerda com informações
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Matemática Aplicada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                       color: Color.fromRGBO(8, 66, 66, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.circle, size: 30, color: Colors.green),
                      SizedBox(width: 6),
                      Text('19:00 - 19:50'),
                      
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Prof. Gustavo Menegestions'),
                  
                ],
              ),
            ),
          ),
          // Parte direita com bloco e sala
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFF062825),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Bloco C',
                  style: TextStyle(
                    color: Colors.white,
                          fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sala 18',
                  style: TextStyle(
                          fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}