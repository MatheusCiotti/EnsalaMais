import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/users_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  // Variáveis para o filtro
  final List<String> _filterRoles = ['Todos', 'Administração', 'Professor', 'Aluno'];
  String _selectedRoleFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Passa o filtro selecionado para o serviço
      final usersData = await UsersService.getUsers(role: _selectedRoleFilter);
      if (mounted) {
        setState(() {
          _users = usersData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar usuários: $e')));
        setState(() => _isLoading = false);
      }
    }
  }


  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = User.roles.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Adicionar Novo Usuário',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nome do Usuário',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha Temporária',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Função',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                  ),
                  items: User.roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(
                        role,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setDialogState(() {
                      selectedRole = value ?? User.roles.first;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  try {
                    await UsersService.createUser(
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      role: selectedRole,
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuário criado com sucesso!'),
                        ),
                      );
                      _loadUsers(); // Recarrega a lista de usuários
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao criar usuário: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role ?? _filterRoles.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Editar Usuário', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nome', labelStyle: TextStyle(color: Colors.white))),
                const SizedBox(height: 16),
                TextField(controller: emailController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'E-mail', labelStyle: TextStyle(color: Colors.white))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  items: User.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (value) => setDialogState(() => selectedRole = value!),
                  decoration: InputDecoration(labelText: 'Função', labelStyle: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                try {
                  final updatedUserData = await UsersService.updateUser(
                    userId: user.id,
                    name: nameController.text,
                    email: emailController.text,
                    role: selectedRole,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário atualizado!'), backgroundColor: Colors.green));
                    // Atualiza a lista localmente para refletir a mudança instantaneamente
                    setState(() {
                      final index = _users.indexWhere((u) => u.id == user.id);
                      if (index != -1) {
                        _users[index] = User.fromJson(updatedUserData);
                      }
                    });
                  }
                } catch (e) {
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/tela.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    const Text('Gestão de Usuários', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // ===== NOVO WIDGET DE FILTRO =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtrar por função:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _filterRoles.map((role) {
                        final isSelected = _selectedRoleFilter == role;
                        return ChoiceChip(
                          label: Text(role),
                          selected: isSelected,
                          selectedColor: Colors.orange,
                          backgroundColor: Colors.grey[800],
                          labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedRoleFilter = role;
                              });
                              _loadUsers(); // Recarrega os usuários com o novo filtro
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, color: Colors.white24),
              // LISTA DE USUÁRIOS
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            color: Colors.grey[850],
                            child: ListTile(
                              title: Text(user.name ?? 'Usuário sem nome', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text('Função: ${user.role ?? 'Não definida'}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditUserDialog(user)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}