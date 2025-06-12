import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/course.dart';
import '../services/courses_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  Course? _course;
  List<Class> _associatedClasses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // LÓGICA DE CARREGAMENTO OTIMIZADA
  Future<void> _loadDetails() async {
    try {
      // Busca os detalhes do curso e a lista de aulas em paralelo
      final results = await Future.wait([
        // Modifique seu CoursesService para ter uma função getCourseById
        // Por enquanto, vamos manter a lógica de filtro
        CoursesService.getCourses(), 
        CoursesService.getClassesForCourse(widget.courseId),
      ]);

      final allCourses = results[0] as List<Map<String, dynamic>>;
      final specificCourseData = allCourses.firstWhere(
        (c) => c['id'] == widget.courseId,
        orElse: () => {},
      );

      if (mounted) {
        setState(() {
          _course = specificCourseData.isNotEmpty ? Course.fromJson(specificCourseData) : null;
          _associatedClasses = results[1] as List<Class>;
          _isLoading = false;
        });
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/tela.png'), fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          _isLoading ? 'Carregando...' : (_course?.name ?? 'Detalhes do Curso'),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _errorMessage != null
                          ? Center(child: Text('Erro: $_errorMessage', style: const TextStyle(color: Colors.red, fontSize: 16)))
                          : buildCourseDetails(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== WIDGET DE DETALHES CORRIGIDO =====
  Widget buildCourseDetails() {
    if (_course == null) {
      return const Center(child: Text('Curso não encontrado.', style: TextStyle(color: Colors.white)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // CORREÇÃO: Usando a interpolação de string padrão do Dart
          Text('Coordenador: ${_course!.coordinator}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 4),
          Text('${_course!.semester}º Semestre - ${_course!.period}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30),
          const SizedBox(height: 16),
          const Text('Aulas Associadas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          _associatedClasses.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Nenhuma aula associada a este curso.', style: TextStyle(color: Colors.white70))))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _associatedClasses.length,
                  itemBuilder: (context, index) {
                    final classItem = _associatedClasses[index];
                    return Card(
                      color: Colors.grey[850]?.withOpacity(0.5),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(classItem.name ?? 'Aula sem nome', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(classItem.schedule ?? 'Horário não definido', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}