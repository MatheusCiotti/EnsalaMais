import 'package:flutter/material.dart';
import '../screens/technical_area_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/users_screen.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
          ListTile(
            leading: const Icon(
              Icons.history,
              color: Colors.orange,
            ),
            title: const Text(
              'Histórico',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navegar para tela de histórico
            },
          ),
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
              // TODO: Navegar para tela de perfil
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