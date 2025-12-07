using Serpro.Componentes.AssinaturaDigital.Interfaces;
using System;
using System.Security.Cryptography.X509Certificates;

namespace Serpro.Componentes.AssinaturaDigital
{
    public class AssinadorXmlComCertificadoNaoInstalado : IAssinadorXmlComCertificadoNaoInstalado
    {
        private readonly IValidadorCertificado validadorCertificado;
        private readonly IAssinadorXmlComCertificado assinadorXmlComCertificado;

        public AssinadorXmlComCertificadoNaoInstalado(IValidadorCertificado validadorCertificado, IAssinadorXmlComCertificado assinadorXmlComCertificado)
        {
            this.validadorCertificado = validadorCertificado;
            this.assinadorXmlComCertificado = assinadorXmlComCertificado;
        }

        public (Result, string) Assinar(string xmlNaoAssinado, string caminhoCertificado, string senhaCertificado, string tagParaAssinar = "", string idAtributoTag = "", bool deveRemoverXmlDeclaration = true)
        {
            string xmlAssinado;

            try
            {
                var x509Certificate2 = new X509Certificate2(caminhoCertificado, senhaCertificado);

                var (result, certificadoValidado) = validadorCertificado.Validar(x509Certificate2);
                if ((result.Fail) || (!certificadoValidado)) return (result, default);

                (result, xmlAssinado) = assinadorXmlComCertificado.Assinar(xmlNaoAssinado, x509Certificate2, tagParaAssinar, idAtributoTag, deveRemoverXmlDeclaration);
                if (result.Fail) return (result, default);
            }
            catch (Exception e)
            {
                return (new Result(false, e.Message), default);
            }

            return (new Result(true), xmlAssinado);
        }
    }
}
