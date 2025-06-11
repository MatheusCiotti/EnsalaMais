import 'package:flutter/material.dart';
import '../models/class.dart'; // Importe seu modelo de aula
import '../services/classes_service.dart';

class ScheduleViewScreen extends StatefulWidget {
  const ScheduleViewScreen({super.key});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  // Estrutura para organizar os dados: Dia -> Sala -> Lista de Aulas
  final Map<String, Map<String, List<Class>>> _scheduleByDayAndRoom = {};

  final List<String> _weekDays = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _weekDays.length, vsync: this);
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final fullScheduleData = await ClassesService.getFullSchedule();
      
      // Processa e agrupa os dados para a UI
      _scheduleByDayAndRoom.clear();
      for (var item in fullScheduleData) {
        final day = item['day_of_week'];
        final roomName = item['room']?['nome'] ?? 'Sala Desconhecida';
        
        final classObj = Class.fromJson(item['class']);

        _scheduleByDayAndRoom.putIfAbsent(day, () => {});
        _scheduleByDayAndRoom[day]!.putIfAbsent(roomName, () => []);
        _scheduleByDayAndRoom[day]![roomName]!.add(classObj);
      }

      // Ordena os horários dentro de cada sala
      _scheduleByDayAndRoom.forEach((day, roomSchedules) {
        roomSchedules.forEach((roomName, classes) {
          classes.sort((a, b) => (a.schedule ?? '').compareTo(b.schedule ?? ''));
        });
      });


      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade de Ensalamento'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _weekDays.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erro: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: _weekDays.map((day) {
                    final daySchedule = _scheduleByDayAndRoom[day] ?? {};
                    return ScheduleDayGrid(scheduleForDay: daySchedule);
                  }).toList(),
                ),
    );
  }
}

// Widget auxiliar para construir a grade de um dia
class ScheduleDayGrid extends StatelessWidget {
  final Map<String, List<Class>> scheduleForDay;

  const ScheduleDayGrid({super.key, required this.scheduleForDay});

  @override
  Widget build(BuildContext context) {
    if (scheduleForDay.isEmpty) {
      return const Center(child: Text('Nenhuma aula alocada para este dia.'));
    }
    
    final sortedRoomNames = scheduleForDay.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedRoomNames.length,
      itemBuilder: (context, index) {
        final roomName = sortedRoomNames[index];
        final classesInRoom = scheduleForDay[roomName]!;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roomName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(height: 20),
                ...classesInRoom.map((classItem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${classItem.schedule}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${classItem.name} (${classItem.courseName ?? 'Curso não especificado'})'),
                        Text('Professor: ${classItem.professorName ?? "Não definido"}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
} 