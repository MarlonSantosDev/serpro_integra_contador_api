import base64
    import json
    from requests_pkcs12 import post
    
    
    def serpro_componentes_autenticacaoLoja():
        url = "endereco_endpoint_autenticacao"
    
        # arquivo exportado em formato PFX ou P12 com a chave privada e senha
        # certificado eCNPJ ICP Brasil do contratante na loja Serpro
        caminho_arquivo = 'caminho_do_arquivo'
        certificado = caminho_arquivo + 'certificado.pfx'
        senha = 'sEnha_do_certificado'
    
        # credenciais loja Serpro para autenticação
        consumer_key = "sua_customer_key"
        consumer_secret = "sua_customer_secret"
    
        # converte as credenciais para base64
        def converter_base64(credenciais):
            return base64.b64encode(credenciais.encode("utf8")).decode("utf8")
    
        # autenticar na loja com o certificado digital do contratante
        def autenticar(ck, cs, certificado, senha):
            headers = {
                "Authorization": "Basic " + converter_base64(ck + ":" + cs),
                "role-type": "TERCEIROS",
                "content-type": "application/x-www-form-urlencoded"
            }
            body = {'grant_type': 'client_credentials'}
            return post(url,
                        data=body,
                        headers=headers,
                        verify=True,
                        pkcs12_filename=certificado,
                        pkcs12_password=senha)
    
        return autenticar(consumer_key, consumer_secret, certificado, senha)
    
    
    response = serpro_componentes_autenticacaoLoja()
    
    print(response.status_code)
    print(json.dumps(json.loads(response.content.decode("utf-8")), indent=4, separators=(',', ': '), sort_keys=True))
    
    #
    # Output:
    #   200
    #   {
    #       "access_token": "05e658b6-212e-3f0e-b068-9d125a3ea479",
    #       "expires_in": 3032,
    #       "jwt_pucomex": null,
    #       "jwt_token": "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIzMzY4MzExMTxj...",
    #       "scope": "am_application_scope default",
    #       "token_type": "Bearer"
    #   }
    #