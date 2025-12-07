using Serpro.Componentes.AssinaturaDigital.Interfaces;
using System;
using System.Security.Cryptography.X509Certificates;

namespace Serpro.Componentes.AssinaturaDigital
{
    public class ValidadorCertificado : IValidadorCertificado
    {
        public (Result, bool) Validar(X509Certificate2 certificado)
        {
            try
            {
                if (!certificado.HasPrivateKey)
                    return (new Result(true, "Certificado não possui chave privada."), false);

                if (DateTime.Now > certificado.NotAfter || DateTime.Now < certificado.NotBefore)
                    return (new Result(true, "Certificado fora do período de validade."), false);

                return (new Result(true), true);
            }
            catch (Exception e)
            {
                return (new Result(false, e.Message), default);
            }
        }
    }
}