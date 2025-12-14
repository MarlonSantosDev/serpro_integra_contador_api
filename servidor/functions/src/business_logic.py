"""
Lógica de negócio compartilhada entre Firebase e Localhost.

Este arquivo contém TODA a lógica de autenticação e processamento.
Ele é importado tanto por firebase.py quanto por localhost.py
"""

import json
import base64
from typing import Dict, Any, Optional, List

from src.mtls_client import MtlsClient
from src.xml_signer import criar_termo_xml, assinar_xml


def validate_request_data(data: Dict, required_fields: List[str]) -> Optional[str]:
    """Valida dados da requisição."""
    # Verificar campos obrigatórios
    for field in required_fields:
        if field not in data or not data[field]:
            return f"Campo obrigatório ausente: {field}"

    # Validar formato CNPJ/CPF
    contratante = data.get("contratante_numero", "")
    if contratante:
        clean = contratante.replace(".", "").replace("-", "").replace("/", "")
        if len(clean) not in [11, 14]:
            return "Formato inválido para contratante_numero: deve ter 11 (CPF) ou 14 (CNPJ) dígitos"

    autor = data.get("autor_pedido_dados_numero", "")
    if autor:
        clean = autor.replace(".", "").replace("-", "").replace("/", "")
        if len(clean) not in [11, 14]:
            return "Formato inválido para autor_pedido_dados_numero: deve ter 11 (CPF) ou 14 (CNPJ) dígitos"

    # Validar ambiente
    ambiente = data.get("ambiente", "")
    if ambiente and ambiente not in ["trial", "producao"]:
        return f"Ambiente inválido: '{ambiente}'. Use 'trial' ou 'producao'."

    return None


def process_autenticar_serpro(data: Dict[str, Any], get_secret_fn=None) -> Dict[str, Any]:
    """
    Processa autenticação SERPRO.

    Args:
        data: Dados da requisição
        get_secret_fn: Função opcional para buscar secrets (Firebase)

    Returns:
        Dict com tokens de autenticação
    """
    # Validar dados
    validation_error = validate_request_data(data, [
        "consumer_key", "consumer_secret",
        "contratante_numero", "autor_pedido_dados_numero"
    ])
    if validation_error:
        raise ValueError(validation_error)

    ambiente = data.get("ambiente", "trial")

    # Obter certificado (prioridade: body > Secret Manager)
    cert_base64 = data.get("certificado_base64")
    cert_password = data.get("certificado_senha")

    # Se não veio no body, tentar Secret Manager (se disponível)
    if get_secret_fn and ambiente == "producao" and not cert_base64:
        cert_secret = data.get("cert_secret_name")
        password_secret = data.get("cert_password_secret_name")

        if cert_secret:
            cert_base64 = get_secret_fn(cert_secret)
        if password_secret:
            cert_password = get_secret_fn(password_secret)

    # Criar cliente mTLS
    client = MtlsClient(
        cert_base64=cert_base64,
        cert_password=cert_password,
        ambiente=ambiente
    )

    # Autenticar
    result = client.authenticate(
        consumer_key=data["consumer_key"],
        consumer_secret=data["consumer_secret"]
    )

    # Adicionar dados extras
    result["contratante_numero"] = data["contratante_numero"]
    result["autor_pedido_dados_numero"] = data["autor_pedido_dados_numero"]

    return result


