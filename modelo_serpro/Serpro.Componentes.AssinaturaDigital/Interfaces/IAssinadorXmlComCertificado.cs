using System.Security.Cryptography.X509Certificates;

namespace Serpro.Componentes.AssinaturaDigital.Interfaces
{
    public interface IAssinadorXmlComCertificado
    {
        (Result, string) Assinar(string xmlNaoAssinado, X509Certificate2 certificado, string tagParaAssinar = "", string idAtributoTag = "", bool deveRemoverXmlDeclaration = true);
    }
}
