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
    Cria XML do Termo de Autorização.
    
    Args:
        contratante_numero: CNPJ do contratante
        contratante_nome: Razão social do contratante
        autor_numero: CPF/CNPJ do autor (procurador)
        autor_nome: Nome do autor
        
    Returns:
        XML como string
    """
    # Detectar tipo de documento
    contratante_tipo = "2" if len(contratante_numero.replace(".", "").replace("-", "").replace("/", "")) == 14 else "1"
    autor_tipo = "2" if len(autor_numero.replace(".", "").replace("-", "").replace("/", "")) == 14 else "1"
    
    # Data/hora atual
    agora = datetime.now(timezone.utc)
    data_hora = agora.strftime("%Y-%m-%dT%H:%M:%S.000-03:00")
    
    xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<TermoAutorizacao>
    <contratanteNumero>{contratante_numero}</contratanteNumero>
    <contratanteTipo>{contratante_tipo}</contratanteTipo>
    <contratanteNome>{contratante_nome}</contratanteNome>
    <autorPedidoDadosNumero>{autor_numero}</autorPedidoDadosNumero>
    <autorPedidoDadosTipo>{autor_tipo}</autorPedidoDadosTipo>
    <autorPedidoDadosNome>{autor_nome}</autorPedidoDadosNome>
    <dataHora>{data_hora}</dataHora>
</TermoAutorizacao>'''
    
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
    
    # Criar assinador
    signer = XMLSigner(
        method=methods.enveloped,
        signature_algorithm="rsa-sha256",
        digest_algorithm="sha256"
    )
    
    # Assinar
    signed_root = signer.sign(
        root,
        key=key_pem,
        cert=cert_pem
    )
    
    # Retornar como string
    return etree.tostring(signed_root, encoding='unicode', xml_declaration=True)
