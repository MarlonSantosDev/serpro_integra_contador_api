<?php
date_default_timezone_set('America/Sao_Paulo');

// DADOS DO DESTINATÁRIO
$destinatario_numero = 'aqui_vai_o_CNPJ_do_contratante';
$destinatario_nome = 'aqui_vai_o_razão_social_contratante';
$destinatario_tipo = 'PJ';
$destinatario_papel = 'contratante';

// DADOS DO ASSINANTE*/
$assinante_numero = 'aqui_vai_o_numero_CPF_ou_CNPJ_de_quem_vai_assinar';
$assinante_nome = 'aqui_vai_o_nome_exato_CPF_ou_CNPJ_de_quem_vai_assinar';
$assinante_tipo = 'PF_ou_PJ';
$assinante_papel = 'autor pedido de dados';

// Certificado digital
$arquivoCertificado = 'arquivo.pfx';
$senhaCertificado = 'sEnha';

// DATAS
$data_assinatura = date("Ymd");
$data_vigencia_termo = '+30 days';

function montarTermoAutorizacao()
{
	$stringRoot = <<<XML
	<?xml version='1.0' encoding='UTF-8'?><termoDeAutorizacao></termoDeAutorizacao>
	XML;

	$xmlNaoAssinado = new SimpleXMLElement($stringRoot);

	$dados = $xmlNaoAssinado->addChild('dados');

	$sistema = $dados->addChild('sistema');
	$sistema->addAttribute('id', 'API Integra Contador');

	$termo = $dados->addChild('termo');
	$termo->addAttribute('texto', 'Autorizo a empresa CONTRATANTE, identificada neste termo de autorização como DESTINATÁRIO, a executar as requisições dos serviços web disponibilizados pela API INTEGRA CONTADOR, onde terei o papel de AUTOR PEDIDO DE DADOS no corpo da mensagem enviada na requisição do serviço web. Esse termo de autorização está assinado digitalmente com o certificado digital do PROCURADOR ou OUTORGADO DO CONTRIBUINTE responsável, identificado como AUTOR DO PEDIDO DE DADOS.');

	$avisoLegal = $dados->addChild('avisoLegal');
	$avisoLegal->addAttribute('texto', 'O acesso a estas informações foi autorizado pelo próprio PROCURADOR ou OUTORGADO DO CONTRIBUINTE, responsável pela informação, via assinatura digital. É dever do destinatário da autorização e consumidor deste acesso observar a adoção de base legal para o tratamento dos dados recebidos conforme artigos 7º ou 11º da LGPD (Lei n.º 13.709, de 14 de agosto de 2018), aos direitos do titular dos dados (art. 9º, 17 e 18, da LGPD) e aos princípios que norteiam todos os tratamentos de dados no Brasil (art. 6º, da LGPD).');

	$finalidade = $dados->addChild('finalidade ');
	$finalidade->addAttribute('texto', 'A finalidade única e exclusiva desse TERMO DE AUTORIZAÇÃO, é garantir que o CONTRATANTE apresente a API INTEGRA CONTADOR esse consentimento do PROCURADOR ou OUTORGADO DO CONTRIBUINTE assinado digitalmente, para que possa realizar as requisições dos serviços web da API INTEGRA CONTADOR em nome do AUTOR PEDIDO DE DADOS (PROCURADOR ou OUTORGADO DO CONTRIBUINTE).');

	$dataAssinatura = $dados->addChild('dataAssinatura');
	$dataAssinatura->addAttribute('data', $GLOBALS['data_assinatura']);

	$vigencia = $dados->addChild('vigencia');
	$vigencia->addAttribute('data', date('Ymd', strtotime($GLOBALS['data_vigencia_termo'])));

	$destinatario = $dados->addChild('destinatario');
	$destinatario->addAttribute('numero', $GLOBALS['destinatario_numero']);
	$destinatario->addAttribute('nome', $GLOBALS['destinatario_nome']);
	$destinatario->addAttribute('tipo', $GLOBALS['destinatario_tipo']);
	$destinatario->addAttribute('papel', $GLOBALS['destinatario_papel']);

	$assinadoPor = $dados->addChild('assinadoPor');
	$assinadoPor->addAttribute('numero', $GLOBALS['assinante_numero']);
	$assinadoPor->addAttribute('nome', $GLOBALS['assinante_nome']);
	$assinadoPor->addAttribute('tipo', $GLOBALS['assinante_tipo']);
	$assinadoPor->addAttribute('papel', $GLOBALS['assinante_papel']);

	return $xmlNaoAssinado;
}

function carregarCertificados()
{
	$arquivo = $GLOBALS['arquivoCertificado'];
	$certs = $GLOBALS['certificados'];
	$senha = $GLOBALS['senhaCertificado'];

	$conteudo = file_get_contents($arquivo);
	openssl_pkcs12_read($conteudo, $certs, $senha);
	return $certs;
}

