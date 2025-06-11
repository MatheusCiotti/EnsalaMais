import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/course.dart';
import '../models/room.dart';
import '../services/courses_service.dart';
import '../services/rooms_service.dart';
import '../services/classes_service.dart';

class AllocationFormScreen extends StatefulWidget {
  const AllocationFormScreen({super.key});

  @override
  State<AllocationFormScreen> createState() => _AllocationFormScreenState();
}

class _AllocationFormScreenState extends State<AllocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _errorMessage;

  // Listas para os dropdowns
  List<Course> _availableCourses = [];
  List<Class> _availableClasses = [];
  List<Room> _availableRooms = [];
  
  // Opções estáticas
  final List<String> _daysOfWeek = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
  final List<String> _timeSlots = ['1º Horário', '2º Horário', '3º Horário', '4º Horário'];

  // Variáveis para guardar os valores selecionados
  int? _selectedCourseId;
  String? _selectedClassId;
  int? _selectedRoomId;
  String? _selectedDay;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Carrega apenas os dados que não dependem de seleção: Cursos e Salas
      final results = await Future.wait([
        CoursesService.getCourses().then((maps) => maps.map((c) => Course.fromJson(c)).toList()),
        RoomsService.getRooms().then((maps) => maps.map((r) => Room.fromJson(r)).toList()),
      ]);
      if (mounted) {
        setState(() {
          _availableCourses = results[0] as List<Course>;
          _availableRooms = results[1] as List<Room>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => _errorMessage = e.toString());
    }
  }
  
  // Nova função para carregar as aulas de um curso específico
  Future<void> _loadClassesForCourse(int courseId) async {
    setState(() => _isLoading = true);
    try {
      // Usando a função que já tínhamos no CoursesService
      final classes = await CoursesService.getClassesForCourse(courseId);
      if (mounted) {
        setState(() {
          _availableClasses = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
       if(mounted) setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await ClassesService.createEnsalamento(
          classId: _selectedClassId!,
          roomId: _selectedRoomId!,
          dayOfWeek: _selectedDay!,
          timeSlot: _selectedTimeSlot!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ensalamento salvo com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Ensalamento')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erro: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // NOVO DROPDOWN DE CURSO
                      DropdownButtonFormField<int>(
                        value: _selectedCourseId,
                        hint: const Text('Primeiro, selecione o Curso'),
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Curso', border: OutlineInputBorder()),
                        items: _availableCourses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCourseId = value;
                              _selectedClassId = null; // Reseta a seleção de aula
                              _availableClasses = []; // Limpa a lista de aulas
                            });
                            _loadClassesForCourse(value); // Carrega as aulas do curso selecionado
                          }
                        },
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      // Dropdown de Aula (agora depende do curso)
                      DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        hint: Text(_selectedCourseId == null ? 'Selecione um curso primeiro' : 'Selecione a Aula'),
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Aula', border: OutlineInputBorder()),
                        // Desabilita se nenhum curso foi selecionado
                        items: _selectedCourseId == null ? [] : _availableClasses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name ?? 'Aula sem nome', overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: _selectedCourseId == null ? null : (value) => setState(() => _selectedClassId = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDay,
                        hint: const Text('Selecione o Dia da Semana'),
                        decoration: const InputDecoration(labelText: 'Dia da Semana', border: OutlineInputBorder()),
                        items: _daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                        onChanged: (value) => setState(() => _selectedDay = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTimeSlot,
                        hint: const Text('Selecione o Horário'),
                        decoration: const InputDecoration(labelText: 'Horário', border: OutlineInputBorder()),
                        items: _timeSlots.map((slot) => DropdownMenuItem(value: slot, child: Text(slot))).toList(),
                        onChanged: (value) => setState(() => _selectedTimeSlot = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedRoomId,
                        hint: const Text('Selecione a Sala'),
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Sala', border: OutlineInputBorder()),
                        items: _availableRooms.map((r) => DropdownMenuItem(value: r.id, child: Text(r.nome ?? 'Sala sem nome', overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (value) => setState(() => _selectedRoomId = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3)) : const Text('Salvar Ensalamento'),
                      ),
                    ],
                  ),
                ),
    );
  }
}