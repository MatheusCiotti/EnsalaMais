import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/room.dart';
import '../services/classes_service.dart';
import '../services/rooms_service.dart';

class AllocationFormScreen extends StatefulWidget {
  const AllocationFormScreen({super.key});

  @override
  State<AllocationFormScreen> createState() => _AllocationFormScreenState();
}

class _AllocationFormScreenState extends State<AllocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _errorMessage;

  List<Class> _availableClasses = [];
  List<Room> _availableRooms = [];
  final List<String> _daysOfWeek = ['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
  final List<String> _timeSlots = ['1º Horário', '2º Horário', '3º Horário', '4º Horário'];

  String? _selectedClassId;
  int? _selectedRoomId;
  String? _selectedDay;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ClassesService.getClasses(),
        RoomsService.getRooms(),
      ]);
      if (mounted) {
        setState(() {
          _availableClasses = results[0] as List<Class>;
          _availableRooms = results[1] as List<Room>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
              ? Center(child: Text('Erro ao carregar dados: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedDay,
                        hint: const Text('Selecione o Dia da Semana'),
                        items: _daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                        onChanged: (value) => setState(() => _selectedDay = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTimeSlot,
                        hint: const Text('Selecione o Horário'),
                        items: _timeSlots.map((slot) => DropdownMenuItem(value: slot, child: Text(slot))).toList(),
                        onChanged: (value) => setState(() => _selectedTimeSlot = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        hint: const Text('Selecione a Aula'),
                        isExpanded: true,
                        items: _availableClasses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (value) => setState(() => _selectedClassId = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedRoomId,
                        hint: const Text('Selecione a Sala'),
                        isExpanded: true,
                        items: _availableRooms.map((r) => DropdownMenuItem(value: r.id, child: Text(r.nome, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (value) => setState(() => _selectedRoomId = value),
                        validator: (value) => value == null ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Salvar Ensalamento'),
                      ),
                    ],
                  ),
                ),
    );
  }
} 