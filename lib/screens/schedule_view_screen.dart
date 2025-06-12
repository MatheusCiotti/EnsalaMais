import 'package:flutter/material.dart';
import '../models/class.dart'; // Certifique-se que o modelo Class está importado
import '../services/classes_service.dart';
import './allocation_form_screen.dart';

class ScheduleViewScreen extends StatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, Map<String, List<Map<String, dynamic>>>> _scheduleByDayAndRoom = {};
  final List<String> _weekDays = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _weekDays.length, vsync: this);
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final fullScheduleData = await ClassesService.getFullSchedule();
      
      _scheduleByDayAndRoom.clear();
      for (var item in fullScheduleData) {
        final day = item['day_of_week'];
        final roomName = item['room']?['nome'] ?? 'Sala Desconhecida';
        
        if (day != null) {
          _scheduleByDayAndRoom.putIfAbsent(day, () => {});
          _scheduleByDayAndRoom[day]!.putIfAbsent(roomName, () => []);
          _scheduleByDayAndRoom[day]![roomName]!.add(item);
        }
      }

      _scheduleByDayAndRoom.forEach((day, roomSchedules) {
        roomSchedules.forEach((roomName, classes) {
          classes.sort((a, b) => (a['time_slot'] as String).compareTo(b['time_slot'] as String));
        });
      });

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aplicando o fundo padrão
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/tela.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: DefaultTabController(
            length: _weekDays.length,
            child: Column(
              children: [
                // AppBar customizada
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      const Text('Grade de Ensalamento', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // TabBar estilizada
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.orange,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.orange,
                  indicatorWeight: 3.0,
                  tabs: _weekDays.map((day) => Tab(text: day)).toList(),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _errorMessage != null
                          ? Center(child: Text('Erro: $_errorMessage', style: const TextStyle(color: Colors.red)))
                          : TabBarView(
                              controller: _tabController,
                              children: _weekDays.map((day) {
                                final daySchedule = _scheduleByDayAndRoom[day] ?? {};
                                return ScheduleDayGrid(
                                  scheduleForDay: daySchedule,
                                  onScheduleChange: _loadSchedule,
                                );
                              }).toList(),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar com o novo design da grade
typedef ScheduleChangeCallback = Future<void> Function();

class ScheduleDayGrid extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> scheduleForDay;
  final ScheduleChangeCallback onScheduleChange;

  const ScheduleDayGrid({super.key, required this.scheduleForDay, required this.onScheduleChange});

  @override
  Widget build(BuildContext context) {
    if (scheduleForDay.isEmpty) {
      return const Center(child: Text('Nenhuma aula alocada para este dia.', style: TextStyle(color: Colors.white70)));
    }
    
    final sortedRoomNames = scheduleForDay.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedRoomNames.length,
      itemBuilder: (context, index) {
        final roomName = sortedRoomNames[index];
        final itemsInRoom = scheduleForDay[roomName]!;

        return Card(
          color: Colors.black.withOpacity(0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15)
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roomName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const Divider(height: 20, color: Colors.white30),
                Column(
                  children: itemsInRoom.map((item) {
                    return _buildScheduleRow(context, item);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleRow(BuildContext context, Map<String, dynamic> item) {
    final classItem = Class.fromJson(item['class']);
    final timeSlot = item['time_slot'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(timeSlot, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(classItem.name ?? 'Aula sem nome', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                if (classItem.courseName != null)
                  Text(
                    // Mostra o semestre junto com o nome do curso
                    '${classItem.courseName}${classItem.courseSemester != null ? ' - ${classItem.courseSemester}º Semestre' : ''}',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                if (classItem.professorName != null)
                  Text(
                    'Prof: ${classItem.professorName}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          // Botão de editar
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
            tooltip: 'Editar Alocação',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllocationFormScreen(scheduleItem: item),
                ),
              );
              if (result == true) {
                onScheduleChange();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Excluir Alocação',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: Text('Deseja realmente remover a aula "${classItem.name}" deste horário?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Excluir')),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  await ClassesService.deleteEnsalamento(item['id']);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alocação removida!'), backgroundColor: Colors.green));
                  await onScheduleChange();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                }
              }
            },
          ),
        ],
      ),
    );
  }
} 