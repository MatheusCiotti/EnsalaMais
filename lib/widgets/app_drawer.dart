import 'package:flutter/material.dart';
import '../screens/technical_area_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/users_screen.dart';
import '../screens/allocation_form_screen.dart';
import '../screens/schedule_view_screen.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUserData();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Widget> _buildMenuItems() {
    if (_isLoading || _currentUser == null) {
      return [
        const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      ];
    }

    List<Widget> items = [];
    final userRole = _currentUser!.role;

    // Perfil - disponível para todos
    items.add(
      ListTile(
        leading: const Icon(
          Icons.person,
          color: Colors.orange,
        ),
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/profile');
        },
      ),
    );

    // Reservas - apenas para Professor
    if (userRole == 'Professor') {
      items.add(
        ListTile(
          leading: const Icon(
            Icons.calendar_today,
            color: Colors.orange,
          ),
          title: const Text(
            'Reservas',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navegar para tela de reservas
          },
        ),
      );
    }

    // Área Técnica - apenas para usuários da Área Técnica
    if (userRole == 'Área Técnica') {
      items.add(
        ListTile(
          leading: const Icon(
            Icons.business,
            color: Colors.orange,
          ),
          title: const Text(
            'Área Técnica',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TechnicalAreaScreen(),
              ),
            );
          },
        ),
      );
    }

    // Opções para Administração - todas exceto Área Técnica
    if (userRole == 'Administração') {
      items.addAll([
        ListTile(
          leading: const Icon(
            Icons.calendar_today,
            color: Colors.orange,
          ),
          title: const Text(
            'Reservas',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navegar para tela de reservas
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.school,
            color: Colors.orange,
          ),
          title: const Text(
            'Cursos',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CoursesScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.school, color: Colors.orange),
          title: const Text(
            'Aulas',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/classes');
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.person_add,
            color: Colors.orange,
          ),
          title: const Text(
            'Usuários',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsersScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.add_box,
            color: Colors.orange,
          ),
          title: const Text(
            'Cadastrar Ensalamento',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllocationFormScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_view_week_outlined, color: Colors.orange),
          title: const Text('Ver Ensalamento', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScheduleViewScreen()),
            );
          },
        ),
      ]);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[850],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  height: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ensala+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ..._buildMenuItems(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              try {
                await AuthService.signOut(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao sair: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
} 