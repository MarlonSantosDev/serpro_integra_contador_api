using Serpro.Componentes.AssinaturaDigital.Interfaces;
using System;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography.Xml;
using System.Xml;

namespace Serpro.Componentes.AssinaturaDigital
{
    public class AssinadorXmlComCertificado : IAssinadorXmlComCertificado
    {
        public (Result, string) Assinar(string xmlNaoAssinado, X509Certificate2 certificado, string tagParaAssinar = "", string idAtributoTag = "", bool deveRemoverXmlDeclaration = true)
        {
            string xmlAssinado;

            try
            {
                var xmlDoc = new XmlDocument();

                xmlDoc.LoadXml(xmlNaoAssinado);

                var elementoParaAssinar = (string.IsNullOrWhiteSpace(tagParaAssinar) ? xmlDoc.DocumentElement : (XmlElement)xmlDoc.GetElementsByTagName(tagParaAssinar)?[0]);

                var signedXml = new SignedXml(elementoParaAssinar)
                {
                    SigningKey = certificado.GetRSAPrivateKey()
                };

                signedXml.SignedInfo.SignatureMethod = SignedXml.XmlDsigRSASHA256Url;

                var reference = new Reference()
                {
                    DigestMethod = SignedXml.XmlDsigSHA256Url,
                    Uri = string.IsNullOrWhiteSpace(idAtributoTag) ? string.Empty : $"#{elementoParaAssinar.Attributes[idAtributoTag].Value}"
                };

                reference.AddTransform(new XmlDsigEnvelopedSignatureTransform());
                reference.AddTransform(new XmlDsigC14NTransform());

                signedXml.AddReference(reference);

                var keyInfo = new KeyInfo();
                keyInfo.AddClause(new KeyInfoX509Data(certificado));

                signedXml.KeyInfo = keyInfo;

                signedXml.ComputeSignature();

                var xmlDigitalSignature = signedXml.GetXml();

                if (String.IsNullOrEmpty(tagParaAssinar))
                {
                    elementoParaAssinar.AppendChild(xmlDoc.ImportNode(xmlDigitalSignature, true));
                }
                else
                {
                    elementoParaAssinar.ParentNode.AppendChild(xmlDoc.ImportNode(xmlDigitalSignature, true));
                }

                if (deveRemoverXmlDeclaration)
                {
                    if (xmlDoc.FirstChild is XmlDeclaration)
                        xmlDoc.RemoveChild(xmlDoc.FirstChild);
                }


                xmlAssinado = xmlDoc.InnerXml;
            }
            catch (Exception e)
            {
                return (new Result(false, e.Message), default);
            }

            return (new Result(true), xmlAssinado);
        }
    }
}