function obterPrivateKey($certificados)
{
	return $certificados["pkey"];
}

function obterCertificado($certificados)
{
	return $certificados["cert"];
}

function obterx509Certificate($certificados)
{
	// <X509Certificate>
	$x509Certificate = obterCertificado($certificados);
	$x509Certificate = str_replace('-----END CERTIFICATE-----', ' ', $x509Certificate);
	$x509Certificate = str_replace('-----BEGIN CERTIFICATE-----', ' ', $x509Certificate);
	return preg_replace("/\r|\n/", "", trim($x509Certificate));
}

function assinar($xmlNaoAssinado, $certificados)
{
	// Leitura do XML que contém o documento Termo de Autorização ainda não assinado
	$xml = new DOMDocument();

	// Preservando os espaços em branco
	$xml->preserveWhiteSpace = true;
	$xml->formatOutput = false;

	$xml->loadXML($xmlNaoAssinado->asXML());

	// Canonizar o conteúdo, exclusivo e sem comentários
	if (!$xml->documentElement) {
		throw new UnexpectedValueException('Indefindo o elemento documentElement');
	}

	$canonicalData = $xml->documentElement->C14N(true, false);

	// Calcular o digest
	$digestValue = openssl_digest($canonicalData, "sha256", true);
	if ($digestValue === false) {
		throw new UnexpectedValueException('Invalid digest value');
	}

	// Codificar para base64 (encode)
	$digestValue = base64_encode($digestValue);

	// Adiciona os elementos que vai compor a tag Signature com a assinatura digital
	$signatureElement = $xml->createElement('Signature');
	$signatureElement->setAttribute('xmlns', 'http://www.w3.org/2000/09/xmldsig#');
	$xml->documentElement->appendChild($signatureElement);

	$signedInfoElement = $xml->createElement('SignedInfo');
	$signatureElement->appendChild($signedInfoElement);

	$canonicalizationMethodElement = $xml->createElement('CanonicalizationMethod');
	$canonicalizationMethodElement->setAttribute('Algorithm', 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315');
	$signedInfoElement->appendChild($canonicalizationMethodElement);

	$signatureMethodElement = $xml->createElement('SignatureMethod');
	$signatureMethodElement->setAttribute('Algorithm', 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256');
	$signedInfoElement->appendChild($signatureMethodElement);

	$referenceElement = $xml->createElement('Reference');
	$referenceElement->setAttribute('URI', '');
	$signedInfoElement->appendChild($referenceElement);

	$transformsElement = $xml->createElement('Transforms');
	$referenceElement->appendChild($transformsElement);

	$transformElement = $xml->createElement('Transform');
	$transformElement->setAttribute('Algorithm', 'http://www.w3.org/2000/09/xmldsig#enveloped-signature');
	$transformsElement->appendChild($transformElement);

	$transformElement = $xml->createElement('Transform');
	$transformElement->setAttribute('Algorithm', 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315');
	$transformsElement->appendChild($transformElement);

	$digestMethodElement = $xml->createElement('DigestMethod');
	$digestMethodElement->setAttribute('Algorithm', 'http://www.w3.org/2001/04/xmlenc#sha256');
	$referenceElement->appendChild($digestMethodElement);

	$digestValueElement = $xml->createElement('DigestValue', $digestValue);
	$referenceElement->appendChild($digestValueElement);

	$signatureValueElement = $xml->createElement('SignatureValue', '');
	$signatureElement->appendChild($signatureValueElement);

	$keyInfoElement = $xml->createElement('KeyInfo');
	$signatureElement->appendChild($keyInfoElement);

	$X509Data = $xml->createElement('X509Data');
	$keyInfoElement->appendChild($X509Data);

	$X509Certificate = $xml->createElement('X509Certificate', obterx509Certificate($certificados));
	$X509Data->appendChild($X509Certificate);

	$c14nSignedInfo = $signedInfoElement->C14N(true, false);

	$status = openssl_sign($c14nSignedInfo, $signatureValue, obterPrivateKey($certificados), OPENSSL_ALGO_SHA256);

	if (!$status) {
		throw new Exception('Falha no cálculo da assinatura.');
	}

	$xpath = new DOMXpath($xml);
	$signatureValueElement = $xpath->query('//SignatureValue', $signatureElement)->item(0);
	$signatureValueElement->nodeValue = base64_encode($signatureValue);

	return $xml->saveXML();
}

$certificados = array();

$xmlNaoAssinado = montarTermoAutorizacao();

$certificados = carregarCertificados();

$resultado = assinar($xmlNaoAssinado, $certificados);

echo '<textarea>' . $resultado . '</textarea>';
echo '<textarea>' . base64_encode($resultado) . '</textarea>';

/* Output:

Textarea1 xml assinado:
<?xml version="1.0" encoding="UTF-8"?>
<termoDeAutorizacao><dados><sistema id="API Integra Contador"/>...

Textarea2 xml assinado em base64: 
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHRlcm1vRdd...

*/
