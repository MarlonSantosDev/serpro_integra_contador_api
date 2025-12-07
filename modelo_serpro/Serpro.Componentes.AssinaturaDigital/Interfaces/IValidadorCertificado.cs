using System.Security.Cryptography.X509Certificates;

namespace Serpro.Componentes.AssinaturaDigital.Interfaces
{
    public interface IValidadorCertificado
    {
        (Result, bool) Validar(X509Certificate2 certificado);
    }
}
