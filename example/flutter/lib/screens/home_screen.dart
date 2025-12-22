import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'config_screen.dart';
import 'service_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SERPRO Integra Contador - Testes'),
            Text('Versão: 2.0.2', style: TextStyle(fontSize: 11)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfigScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status de autenticação
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AuthService.isAuthenticated
                ? Colors.green.shade100
                : Colors.orange.shade100,
            child: Row(
              children: [
                Icon(
                  AuthService.isAuthenticated
                      ? Icons.check_circle
                      : Icons.warning,
                  color: AuthService.isAuthenticated
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AuthService.isAuthenticated
                        ? 'Autenticado'
                        : 'Não autenticado - Configure as credenciais',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!AuthService.isAuthenticated)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConfigScreen(),
                        ),
                      );
                    },
                    child: const Text('Configurar'),
                  ),
              ],
            ),
          ),
          // Lista de serviços
          const Expanded(child: ServiceListScreen()),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
