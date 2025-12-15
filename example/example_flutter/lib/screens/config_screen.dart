import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _consumerKeyController = TextEditingController();
  final _consumerSecretController = TextEditingController();
  final _contratanteController = TextEditingController();
  final _autorPedidoController = TextEditingController();
  final _senhaCertificadoController = TextEditingController();
  final _certificadoBase64Controller = TextEditingController();
  final _urlServidorController = TextEditingController();

  String _ambiente = 'trial';
  bool _isLoading = false;
  bool _obscureSecret = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Valores padrão para trial
    _consumerKeyController.text = '06aef429-a981-3ec5-a1f8-71d38d86481e';
    _consumerSecretController.text = '06aef429-a981-3ec5-a1f8-71d38d86481e';
    _contratanteController.text = '00000000000191';
    _autorPedidoController.text = '00000000191';
    _urlServidorController.text = 'http://localhost:8080';
  }

  @override
  void dispose() {
    _consumerKeyController.dispose();
    _consumerSecretController.dispose();
    _contratanteController.dispose();
    _autorPedidoController.dispose();
    _senhaCertificadoController.dispose();
    _certificadoBase64Controller.dispose();
    _urlServidorController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.authenticate(
        consumerKey: _consumerKeyController.text.trim(),
        consumerSecret: _consumerSecretController.text.trim(),
        contratanteNumero: _contratanteController.text.trim(),
        autorPedidoDadosNumero: _autorPedidoController.text.trim(),
        certificadoDigitalBase64: _certificadoBase64Controller.text.trim().isNotEmpty ? _certificadoBase64Controller.text.trim() : null,
        senhaCertificado: _senhaCertificadoController.text.trim().isNotEmpty ? _senhaCertificadoController.text.trim() : null,
        ambiente: _ambiente,
        urlServidor: _urlServidorController.text.trim().isNotEmpty ? _urlServidorController.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Autenticação realizada com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro na autenticação: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração de Autenticação')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ambiente
            Card(
              color: Colors.redAccent.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ambiente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'trial', label: Text('Trial'), icon: Icon(Icons.developer_mode)),
                        ButtonSegment(value: 'producao', label: Text('Produção'), icon: Icon(Icons.business)),
                      ],
                      selected: {_ambiente},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _ambiente = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Consumer Key
            TextFormField(
              controller: _consumerKeyController,
              decoration: const InputDecoration(
                labelText: 'Consumer Key *',
                border: OutlineInputBorder(),
                helperText: 'Chave de acesso fornecida pelo SERPRO',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Consumer Key é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Consumer Secret
            TextFormField(
              controller: _consumerSecretController,
              decoration: InputDecoration(
                labelText: 'Consumer Secret *',
                border: const OutlineInputBorder(),
                helperText: 'Segredo de acesso fornecida pelo SERPRO',
                suffixIcon: IconButton(
                  icon: Icon(_obscureSecret ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureSecret = !_obscureSecret;
                    });
                  },
                ),
              ),
              obscureText: _obscureSecret,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Consumer Secret é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contratante
            TextFormField(
              controller: _contratanteController,
              decoration: const InputDecoration(
                labelText: 'CNPJ Contratante *',
                border: OutlineInputBorder(),
                helperText: 'CNPJ da empresa contratante',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'CNPJ Contratante é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Autor do Pedido
            TextFormField(
              controller: _autorPedidoController,
              decoration: const InputDecoration(
                labelText: 'CPF/CNPJ Autor do Pedido *',
                border: OutlineInputBorder(),
                helperText: 'CPF ou CNPJ do autor da requisição',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Autor do Pedido é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Certificado (apenas para produção)
            if (_ambiente == 'producao') ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Certificado Digital (Produção)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _certificadoBase64Controller,
                        decoration: const InputDecoration(
                          labelText: 'Certificado Base64',
                          border: OutlineInputBorder(),
                          helperText: 'Certificado P12/PFX em Base64',
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (_ambiente == 'producao' && (value == null || value.trim().isEmpty)) {
                            return 'Certificado é obrigatório em produção';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaCertificadoController,
                        decoration: InputDecoration(
                          labelText: 'Senha do Certificado',
                          border: const OutlineInputBorder(),
                          helperText: 'Senha do certificado (deixe vazio se não tiver)',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // URL Servidor (opcional para Web)
            TextFormField(
              controller: _urlServidorController,
              decoration: const InputDecoration(
                labelText: 'URL Servidor (Opcional)',
                border: OutlineInputBorder(),
                helperText: 'URL do servidor externo para uso na Web',
              ),
            ),
            const SizedBox(height: 24),

            // Botão de autenticação
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _authenticate,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Autenticar', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // Botão para limpar autenticação
            if (AuthService.isAuthenticated)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    AuthService.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autenticação limpa')));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Limpar Autenticação'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
