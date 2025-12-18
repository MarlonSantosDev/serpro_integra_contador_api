import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  List<ServiceItem> get _services {
    final services = [
      ServiceItem(
        id: 'ccmei',
        name: 'CCMEI',
        description: 'Certificado da Condição de Microempreendedor Individual',
        icon: Icons.badge,
        color: Colors.blue,
      ),
      ServiceItem(id: 'pgmei', name: 'PGMEI', description: 'Pagamento de DAS do MEI', icon: Icons.payment, color: Colors.green),
      ServiceItem(
        id: 'pgdasd',
        name: 'PGDASD',
        description: 'Pagamento de DAS por Débito Direto Autorizado',
        icon: Icons.account_balance,
        color: Colors.orange,
      ),
      ServiceItem(
        id: 'caixa_postal',
        name: 'Caixa Postal',
        description: 'Consulta de mensagens da Receita Federal',
        icon: Icons.mail,
        color: Colors.purple,
      ),
      ServiceItem(
        id: 'dctfweb',
        name: 'DCTFWeb',
        description: 'Declaração de Débitos e Créditos Tributários Federais',
        icon: Icons.description,
        color: Colors.teal,
      ),
      ServiceItem(
        id: 'defis',
        name: 'DEFIS',
        description: 'Declaração de Informações Socioeconômicas e Fiscais',
        icon: Icons.assessment,
        color: Colors.indigo,
      ),
      ServiceItem(id: 'sitfis', name: 'SITFIS', description: 'Sistema de Informações Tributárias Fiscais', icon: Icons.info, color: Colors.cyan),
      ServiceItem(id: 'sicalc', name: 'SICALC', description: 'Sistema de Cálculo de Impostos', icon: Icons.calculate, color: Colors.deepOrange),
      ServiceItem(id: 'parcmei', name: 'PARCMEI', description: 'Parcelamento do MEI', icon: Icons.credit_card, color: Colors.pink),
      ServiceItem(
        id: 'parcmei_especial',
        name: 'PARCMEI Especial',
        description: 'Parcelamento Especial do MEI',
        icon: Icons.star,
        color: Colors.pinkAccent,
      ),
      ServiceItem(id: 'pertmei', name: 'PERTMEI', description: 'Pertinência do MEI', icon: Icons.check_circle, color: Colors.lightGreen),
      ServiceItem(id: 'relpmei', name: 'RELPMEI', description: 'Relatório de Pagamentos do MEI', icon: Icons.receipt, color: Colors.lightBlue),
      ServiceItem(id: 'parcsn', name: 'PARCSN', description: 'Parcelamento do Simples Nacional', icon: Icons.business_center, color: Colors.amber),
      ServiceItem(
        id: 'parcsn_especial',
        name: 'PARCSN Especial',
        description: 'Parcelamento Especial do Simples Nacional',
        icon: Icons.star_border,
        color: Colors.amberAccent,
      ),
      ServiceItem(id: 'pertsn', name: 'PERTSN', description: 'Pertinência do Simples Nacional', icon: Icons.verified, color: Colors.lime),
      ServiceItem(
        id: 'relpsn',
        name: 'RELPSN',
        description: 'Relatório de Pagamentos do Simples Nacional',
        icon: Icons.receipt_long,
        color: Colors.yellow,
      ),
      ServiceItem(id: 'dte', name: 'DTE', description: 'Domicílio Tributário Eletrônico', icon: Icons.home, color: Colors.brown),
      ServiceItem(
        id: 'pagtoweb',
        name: 'PagtoWeb',
        description: 'Consulta de pagamentos e emissão de comprovantes',
        icon: Icons.web,
        color: Colors.blueGrey,
      ),
      ServiceItem(id: 'mit', name: 'MIT', description: 'Módulo de Inclusão de Tributos', icon: Icons.add_circle, color: Colors.red),
      ServiceItem(
        id: 'eventos_atualizacao',
        name: 'Eventos de Atualização',
        description: 'Monitoramento de atualizações em sistemas',
        icon: Icons.update,
        color: Colors.deepPurple,
      ),
      ServiceItem(id: 'procuracoes', name: 'Procurações', description: 'Gestão de procurações eletrônicas', icon: Icons.gavel, color: Colors.grey),
      ServiceItem(
        id: 'autenticaprocurador',
        name: 'Autentica Procurador',
        description: 'Gestão de autenticação de procuradores',
        icon: Icons.security,
        color: Colors.black87,
      ),
      ServiceItem(
        id: 'regime_apuracao',
        name: 'Regime Apuração',
        description: 'Gestão do regime de apuração do Simples Nacional',
        icon: Icons.timeline,
        color: Colors.blueGrey,
      ),
    ];
    services.sort((a, b) => a.name.compareTo(b.name));
    return services;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: service.color.withValues(alpha: 0.2),
              child: Icon(service.icon, color: service.color),
            ),
            title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(service.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (!AuthService.isAuthenticated) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Por favor, configure a autenticação primeiro'), backgroundColor: Colors.orange));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetailScreen(service: service)));
            },
          ),
        );
      },
    );
  }
}

class ServiceItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const ServiceItem({required this.id, required this.name, required this.description, required this.icon, required this.color});
}
