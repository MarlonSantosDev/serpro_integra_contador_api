import 'dart:convert';
import '../../util/validations_utils.dart';
import 'procuracoes_enums.dart';

/// Request para obter procurações eletrônicas
class ObterProcuracaoRequest {
  final String outorgante;
  final String tipoOutorgante;
  final String outorgado;
  final String tipoOutorgado;

  ObterProcuracaoRequest({required this.outorgante, required this.tipoOutorgante, required this.outorgado, required this.tipoOutorgado});

  /// Cria request a partir de CPF/CNPJ
  factory ObterProcuracaoRequest.fromDocuments({required String outorgante, required String outorgado}) {
    return ObterProcuracaoRequest(
      outorgante: outorgante,
      tipoOutorgante: _detectDocumentType(outorgante),
      outorgado: outorgado,
      tipoOutorgado: _detectDocumentType(outorgado),
    );
  }

  /// Detecta o tipo de documento (1=CPF, 2=CNPJ)
  static String _detectDocumentType(String document) {
    return DocumentUtils.detectDocumentType(document).toString();
  }

  /// Valida dados mas lança exceção ao invés de retornar lista de erros
  void validateWithException() {
    final erros = validate();
    if (erros.isNotEmpty) {
      throw ArgumentError('Dados inválidos: ${erros.join(', ')}');
    }
  }

  /// Valida e limpa documentos automaticamente
  ObterProcuracaoRequest validatedAndCleaned() {
    validateWithException();

    return ObterProcuracaoRequest(
      outorgante: DocumentUtils.cleanDocumentNumber(outorgante),
      tipoOutorgante: tipoOutorgante,
      outorgado: DocumentUtils.cleanDocumentNumber(outorgado),
      tipoOutorgado: tipoOutorgado,
    );
  }

  /// Valida os dados da requisição
  List<String> validate() {
    final errors = <String>[];

    // Validar outorgante
    if (outorgante.isEmpty) {
      errors.add('Outorgante é obrigatório');
    } else {
      if (tipoOutorgante == ProcuracoesConstants.tipoCpf && !DocumentUtils.isValidCpf(outorgante)) {
        errors.add('CPF do outorgante inválido!');
      } else if (tipoOutorgante == ProcuracoesConstants.tipoCnpj && !DocumentUtils.isValidCnpj(outorgante)) {
        errors.add('CNPJ do outorgante inválido!');
      }
    }

    // Validar outorgado
    if (outorgado.isEmpty) {
      errors.add('Outorgado é obrigatório');
    } else {
      if (tipoOutorgado == ProcuracoesConstants.tipoCpf && !DocumentUtils.isValidCpf(outorgado)) {
        errors.add('CPF do outorgado inválido!');
      } else if (tipoOutorgado == ProcuracoesConstants.tipoCnpj && !DocumentUtils.isValidCnpj(outorgado)) {
        errors.add('CNPJ do outorgado inválido!');
      }
    }

    // Validar tipos
    if (!ProcuracoesConstants.isTipoPessoaValido(tipoOutorgante)) {
      errors.add('Tipo NI do outorgante inválido!');
    }

    if (!ProcuracoesConstants.isTipoPessoaValido(tipoOutorgado)) {
      errors.add('Tipo NI do outorgado inválido!');
    }

    return errors;
  }

  /// Converte para JSON string para envio na API
  String toJsonString() {
    final data = {'outorgante': outorgante, 'tipoOutorgante': tipoOutorgante, 'outorgado': outorgado, 'tipoOutorgado': tipoOutorgado};
    return jsonEncode(data);
  }

  /// Converte para Map
  Map<String, dynamic> toJson() {
    return {'outorgante': outorgante, 'tipoOutorgante': tipoOutorgante, 'outorgado': outorgado, 'tipoOutorgado': tipoOutorgado};
  }

  /// Cria a partir de JSON
  factory ObterProcuracaoRequest.fromJson(Map<String, dynamic> json) {
    return ObterProcuracaoRequest(
      outorgante: json['outorgante'].toString(),
      tipoOutorgante: json['tipoOutorgante'].toString(),
      outorgado: json['outorgado'].toString(),
      tipoOutorgado: json['tipoOutorgado'].toString(),
    );
  }

  @override
  String toString() {
    return 'ObterProcuracaoRequest(outorgante: $outorgante, tipoOutorgante: $tipoOutorgante, outorgado: $outorgado, tipoOutorgado: $tipoOutorgado)';
  }
}
