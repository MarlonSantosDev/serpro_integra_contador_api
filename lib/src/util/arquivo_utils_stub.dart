/// Implementação stub para Web - não suporta operações de arquivo
///
/// Em Web, salvar arquivos no sistema de arquivos não é suportado.
/// Use implementações específicas da plataforma ou APIs do navegador.
class ArquivoUtils {
  /// Salva um arquivo em base64 em um arquivo local - não suportado em Web
  ///
  /// Em Web, este método sempre retorna false pois não é possível
  /// salvar arquivos diretamente no sistema de arquivos.
  static Future<bool> salvarArquivo(String pdfBase64, String nomeDoArquivo) async {
    // Em Web, não é possível salvar arquivos no sistema de arquivos
    // O usuário deve usar APIs do navegador (como download) ou
    // implementações específicas da plataforma
    return false;
  }
}
