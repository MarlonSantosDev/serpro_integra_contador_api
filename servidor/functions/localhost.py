"""
FastAPI Servidor Server - Wrapper para business_logic.py

Este arquivo APENAS define os endpoints do FastAPI.
TODA a lógica de negócio está em business_logic.py
"""

import logging
from typing import Dict, Any, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Importar lógica de negócio centralizada
from src.business_logic import (
    process_autenticar_serpro,
    process_autenticar_procurador,
    process_proxy_serpro
)

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Criar app FastAPI
app = FastAPI(
    title="SERPRO mTLS Proxy",
    description="Proxy mTLS para API SERPRO (Localhost)",
    version="2.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ===== MODELS =====

class AutenticarSerproRequest(BaseModel):
    consumer_key: str
    consumer_secret: str
    contratante_numero: str
    autor_pedido_dados_numero: str
    ambiente: str = "trial"
    certificado_base64: Optional[str] = None
    certificado_senha: Optional[str] = None


class AutenticarProcuradorRequest(BaseModel):
    consumer_key: str
    consumer_secret: str
    contratante_numero: str
    contratante_nome: str
    autor_pedido_dados_numero: str
    autor_nome: str
    contribuinte_numero: Optional[str] = None
    ambiente: str = "trial"
    certificado_base64: Optional[str] = None
    certificado_senha: Optional[str] = None


class ProxySerproRequest(BaseModel):
    endpoint: str
    body: Dict[str, Any]
    access_token: str
    jwt_token: str
    procurador_token: Optional[str] = None
    ambiente: str = "trial"
    certificado_base64: Optional[str] = None
    certificado_senha: Optional[str] = None


# ===== ENDPOINTS =====

@app.get("/")
async def root():
    """Health check."""
    return {
        "status": "online",
        "service": "SERPRO mTLS Proxy",
        "version": "2.0.0",
        "mode": "servidor",
        "endpoints": [
            "POST /autenticar_serpro",
            "POST /autenticar_procurador",
            "POST /proxy_serpro"
        ]
    }


@app.post("/autenticar_serpro")
async def autenticar_serpro(request: AutenticarSerproRequest):
    """Endpoint FastAPI: Autenticar SERPRO."""
    try:
        logger.info(f"[autenticar_serpro] Ambiente: {request.ambiente}")

        # Chamar lógica centralizada (sem Secret Manager)
        result = process_autenticar_serpro(request.model_dump(), get_secret_fn=None)

        logger.info(f"[autenticar_serpro] OK para {request.contratante_numero}")
        return result
    except ValueError as e:
        logger.error(f"[autenticar_serpro] Erro de validação: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"[autenticar_serpro] Erro: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/autenticar_procurador")
async def autenticar_procurador(request: AutenticarProcuradorRequest):
    """Endpoint FastAPI: Autenticar Procurador."""
    try:
        logger.info(f"[autenticar_procurador] Ambiente: {request.ambiente}")

        # Chamar lógica centralizada (sem Secret Manager)
        result = process_autenticar_procurador(request.model_dump(), get_secret_fn=None)

        logger.info(f"[autenticar_procurador] OK para {request.autor_pedido_dados_numero}")
        return result
    except ValueError as e:
        logger.error(f"[autenticar_procurador] Erro de validação: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"[autenticar_procurador] Erro: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/proxy_serpro")
async def proxy_serpro(request: ProxySerproRequest):
    """Endpoint FastAPI: Proxy SERPRO."""
    try:
        logger.info(f"[proxy_serpro] Endpoint: {request.endpoint}")

        # Chamar lógica centralizada (sem Secret Manager)
        result = process_proxy_serpro(request.model_dump(), get_secret_fn=None)

        logger.info(f"[proxy_serpro] OK para {request.endpoint}")
        return result
    except ValueError as e:
        logger.error(f"[proxy_serpro] Erro de validação: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"[proxy_serpro] Erro: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


# ===== EXECUTAR SERVIDOR =====

if __name__ == "__main__":
    import uvicorn

    print("=" * 60)
    print("SERPRO mTLS Proxy Server (Localhost)")
    print("=" * 60)
    print("URL: http://localhost:8000")
    print("Docs: http://localhost:8000/docs")
    print("=" * 60)
    print()

    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
