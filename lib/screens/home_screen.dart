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
  
  Map<String, List<Map<String, dynamic>>> _weekSchedule = {};

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
        // Aluno: carregar aulas do curso para a semana
        _loadWeekSchedule(userData!.courseId!);
      } else if (userData?.role == 'Professor') {
        // Professor: carregar suas próprias aulas da semana
        _loadProfessorWeekSchedule(userData!.id!);
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

  Future<void> _loadWeekSchedule(int courseId) async {
    setState(() {
      _isLoadingSchedule = true;
    });

    try {
      final schedule = await UserService.getWeekClassesByCourse(courseId);
      print('Schedule da semana carregado para aluno: $schedule');
      setState(() {
        _weekSchedule = schedule;
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

  Future<void> _loadProfessorWeekSchedule(String professorId) async {
    setState(() {
      _isLoadingSchedule = true;
    });

    try {
      final schedule = await UserService.getWeekClassesByProfessor(professorId);
      print('Schedule da semana carregado para professor: $schedule');
      setState(() {
        _weekSchedule = schedule;
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
            _currentUser?.role == 'Professor' ? 'Suas aulas da semana:' : 'Suas aulas da semana:',
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
                : _weekSchedule.isEmpty
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
                              'Nenhuma aula esta semana!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aproveite sua semana livre 😊',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildWeekScheduleView(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekScheduleView() {
    return DefaultTabController(
      length: 7,
      initialIndex: DateTime.now().weekday - 1, // Inicia no dia atual
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TabBar(
              isScrollable: false,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'SEG'),
                Tab(text: 'TER'),
                Tab(text: 'QUA'),
                Tab(text: 'QUI'),
                Tab(text: 'SEX'),
                Tab(text: 'SÁB'),
                Tab(text: 'DOM'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TabBarView(
                  children: [
                    _buildDaySchedule('Segunda-feira'),
                    _buildDaySchedule('Terça-feira'),
                    _buildDaySchedule('Quarta-feira'),
                    _buildDaySchedule('Quinta-feira'),
                    _buildDaySchedule('Sexta-feira'),
                    _buildDaySchedule('Sábado'),
                    _buildDaySchedule('Domingo'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(String dayOfWeek) {
    final daySchedule = _weekSchedule[dayOfWeek] ?? [];
    
    if (daySchedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.free_breakfast,
                  size: 32,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma aula',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dia livre! 😊',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySchedule.length,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: _buildScheduleCard(daySchedule[index]),
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeSlot,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          professorName,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 110,
            width: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF062825),
                  Color(0xFF084A46),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.room,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sala',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    roomName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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