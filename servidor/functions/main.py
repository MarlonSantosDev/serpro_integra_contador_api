"""
Firebase Cloud Functions - Wrapper para business_logic.py

Este arquivo APENAS define os endpoints do Firebase.
TODA a lógica de negócio está em business_logic.py
"""

import json
from typing import Any, Dict, Optional
from firebase_functions import https_fn, options
from firebase_admin import initialize_app, auth
from google.cloud import secretmanager

# Importar lógica de negócio centralizada
from src.business_logic import (
    process_autenticar_serpro,
    process_autenticar_procurador,
    process_proxy_serpro
)

# Inicializar Firebase Admin
initialize_app()

# Configurar CORS
cors_options = options.CorsOptions(
    cors_origins="*",
    cors_methods=["POST", "OPTIONS"]
)


def _get_secret(secret_name: str) -> str:
    """Busca valor do Secret Manager."""
    client = secretmanager.SecretManagerServiceClient()
    response = client.access_secret_version(request={"name": secret_name})
    return response.payload.data.decode("UTF-8").strip()


def _verify_firebase_token(request: https_fn.Request) -> Optional[Dict]:
    """Verifica token Firebase (OPCIONAL)."""
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return None

    token = auth_header.replace("Bearer ", "")
    try:
        return auth.verify_id_token(token)
    except Exception as e:
        print(f"[INFO] Token verification failed (non-blocking): {e}")
        return None


def _error_response(message: str, status: int = 400) -> https_fn.Response:
    """Cria resposta de erro."""
    return https_fn.Response(
        json.dumps({"error": message, "status": status}),
        status=status,
        headers={"Content-Type": "application/json"}
    )


def _success_response(data: Dict[str, Any]) -> https_fn.Response:
    """Cria resposta de sucesso."""
    return https_fn.Response(
        json.dumps(data),
        status=200,
        headers={"Content-Type": "application/json"}
    )


@https_fn.on_request(cors=cors_options)
def autenticar_serpro(request: https_fn.Request) -> https_fn.Response:
    """Endpoint Firebase: Autenticar SERPRO."""
    try:
        data = request.get_json()
        _verify_firebase_token(request)  # Opcional

        # Chamar lógica centralizada
        result = process_autenticar_serpro(data, get_secret_fn=_get_secret)

        return _success_response(result)
    except ValueError as e:
        return _error_response(str(e), 400)
    except Exception as e:
        return _error_response(str(e), 500)


@https_fn.on_request(cors=cors_options)
def autenticar_procurador(request: https_fn.Request) -> https_fn.Response:
    """Endpoint Firebase: Autenticar Procurador."""
    try:
        data = request.get_json()
        _verify_firebase_token(request)  # Opcional

        # Chamar lógica centralizada
        result = process_autenticar_procurador(data, get_secret_fn=_get_secret)

        return _success_response(result)
    except ValueError as e:
        return _error_response(str(e), 400)
    except Exception as e:
        return _error_response(str(e), 500)


@https_fn.on_request(cors=cors_options)
def proxy_serpro(request: https_fn.Request) -> https_fn.Response:
    """Endpoint Firebase: Proxy SERPRO."""
    try:
        data = request.get_json()
        _verify_firebase_token(request)  # Opcional

        # Chamar lógica centralizada
        result = process_proxy_serpro(data, get_secret_fn=_get_secret)

        return _success_response(result)
    except ValueError as e:
        return _error_response(str(e), 400)
    except Exception as e:
        return _error_response(str(e), 500)
