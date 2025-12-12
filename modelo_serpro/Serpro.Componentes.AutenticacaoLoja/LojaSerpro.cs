using System.Net.Http.Json;
using System.Net.Security;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;

namespace Serpro.Componentes.AutenticacaoLoja;
public static class LojaSerpro
{
    private const string ENDPOINT_LOJA_SERPRO = "endereco_endpoint_de_autenticacao";

    public static async Task<TokensLojaSerpro> GerarTokensTemporariosAsync(string consumerKey, string consumerSecret, string certificado, string senhaCertificado)
    {
        string autBase64 = EncodeBase64($"{consumerKey}:{consumerSecret}");

        using HttpClientHandler httpClientHandler = AdicionarPfx(certificado, senhaCertificado);
        using HttpClient client = new(httpClientHandler);
        Uri uri = new(ENDPOINT_LOJA_SERPRO);
        client.BaseAddress = uri;

        HttpRequestMessage request = new(HttpMethod.Post, "authenticate");

        request.Headers.Clear();
        request.Headers.Add("Authorization", $"Basic {autBase64}");
        request.Headers.Add("Role-Type", "TERCEIROS");
        request.Content = new StringContent("grant_type=client_credentials", Encoding.UTF8, "application/json"); //CONTENT-TYPE header               

        Task<HttpResponseMessage> response = client.SendAsync(request);

        return await response.Result.Content.ReadFromJsonAsync<TokensLojaSerpro>(OpcoesDesserializarJson);

    }

    private static HttpClientHandler AdicionarPfx(string certificado, string senha)
    {
        HttpClientHandler clientHandler = new();
        X509Certificate2 certificadoPfx = new(certificado, senha);
        clientHandler.SslProtocols = SslProtocols.Tls12;
        clientHandler.ClientCertificateOptions = ClientCertificateOption.Manual;
        clientHandler.ClientCertificates.Add(certificadoPfx);

        clientHandler.ServerCertificateCustomValidationCallback +=
            (HttpRequestMessage req, X509Certificate2 cert2, X509Chain chain, SslPolicyErrors err) => { return true; };

        return clientHandler;
    }

    private static JsonSerializerOptions OpcoesDesserializarJson
    => new() { PropertyNameCaseInsensitive = true };

    private static string EncodeBase64(string str)
    => Convert.ToBase64String(Encoding.UTF8.GetBytes(str));
}

/// <summary>
/// Estrutura de dados com os dados dos Tokens.
/// </summary>
public record TokensLojaSerpro
{
    [JsonPropertyName("expires_in")]
    public int Expires_in { get; set; }

    [JsonPropertyName("scope")]
    public string Scope { get; set; }

    [JsonPropertyName("token_type")]
    public string Token_Type { get; set; }

    [JsonPropertyName("access_token")]
    public string Access_Token { get; set; }

    [JsonPropertyName("jwt_token")]
    public string Jwt_Token { get; set; }

}