def process_autenticar_procurador(data: Dict[str, Any], get_secret_fn=None) -> Dict[str, Any]:
    """
    Processa autenticação de procurador.

    Args:
        data: Dados da requisição
        get_secret_fn: Função opcional para buscar secrets (Firebase)

    Returns:
        Dict com tokens de autenticação + procurador_token
    """
    # Validar dados
    validation_error = validate_request_data(data, [
        "consumer_key", "consumer_secret",
        "contratante_numero", "contratante_nome",
        "autor_pedido_dados_numero", "autor_nome"
    ])
    if validation_error:
        raise ValueError(validation_error)

    ambiente = data.get("ambiente", "trial")

    # Obter certificado
    cert_base64 = data.get("certificado_base64")
    cert_password = data.get("certificado_senha")

    if get_secret_fn and ambiente == "producao" and not cert_base64:
        cert_secret = data.get("cert_secret_name")
        password_secret = data.get("cert_password_secret_name")

        if cert_secret and password_secret:
            cert_base64 = get_secret_fn(cert_secret)
            cert_password = get_secret_fn(password_secret)

    # 1. OAuth2
    client = MtlsClient(
        cert_base64=cert_base64,
        cert_password=cert_password,
        ambiente=ambiente
    )

    auth_result = client.authenticate(
        consumer_key=data["consumer_key"],
        consumer_secret=data["consumer_secret"]
    )

    # Trial mode
    if ambiente == "trial":
        auth_result["contratante_numero"] = data["contratante_numero"]
        auth_result["autor_pedido_dados_numero"] = data["autor_pedido_dados_numero"]
        auth_result["procurador_token"] = "trial_procurador_token_simulado"
        return auth_result

    # 2. Criar XML
    contribuinte = data.get("contribuinte_numero", data["contratante_numero"])

    xml_termo = criar_termo_xml(
        contratante_numero=data["contratante_numero"],
        contratante_nome=data["contratante_nome"],
        autor_numero=data["autor_pedido_dados_numero"],
        autor_nome=data["autor_nome"]
    )

    # 3. Assinar XML
    cert_bytes = base64.b64decode(cert_base64)
    xml_assinado = assinar_xml(xml_termo, cert_bytes, cert_password)

    # 4. Enviar para API
    xml_base64 = base64.b64encode(xml_assinado.encode()).decode()

    # Limpar números para detectar tipo corretamente
    contratante_limpo = data["contratante_numero"].replace(".", "").replace("-", "").replace("/", "")
    autor_limpo = data["autor_pedido_dados_numero"].replace(".", "").replace("-", "").replace("/", "")
    contribuinte_limpo = contribuinte.replace(".", "").replace("-", "").replace("/", "")

    request_body = {
        "contratante": {
            "numero": contratante_limpo,
            "tipo": 2 if len(contratante_limpo) == 14 else 1
        },
        "autorPedidoDados": {
            "numero": autor_limpo,
            "tipo": 2 if len(autor_limpo) == 14 else 1
        },
        "contribuinte": {
            "numero": contribuinte_limpo,
            "tipo": 2 if len(contribuinte_limpo) == 14 else 1
        },
        "pedidoDados": {
            "idSistema": "AUTENTICAPROCURADOR",
            "idServico": "ENVIOXMLASSINADO81",
            "versaoSistema": "1.0",
            "dados": json.dumps({"xml": xml_base64})
        }
    }

    # Debug log (remover em produção se necessário)
    import logging
    logging.info(f"[autenticar_procurador] Request body - Contratante: {contratante_limpo} (tipo: {request_body['contratante']['tipo']}), Autor: {autor_limpo} (tipo: {request_body['autorPedidoDados']['tipo']})")

    response = client.post(
        endpoint="/Apoiar",
        data=request_body,
        access_token=auth_result["access_token"],
        jwt_token=auth_result["jwt_token"]
    )

    # Extrair token
    procurador_token = None
    if "dados" in response and "autenticarProcuradorToken" in response.get("dados", {}):
        procurador_token = response["dados"]["autenticarProcuradorToken"]
    elif "autenticarProcuradorToken" in response:
        procurador_token = response["autenticarProcuradorToken"]

    # Resposta
    result = {
        **auth_result,
        "contratante_numero": data["contratante_numero"],
        "autor_pedido_dados_numero": data["autor_pedido_dados_numero"],
        "procurador_token": procurador_token,
        "contribuinte_numero": contribuinte
    }

    return result


def process_proxy_serpro(data: Dict[str, Any], get_secret_fn=None) -> Dict[str, Any]:
    """
    Processa proxy genérico SERPRO.

    Args:
        data: Dados da requisição
        get_secret_fn: Função opcional para buscar secrets (Firebase)

    Returns:
        Dict com resposta da API SERPRO
    """
    # Validar dados
    validation_error = validate_request_data(data, [
        "endpoint", "body", "access_token", "jwt_token"
    ])
    if validation_error:
        raise ValueError(validation_error)

    ambiente = data.get("ambiente", "trial")

    # Obter certificado
    cert_base64 = data.get("certificado_base64")
    cert_password = data.get("certificado_senha")

    if get_secret_fn and ambiente == "producao":
        cert_secret = data.get("cert_secret_name")
        password_secret = data.get("cert_password_secret_name")

        if cert_secret:
            cert_base64 = get_secret_fn(cert_secret)
        if password_secret:
            cert_password = get_secret_fn(password_secret)

    # Criar cliente
    client = MtlsClient(
        cert_base64=cert_base64,
        cert_password=cert_password,
        ambiente=ambiente
    )

    # Headers adicionais
    headers = {}
    if data.get("procurador_token"):
        headers["autenticar_procurador_token"] = data["procurador_token"]

    # Fazer requisição
    result = client.post(
        endpoint=data["endpoint"],
        data=data["body"],
        access_token=data["access_token"],
        jwt_token=data["jwt_token"],
        headers=headers
    )

    return result
