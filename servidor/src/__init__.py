"""
Módulo src - Lógica de negócio do servidor SERPRO mTLS.

Este pacote contém toda a lógica de negócio compartilhada entre:
- Firebase Functions (main.py)
- Servidor FastAPI Local (localhost.py)
"""

from src.business_logic import (
    process_autenticar_serpro,
    process_autenticar_procurador,
    process_proxy_serpro
)
from src.mtls_client import MtlsClient
from src.xml_signer import criar_termo_xml, assinar_xml

__all__ = [
    "process_autenticar_serpro",
    "process_autenticar_procurador",
    "process_proxy_serpro",
    "MtlsClient",
    "criar_termo_xml",
    "assinar_xml",
]
