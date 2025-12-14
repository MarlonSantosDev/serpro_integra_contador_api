"""
Cliente HTTP com mTLS para comunicação com API SERPRO.

Este módulo gerencia certificados digitais e faz requisições autenticadas.
"""

import base64
import tempfile
import os
import ssl
import requests
from typing import Optional, Dict, Any
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.hazmat.backends import default_backend

# Import condicional do Secret Manager (apenas Firebase)
try:
    from google.cloud import secretmanager
    HAS_SECRET_MANAGER = True
except ImportError:
    HAS_SECRET_MANAGER = False


class MtlsClient:
    """Cliente HTTP com suporte a mTLS para API SERPRO."""
    
    # URLs da API SERPRO
    AUTH_URL = "https://autenticacao.sapi.serpro.gov.br/authenticate"
    API_URL_TRIAL = "https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1"
    API_URL_PROD = "https://gateway.apiserpro.serpro.gov.br/integra-contador/v1"
    
    def __init__(
        self,
        cert_base64: Optional[str] = None,
        cert_password: Optional[str] = None,
        secret_name: Optional[str] = None,
        ambiente: str = "trial"
    ):
        """
        Inicializa o cliente mTLS.
        
        Args:
            cert_base64: Certificado P12 em Base64
            cert_password: Senha do certificado
            secret_name: Nome do segredo no Secret Manager (formato: projects/xxx/secrets/xxx/versions/latest)
            ambiente: 'trial' ou 'producao'
        """
        self.cert_base64 = cert_base64
        self.cert_password = cert_password
        self.secret_name = secret_name
        self.ambiente = ambiente
        self._temp_cert_path: Optional[str] = None
        self._temp_key_path: Optional[str] = None
        
    @property
    def api_url(self) -> str:
        """Retorna URL base da API conforme ambiente."""
        return self.API_URL_PROD if self.ambiente == "producao" else self.API_URL_TRIAL
    
    def _get_cert_from_secret_manager(self) -> str:
        """Busca certificado do Google Secret Manager (apenas Firebase)."""
        if not HAS_SECRET_MANAGER:
            raise ValueError("Secret Manager não disponível (apenas Firebase)")

        client = secretmanager.SecretManagerServiceClient()
        response = client.access_secret_version(request={"name": self.secret_name})
        return response.payload.data.decode("UTF-8")

    def _get_password_from_secret_manager(self, secret_name: str) -> str:
        """Busca senha do Secret Manager (apenas Firebase)."""
        if not HAS_SECRET_MANAGER:
            raise ValueError("Secret Manager não disponível (apenas Firebase)")

        client = secretmanager.SecretManagerServiceClient()
        response = client.access_secret_version(request={"name": secret_name})
        return response.payload.data.decode("UTF-8").strip()

    def _extract_cert_and_key(self, p12_bytes: bytes, password: str) -> tuple:
        """Extrai certificado e chave privada do arquivo P12."""
        private_key, certificate, _ = pkcs12.load_key_and_certificates(
            p12_bytes,
            password.encode() if password else None,
            default_backend()
        )
        return private_key, certificate
    
    def _create_temp_files(self, p12_bytes: bytes, password: str) -> tuple:
        """
        Cria arquivos temporários para certificado e chave.
        
        Necessário porque a biblioteca requests precisa de arquivos no filesystem.
        """
        from cryptography.hazmat.primitives import serialization
        
        private_key, certificate = self._extract_cert_and_key(p12_bytes, password)
        
        # Salvar chave privada
        key_fd, key_path = tempfile.mkstemp(suffix='.key')
        with os.fdopen(key_fd, 'wb') as f:
            f.write(private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.TraditionalOpenSSL,
                encryption_algorithm=serialization.NoEncryption()
            ))
        
        # Salvar certificado
        cert_fd, cert_path = tempfile.mkstemp(suffix='.crt')
        with os.fdopen(cert_fd, 'wb') as f:
            f.write(certificate.public_bytes(serialization.Encoding.PEM))
        
        self._temp_cert_path = cert_path
        self._temp_key_path = key_path
        
        return cert_path, key_path
    
    def cleanup(self):
        """Remove arquivos temporários."""
        if self._temp_cert_path and os.path.exists(self._temp_cert_path):
            os.unlink(self._temp_cert_path)
        if self._temp_key_path and os.path.exists(self._temp_key_path):
            os.unlink(self._temp_key_path)
    
    def authenticate(
        self,
        consumer_key: str,
        consumer_secret: str
    ) -> Dict[str, Any]:
        """
        Autentica com OAuth2 usando mTLS.
        
        Args:
            consumer_key: Consumer Key do SERPRO
            consumer_secret: Consumer Secret do SERPRO
            
        Returns:
            Dict com access_token, jwt_token, expires_in, etc.
        """
        # Modo trial não precisa de certificado
        if self.ambiente == "trial":
            return {
                "access_token": "06aef429-a981-3ec5-a1f8-71d38d86481e",
                "jwt_token": "06aef429-a981-3ec5-a1f8-71d38d86481e",
                "expires_in": 2008,
                "token_type": "Bearer",
                "scope": "default"
            }
        
        # Obter certificado
        cert_b64 = self.cert_base64
        password = self.cert_password
        
        if self.secret_name and not cert_b64:
            cert_b64 = self._get_cert_from_secret_manager()
            
        if not cert_b64:
            raise ValueError("Certificado não fornecido para ambiente de produção")
        
        if not password:
            raise ValueError("Senha do certificado não fornecida")
        
        # Decodificar e extrair certificado
        p12_bytes = base64.b64decode(cert_b64)
        cert_path, key_path = self._create_temp_files(p12_bytes, password)
        
        try:
            # Criar Basic Auth
            auth_string = f"{consumer_key}:{consumer_secret}"
            basic_auth = base64.b64encode(auth_string.encode()).decode()
            
            # Fazer requisição com mTLS
            response = requests.post(
                self.AUTH_URL,
                headers={
                    "Authorization": f"Basic {basic_auth}",
                    "role-type": "TERCEIROS",
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                data="grant_type=client_credentials",
                cert=(cert_path, key_path),
                verify=True
            )
            
            response.raise_for_status()
            return response.json()
            
        finally:
            self.cleanup()
    
    def post(
        self,
        endpoint: str,
        data: Dict[str, Any],
        access_token: str,
        jwt_token: str,
        headers: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """
        Faz requisição POST para a API SERPRO.
        
        Args:
            endpoint: Endpoint da API (ex: '/Ccmei/Emitir')
            data: Dados da requisição (body JSON)
            access_token: Token de acesso OAuth2
            jwt_token: JWT token da autenticação
            headers: Headers adicionais
            
        Returns:
            Resposta da API como Dict
        """
        url = f"{self.api_url}{endpoint}"
        
        request_headers = {
            "Authorization": f"Bearer {access_token}",
            "jwt_token": jwt_token,
            "Content-Type": "application/json"
        }
        
        if headers:
            request_headers.update(headers)
        
        # Em trial, não precisa de certificado
        if self.ambiente == "trial":
            response = requests.post(url, json=data, headers=request_headers)
        else:
            # Modo produção com mTLS
            cert_b64 = self.cert_base64
            if self.secret_name and not cert_b64:
                cert_b64 = self._get_cert_from_secret_manager()
            
            if not cert_b64 or not self.cert_password:
                raise ValueError("Certificado necessário para produção")
            
            p12_bytes = base64.b64decode(cert_b64)
            cert_path, key_path = self._create_temp_files(p12_bytes, self.cert_password)
            
            try:
                response = requests.post(
                    url,
                    json=data,
                    headers=request_headers,
                    cert=(cert_path, key_path),
                    verify=True
                )
            finally:
                self.cleanup()
        
        response.raise_for_status()
        return response.json()
