import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/course.dart';
import '../models/room.dart';
import '../services/classes_service.dart';
import '../services/courses_service.dart';
import '../services/rooms_service.dart';

class AllocationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? scheduleItem;

  const AllocationFormScreen({super.key, this.scheduleItem});

  @override
  State<AllocationFormScreen> createState() => _AllocationFormScreenState();
}

class _AllocationFormScreenState extends State<AllocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSearchingRooms = false;
  String? _errorMessage;

  final Map<String, String> _timeSlotMap = { '1º Horário': '19:00-19:50', '2º Horário': '19:50-20:40', '3º Horário': '20:55-21:45', '4º Horário': '21:45-22:35' };
  final List<String> _daysOfWeek = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
  
  List<Course> _availableCourses = [];
  List<Class> _availableClasses = [];
  List<Room> _availableRoomsForSlot = [];

  int? _selectedCourseId;
  String? _selectedClassId;
  int? _selectedRoomId;
  String? _selectedDay;
  String? _selectedTimeSlot;

  bool get isEditing => widget.scheduleItem != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final item = widget.scheduleItem!;
      _selectedClassId = item['class']?['id'];
      _selectedRoomId = item['room']?['id'];
      _selectedDay = item['day_of_week'];
      _selectedTimeSlot = item['time_slot'];
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final courseData = await CoursesService.getCourses();
      if (mounted) setState(() {
        _availableCourses = courseData.map((c) => Course.fromJson(c)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) setState(() => _errorMessage = e.toString());
    }
  }
  
  Future<void> _loadClassesForCourse(int courseId) async {
    setState(() { _isLoading = true; _availableClasses = []; });
    try {
      final classes = await CoursesService.getClassesForCourse(courseId);
      if (mounted) setState(() => _availableClasses = classes);
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _findAvailableRooms() async {
    if (_selectedDay == null || _selectedTimeSlot == null) return;
    
    setState(() => _isSearchingRooms = true);
    try {
      final rooms = await RoomsService.getAvailableRoomsForSlot(_selectedDay!, _selectedTimeSlot!);
      if (mounted) setState(() => _availableRoomsForSlot = rooms);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar salas: $e')));
    } finally {
      if(mounted) setState(() => _isSearchingRooms = false);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await ClassesService.createEnsalamento(classId: _selectedClassId!, roomId: _selectedRoomId!, dayOfWeek: _selectedDay!, timeSlot: _selectedTimeSlot!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ensalamento salvo com sucesso!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.orange)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Ensalamento'), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/tela.png'), fit: BoxFit.cover)),
        child: _isLoading && _availableCourses.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedCourseId,
                      hint: const Text('Primeiro, selecione o Curso', style: TextStyle(color: Colors.white70)),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey[850],
                      decoration: _inputDecoration('Curso'),
                      items: _availableCourses.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} - ${c.semester}º Semestre'))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCourseId = value;
                            _selectedClassId = null;
                            _availableClasses = [];
                          });
                          _loadClassesForCourse(value);
                        }
                      },
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // ===== DROPDOWN DE AULA CORRIGIDO =====
                    DropdownButtonFormField<String>(
                      value: _selectedClassId,
                      hint: Text(_selectedCourseId == null ? 'Selecione um curso primeiro' : 'Selecione a Aula', style: const TextStyle(color: Colors.white70)),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey[850],
                      decoration: _inputDecoration('Aula'),
                      items: _availableClasses.map((aula) {
                        // Construímos o texto de forma segura ANTES de passar para o widget Text
                        final semesterText = aula.courseSemester != null ? ' (${aula.courseSemester}º Sem)' : '';
                        final displayText = '${aula.name ?? "Aula sem nome"}$semesterText';

                        return DropdownMenuItem(
                          value: aula.id,
                          child: Text(
                            displayText, // Passamos a string já garantida como não-nula
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _selectedCourseId == null ? null : (value) => setState(() => _selectedClassId = value),
                      validator: (value) => value == null ? 'Campo obrigatório' : null,
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Dia da Semana'),
                    Wrap(
                      spacing: 8.0,
                      children: _daysOfWeek.map((day) {
                        final isSelected = _selectedDay == day;
                        return ChoiceChip(
                          label: Text(day),
                          selected: isSelected,
                          selectedColor: Colors.orange,
                          backgroundColor: Colors.grey[800],
                          labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                          onSelected: (selected) {
                            setState(() {
                              _selectedDay = selected ? day : null;
                              _findAvailableRooms();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Horário'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _timeSlotMap.keys.map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return ChoiceChip(
                          label: Text('$slot (${_timeSlotMap[slot]})'),
                          selected: isSelected,
                          selectedColor: Colors.orange,
                          backgroundColor: Colors.grey[800],
                          labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                           onSelected: (selected) {
                            setState(() {
                              _selectedTimeSlot = selected ? slot : null;
                              _findAvailableRooms();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 40, color: Colors.white30),
                    
                    _buildSectionTitle('Salas Disponíveis'),
                    _isSearchingRooms
                        ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                        : SizedBox(
                            height: 150,
                            child: _availableRoomsForSlot.isEmpty
                                ? Center(child: Text('Nenhuma sala disponível ou selecione um dia e horário.', style: TextStyle(color: Colors.white70)))
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _availableRoomsForSlot.length,
                                    itemBuilder: (context, index) {
                                      final room = _availableRoomsForSlot[index];
                                      final isSelected = _selectedRoomId == room.id;
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedRoomId = room.id),
                                        child: Card(
                                          elevation: isSelected ? 8 : 2,
                                          color: isSelected ? Colors.orange.shade200 : Colors.grey[850],
                                          child: Container(
                                            width: 220,
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Text(room.nome ?? '', style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                              const Divider(),
                                              Text('Capacidade: ${room.chairCount}', style: TextStyle(color: isSelected ? Colors.black87 : Colors.white70)),
                                            ]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.orange, foregroundColor: Colors.black),
                      onPressed: (_isLoading || _selectedRoomId == null) ? null : _submitForm,
                      child: const Text('Salvar Ensalamento'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}