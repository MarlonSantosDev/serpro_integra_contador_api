namespace Serpro.Componentes.AssinaturaDigital.Interfaces
{
    public interface IAssinadorXmlComCertificadoNaoInstalado
    {
        (Result, string) Assinar(string xmlNaoAssinado, string caminhoCertificado, string senhaCertificado, string tagParaAssinar = "", string idAtributoTag = "", bool deveRemoverXmlDeclaration = true);
    }
}
