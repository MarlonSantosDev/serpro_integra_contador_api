// See https://aka.ms/new-console-template for more information

using Serpro.Componentes.AutenticacaoLoja;

var customerKey = "sua_customer_key";
var customerSecret = "sua_customer_secret";
var certificado = @"certificado.pfx";
var senha = "senha_do_certificado";

var tokensLojaSerpro = await LojaSerpro.GerarTokensTemporariosAsync(customerKey, 
                                                                    customerSecret,
                                                                    certificado,
                                                                    senha);

Console.WriteLine($"expires_in (segundos): {tokensLojaSerpro.Expires_in}");
Console.WriteLine($"scope: {tokensLojaSerpro.Scope}");
Console.WriteLine($"token_type: {tokensLojaSerpro.Token_Type}");
Console.WriteLine($"access_token: {tokensLojaSerpro.Access_Token}");
Console.WriteLine($"jwt_token: {tokensLojaSerpro.Jwt_Token}");
Console.WriteLine();

/* Output:

    expires_in: 1472
    scope: am_application_scope default
    token_type: Bearer
    access_token: baa63388-2c05-3199-9721-6ac10c05976c
        jwt_token: eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOi...
*/
