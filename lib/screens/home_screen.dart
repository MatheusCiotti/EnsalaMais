import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user.dart';
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
  User? _currentUser;
  bool _isLoadingUser = true;
  bool _isLoadingSchedule = false;
  
  List<Map<String, dynamic>> _todaySchedule = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getCurrentUserData();
      setState(() {
        _currentUser = userData;
        _userName = userData?.name ?? 'Usuário';
        _isLoadingUser = false;
      });

      // Carregar aulas baseado no tipo de usuário
      if (userData?.role == 'Aluno' && userData?.courseId != null) {
        // Aluno: carregar aulas do curso
        _loadTodaySchedule(userData!.courseId!);
      } else if (userData?.role == 'Professor') {
        // Professor: carregar suas próprias aulas
        _loadProfessorSchedule(userData!.id!);
      }
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _loadTodaySchedule(int courseId) async {
    setState(() {
      _isLoadingSchedule = true;
    });

    try {
      final schedule = await UserService.getTodayClassesByCourse(courseId);
      print('Schedule carregado para aluno: $schedule');
      setState(() {
        _todaySchedule = schedule;
        _isLoadingSchedule = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSchedule = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar horários: $e')),
        );
      }
    }
  }

  Future<void> _loadProfessorSchedule(String professorId) async {
    setState(() {
      _isLoadingSchedule = true;
    });

    try {
      final schedule = await UserService.getTodayClassesByProfessor(professorId);
      print('Schedule carregado para professor: $schedule');
      setState(() {
        _todaySchedule = schedule;
        _isLoadingSchedule = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSchedule = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar horários: $e')),
        );
      }
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.account_circle, color: Colors.white, size: 32),
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        tooltip: 'Meu Perfil',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  if (_isLoadingUser)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else
                    _buildContentBasedOnUserRole(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBasedOnUserRole() {
    if (_currentUser?.role == 'Aluno' || _currentUser?.role == 'Professor') {
      return _buildScheduleContent();
    } else if (_currentUser?.role == 'Administração' || _currentUser?.role == 'Área técnica') {
      return _buildWelcomeContent();
    } else {
      // Fallback para outros tipos de usuário
      return _buildWelcomeContent();
    }
  }

  Widget _buildScheduleContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 20),
          
          Text(
            _currentUser?.role == 'Professor' ? 'Suas aulas de hoje:' : 'Suas aulas de hoje:',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          
          Expanded(
            child: _isLoadingSchedule
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _todaySchedule.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma aula hoje!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aproveite seu dia livre 😊',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _todaySchedule.length,
                        itemBuilder: (context, index) =>
                            _buildScheduleCard(_todaySchedule[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.waving_hand,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo ao EnsalaMais!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sistema de gerenciamento de salas e horários',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Acesse o menu lateral para:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(Icons.room, 'Gerenciar salas'),
                  _buildFeatureItem(Icons.schedule, 'Visualizar horários'),
                  _buildFeatureItem(Icons.class_, 'Administrar aulas'),
                  _buildFeatureItem(Icons.assignment, 'Fazer ensalamentos'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> scheduleItem) {
    final classData = scheduleItem['class'];
    final roomData = scheduleItem['room'];
    final timeSlot = scheduleItem['time_slot'] ?? 'Horário não definido';
    final className = classData?['name'] ?? 'Aula sem nome';
    final professorName = classData?['professor']?['name'] ?? 'Professor não definido';
    final roomName = roomData?['nome'] ?? 'Sala não definida';

    // Debug logs
    print('=== DEBUG SCHEDULE CARD ===');
    print('scheduleItem: $scheduleItem');
    print('classData: $classData');
    print('professor data: ${classData?['professor']}');
    print('professorName extraído: $professorName');
    print('========================');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(8, 66, 66, 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeSlot,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prof. $professorName',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 120,
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF062825),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sala',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roomName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
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