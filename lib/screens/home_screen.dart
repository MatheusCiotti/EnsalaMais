import 'package:flutter/material.dart';
import 'package:sala/models/class.dart';
import 'package:sala/services/classes_service.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/app_drawer.dart';
import 'schedule_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  bool _showFilters = false;

  String? _selectedDisciplina;
  String? _selectedSala;
  String? _selectedCurso;
  String? _selectedProfessor;

  final List<String> _disciplinas = ['Matemática', 'Português', 'História'];
  final List<String> _salas = ['Sala 101', 'Sala 202', 'Sala 303'];
  final List<String> _cursos = ['Engenharia', 'Direito', 'Administração'];
  final List<String> _professores = ['Ana', 'Carlos', 'Beatriz'];

//  List<Map<String, dynamic>> _aulas = [];
//bool _isLoadingAulas = true;

List<Class> _aulas = [];
bool _isLoadingAulas = true;



@override
void initState() {
  super.initState();
  initializeDateFormatting('pt_BR', null);
  _loadUserData();
  _loadAulas();
}

Future<void> _loadAulas() async {
  try {
    final aulas = await ClassesService.getClasses();
    setState(() {
      _aulas = aulas;
      _isLoadingAulas = false;
    });   
  } catch (e) {
    setState(() => _isLoadingAulas = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar aulas: $e')),
    );
  }
}



  Future<void> _loadUserData() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['full_name'] as String? ?? 'Usuário';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/tela.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
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
                            _userName ?? 'Usuário',
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
                  Center(
                    child: Text(
                      DateFormat('EEEE, d \'de\' MMMM', 'pt_BR')
                          .format(DateTime.now()),
                      style: const TextStyle(
                        color: Color.fromRGBO(8, 66, 66, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filtro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      foregroundColor: const Color.fromRGBO(8, 66, 66, 1),
                    ),
                  ),

                  if (_showFilters) ...[
                    const SizedBox(height: 10),
                    _buildDropdownFilter(
                        'Disciplina', _disciplinas, _selectedDisciplina,
                        (value) {
                      setState(() {
                        _selectedDisciplina = value;
                      });
                    }),
                    const SizedBox(height: 10),
                    _buildDropdownFilter('Sala', _salas, _selectedSala,
                        (value) {
                      setState(() {
                        _selectedSala = value;
                      });
                    }),
                    const SizedBox(height: 10),
                    _buildDropdownFilter('Curso', _cursos, _selectedCurso,
                        (value) {
                      setState(() {
                        _selectedCurso = value;
                      });
                    }),
                    const SizedBox(height: 10),
                    _buildDropdownFilter(
                        'Professor', _professores, _selectedProfessor,
                        (value) {
                      setState(() {
                        _selectedProfessor = value;
                      });
                    }),
                  ],

                  const SizedBox(height: 20),

                  Expanded(
  child: _isLoadingAulas
      ? const Center(child: CircularProgressIndicator())
      : _aulas.isEmpty
          ? const Center(child: Text('Nenhuma aula encontrada'))
          : ListView.builder(
              itemCount: _aulas.length,
              itemBuilder: (context, index) =>
                  _buildClassCardFromData(_aulas[index]),
            ),
),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String label, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color.fromRGBO(8, 66, 66, 1),
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
    );
  }

  
Widget _buildClassCardFromData(Class aula) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aula.name ?? 'Sem título',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(8, 66, 66, 1),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 30, color: Colors.green),
                    const SizedBox(width: 6),
//HORARIO DE AULA                    
                    Text(
  aula.schedule ?? '00:00',
  style: const TextStyle(
    color: Color.fromARGB(255, 0, 0, 0), // Altere para a cor desejada
    fontSize: 16,
    fontWeight: FontWeight.w500,
  ),
),

                  ],
                ),
                const SizedBox(height: 4),

//PROFESSOR
                Text(
  'Prof. ${aula.professorName ?? 'Desconhecido'}',
  style: const TextStyle(
    color: Color.fromARGB(255, 0, 0, 0), // ou outra cor
    fontSize: 14,
    fontStyle: FontStyle.italic,
  ),
),

              ],
            ),
          ),
        ),

//PARTE VERDE ONDE MOSTRA A SALA
        Container(
  height: 110,
  width: 130, // ou 120, ajuste conforme seu layout
  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
  decoration: const BoxDecoration(
    color: Color(0xFF062825),
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(16),
      bottomRight: Radius.circular(16),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text(
        'Sala',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      Text(
        aula.roomName ?? 'Sala ?',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
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