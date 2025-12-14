"""
Utilitário para assinatura XML digital.

Usado para assinar o Termo de Autorização do Procurador.
"""

import base64
from datetime import datetime, timezone
from typing import Optional
from lxml import etree
from signxml import XMLSigner, methods
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization


def criar_termo_xml(
    contratante_numero: str,
    contratante_nome: str,
    autor_numero: str,
    autor_nome: str
) -> str:
    """
    Cria XML do Termo de Autorização conforme especificação SERPRO.

    Args:
        contratante_numero: CNPJ/CPF do contratante
        contratante_nome: Razão social/Nome do contratante
        autor_numero: CPF/CNPJ do autor (procurador)
        autor_nome: Nome do autor

    Returns:
        XML como string (sem assinatura - será adicionada depois)
    """
    # Limpar números
    contratante_limpo = contratante_numero.replace(".", "").replace("-", "").replace("/", "")
    autor_limpo = autor_numero.replace(".", "").replace("-", "").replace("/", "")

    # Detectar tipo de documento
    contratante_tipo = "PJ" if len(contratante_limpo) == 14 else "PF"
    autor_tipo = "PJ" if len(autor_limpo) == 14 else "PF"

    # Datas (formato AAAAMMDD)
    agora = datetime.now(timezone.utc)
    data_assinatura = agora.strftime("%Y%m%d")
    # Vigência de 1 ano
    vigencia = agora.replace(year=agora.year + 1)
    data_vigencia = vigencia.strftime("%Y%m%d")

    # XML conforme especificação SERPRO (formato em uma linha como no Dart)
    # Importante: manter em uma linha para garantir assinatura idêntica
    xml = (
        f'<?xml version="1.0" encoding="UTF-8"?>'
        f'<termoDeAutorizacao>'
        f'<dados>'
        f'<sistema id="API Integra Contador"/>'
        f'<termo texto="Autorizo a empresa CONTRATANTE, identificada neste termo de autorização como DESTINATÁRIO, a executar as requisições dos serviços web disponibilizados pela API INTEGRA CONTADOR, onde terei o papel de AUTOR PEDIDO DE DADOS no corpo da mensagem enviada na requisição do serviço web. Esse termo de autorização está assinado digitalmente com o certificado digital do PROCURADOR ou OUTORGADO DO CONTRIBUINTE responsável, identificado como AUTOR DO PEDIDO DE DADOS."/>'
        f'<avisoLegal texto="O acesso a estas informações foi autorizado pelo próprio PROCURADOR ou OUTORGADO DO CONTRIBUINTE, responsável pela informação, via assinatura digital. É dever do destinatário da autorização e consumidor deste acesso observar a adoção de base legal para o tratamento dos dados recebidos conforme artigos 7º ou 11º da LGPD (Lei n.º 13.709, de 14 de agosto de 2018), aos direitos do titular dos dados (art. 9º, 17 e 18, da LGPD) e aos princípios que norteiam todos os tratamentos de dados no Brasil (art. 6º, da LGPD)."/>'
        f'<finalidade texto="A finalidade única e exclusiva desse TERMO DE AUTORIZAÇÃO, é garantir que o CONTRATANTE apresente a API INTEGRA CONTADOR esse consentimento do PROCURADOR ou OUTORGADO DO CONTRIBUINTE assinado digitalmente, para que possa realizar as requisições dos serviços web da API INTEGRA CONTADOR em nome do AUTOR PEDIDO DE DADOS (PROCURADOR ou OUTORGADO DO CONTRIBUINTE)."/>'
        f'<dataAssinatura data="{data_assinatura}"/>'
        f'<vigencia data="{data_vigencia}"/>'
        f'<destinatario numero="{contratante_limpo}" nome="{contratante_nome}" tipo="{contratante_tipo}" papel="contratante"/>'
        f'<assinadoPor numero="{autor_limpo}" nome="{autor_nome}" tipo="{autor_tipo}" papel="autor pedido de dados"/>'
        f'</dados>'
        f'</termoDeAutorizacao>'
    )

    return xml


def assinar_xml(
    xml_content: str,
    cert_bytes: bytes,
    cert_password: str
) -> str:
    """
    Assina XML digitalmente usando certificado P12.
    
    Args:
        xml_content: XML a ser assinado
        cert_bytes: Bytes do certificado P12
        cert_password: Senha do certificado
        
    Returns:
        XML assinado como string
    """
    # Carregar certificado
    private_key, certificate, chain = pkcs12.load_key_and_certificates(
        cert_bytes,
        cert_password.encode() if cert_password else None,
        default_backend()
    )
    
    # Converter para PEM
    key_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    cert_pem = certificate.public_bytes(serialization.Encoding.PEM)
    
    # Parse XML
    root = etree.fromstring(xml_content.encode())
    
    # Criar assinador com C14N 1.0 (exatamente como no Dart)
    # Ver xml_signer.dart linha 120: http://www.w3.org/TR/2001/REC-xml-c14n-20010315
    signer = XMLSigner(
        method=methods.enveloped,
        signature_algorithm="rsa-sha256",
        digest_algorithm="sha256",
        c14n_algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
    )
    
    # Assinar
    signed_root = signer.sign(
        root,
        key=key_pem,
        cert=cert_pem
    )

    # Retornar como string (usar UTF-8 com xml_declaration, depois decodificar)
    xml_bytes = etree.tostring(signed_root, encoding='utf-8', xml_declaration=True)
    return xml_bytes.decode('utf-8')
