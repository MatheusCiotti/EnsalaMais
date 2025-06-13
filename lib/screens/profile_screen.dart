import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/courses_service.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _funcaoController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoadingCourses = true;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _showPasswordSection = false;

  User? _currentUser;
  List<Map<String, dynamic>> _courses = [];
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCourses();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUserData();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name ?? '';
          _emailController.text = user.email ?? '';
          _funcaoController.text = user.funcao ?? '';
          _selectedCourseId = user.courseId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await CoursesService.getCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCourses = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cursos: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService.updateUserProfile(
        name: _nameController.text,
        courseId: _selectedCourseId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _funcaoController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tela.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Meu Perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar e informações básicas
                                Center(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.orange,
                                        child: Text(
                                          _currentUser?.name?.isNotEmpty == true
                                              ? _currentUser!.name![0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _currentUser?.name ?? 'Usuário',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _currentUser?.role ?? 'Sem função',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Formulário de edição
                                Card(
                                  color: Colors.black.withOpacity(0.3),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Informações Pessoais',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Nome
                                        TextFormField(
                                          controller: _nameController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Nome Completo',
                                            labelStyle: const TextStyle(color: Colors.white),
                                            prefixIcon: const Icon(Icons.person, color: Colors.white),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              borderSide: const BorderSide(color: Colors.orange),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.1),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Por favor, digite seu nome';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        // Email (somente leitura)
                                        TextFormField(
                                          controller: _emailController,
                                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: 'E-mail',
                                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                            prefixIcon: Icon(Icons.email, color: Colors.white.withOpacity(0.7)),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.05),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Função
                                        TextFormField(
                                          controller: _funcaoController,
                                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: 'Função/Cargo',
                                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                            prefixIcon: Icon(Icons.work, color: Colors.white.withOpacity(0.7)),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30),
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.05),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Curso (se aplicável)
                                        if (_currentUser?.role == 'Aluno' || _currentUser?.role == 'Professor')
                                          _isLoadingCourses
                                              ? Container(
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: Colors.white.withOpacity(0.1),
                                                  ),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(color: Colors.white),
                                                  ),
                                                )
                                              : DropdownButtonFormField<int>(
                                                  value: _selectedCourseId,
                                                  style: const TextStyle(color: Colors.white),
                                                  dropdownColor: Colors.grey[800],
                                                  decoration: InputDecoration(
                                                    labelText: 'Curso',
                                                    labelStyle: const TextStyle(color: Colors.white),
                                                    prefixIcon: const Icon(Icons.school, color: Colors.white),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(30),
                                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(30),
                                                      borderSide: const BorderSide(color: Colors.orange),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white.withOpacity(0.1),
                                                  ),
                                                  items: [
                                                    const DropdownMenuItem<int>(
                                                      value: null,
                                                      child: Text('Selecione um curso', style: TextStyle(color: Colors.white)),
                                                    ),
                                                    ..._courses.map<DropdownMenuItem<int>>((course) {
                                                      return DropdownMenuItem<int>(
                                                        value: course['id'],
                                                        child: Text(
                                                          '${course['name']} - ${course['semester']}º sem',
                                                          style: const TextStyle(color: Colors.white),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ],
                                                  onChanged: (int? value) {
                                                    setState(() {
                                                      _selectedCourseId = value;
                                                    });
                                                  },
                                                ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Seção de alteração de senha
                                Card(
                                  color: Colors.black.withOpacity(0.3),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Alterar Senha',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _showPasswordSection = !_showPasswordSection;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        if (_showPasswordSection) ...[
                                          const SizedBox(height: 16),
                                          
                                          // Nova senha
                                          TextFormField(
                                            controller: _newPasswordController,
                                            obscureText: _obscureNewPassword,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              labelText: 'Nova Senha',
                                              labelStyle: const TextStyle(color: Colors.white),
                                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureNewPassword = !_obscureNewPassword;
                                                  });
                                                },
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(30),
                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(30),
                                                borderSide: const BorderSide(color: Colors.orange),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white.withOpacity(0.1),
                                            ),
                                            validator: (value) {
                                              if (value != null && value.isNotEmpty && value.length < 6) {
                                                return 'A senha deve ter pelo menos 6 caracteres';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),

                                          // Confirmar nova senha
                                          TextFormField(
                                            controller: _confirmPasswordController,
                                            obscureText: _obscureConfirmPassword,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              labelText: 'Confirmar Nova Senha',
                                              labelStyle: const TextStyle(color: Colors.white),
                                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                                  });
                                                },
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(30),
                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(30),
                                                borderSide: const BorderSide(color: Colors.orange),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white.withOpacity(0.1),
                                            ),
                                            validator: (value) {
                                              if (_newPasswordController.text.isNotEmpty) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Por favor, confirme a nova senha';
                                                }
                                                if (value != _newPasswordController.text) {
                                                  return 'As senhas não coincidem';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Botão salvar
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: _isSaving ? null : _saveProfile,
                                    child: _isSaving
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const Text(
                                            'Salvar Alterações',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Botão logout
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.grey[900],
                                          title: const Text('Sair', style: TextStyle(color: Colors.white)),
                                          content: const Text(
                                            'Tem certeza que deseja sair da sua conta?',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Sair', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await SupabaseService.signOut();
                                        if (mounted) {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false,
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Sair da Conta',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
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