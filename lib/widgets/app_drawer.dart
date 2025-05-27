import 'package:flutter/material.dart';
import '../screens/technical_area_screen.dart';

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
              Icons.meeting_room,
              color: Colors.orange,
            ),
            title: const Text(
              'Salas',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navegar para tela de salas
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
              Navigator.pop(context);
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }
} 