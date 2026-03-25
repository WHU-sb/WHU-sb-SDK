using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace WHUSBSDK
{
    public class WHUSBClient
    {
        private readonly string _apiKey;
        private readonly string _apiSecret;
        private readonly string _baseUrl;
        private readonly HttpClient _httpClient;

        public WHUSBClient(string apiKey = null, string apiSecret = null, string baseUrl = null)
        {
            _apiKey = apiKey;
            _apiSecret = apiSecret;
            _baseUrl = (baseUrl ?? Environment.GetEnvironmentVariable("WHUSB_API_BASE_URL") ?? "https://api.whu.sb/api/v1").TrimEnd('/');
            _httpClient = new HttpClient();
        }

        private string GenerateSignature(long timestamp)
        {
            if (string.IsNullOrEmpty(_apiKey) || string.IsNullOrEmpty(_apiSecret)) return "";
            var payload = $"{_apiKey}{timestamp}{_apiSecret}";
            var payloadBytes = Encoding.UTF8.GetBytes(payload);
            using (var sha256 = SHA256.Create())
            {
                var hash = sha256.ComputeHash(payloadBytes);
                return BitConverter.ToString(hash).Replace("-", "").ToLower();
            }
        }

        private async Task<T> RequestAsync<T>(HttpMethod method, string endpoint, object body = null, Dictionary<string, string> query = null)
        {
            var url = $"{_baseUrl}/{endpoint.TrimStart('/')}";
            if (query != null && query.Count > 0)
            {
                var q = new List<string>();
                foreach (var pair in query) q.Add($"{pair.Key}={Uri.EscapeDataString(pair.Value)}");
                url += "?" + string.Join("&", q);
            }

            var request = new HttpRequestMessage(method, url);
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            
            request.Headers.Add("X-API-Key", _apiKey ?? "");
            request.Headers.Add("X-Timestamp", timestamp.ToString());

            if (!string.IsNullOrEmpty(_apiSecret))
            {
                request.Headers.Add("X-Signature", GenerateSignature(timestamp));
            }

            if (body != null)
            {
                var json = JsonConvert.SerializeObject(body);
                request.Content = new StringContent(json, Encoding.UTF8, "application/json");
            }

            var response = await _httpClient.SendAsync(request);
            var responseJson = await response.Content.ReadAsStringAsync();
            var apiResponse = JsonConvert.DeserializeObject<APIResponse<T>>(responseJson);

            if (!response.IsSuccessStatusCode || !apiResponse.Success)
            {
                throw new Exception($"API Request Failed: {apiResponse?.Message ?? response.ReasonPhrase}");
            }

            return apiResponse.Data;
        }

        // --- Course APIs ---

        public async Task<dynamic> ListCoursesAsync(int page = 1, int limit = 20)
        {
            var query = new Dictionary<string, string> { { "page", page.ToString() }, { "limit", limit.ToString() } };
            return await RequestAsync<dynamic>(HttpMethod.Get, "courses", query: query);
        }

        public async Task<dynamic> SearchCoursesAsync(string query, int page = 1, int limit = 12)
        {
            var q = new Dictionary<string, string> { { "query", query }, { "page", page.ToString() }, { "limit", limit.ToString() } };
            return await RequestAsync<dynamic>(HttpMethod.Get, "search/courses", query: q);
        }

        // --- User APIs ---

        public async Task<dynamic> GetMeAsync()
        {
            return await RequestAsync<dynamic>(HttpMethod.Get, "users/me");
        }

        // --- Translation APIs ---

        public async Task<dynamic> TranslateAsync(string text, string target)
        {
            var body = new { text, target };
            return await RequestAsync<dynamic>(HttpMethod.Post, "translation/translate", body: body);
        }
    }

    public class APIResponse<T>
    {
        public bool Success { get; set; }
        public T Data { get; set; }
        public string Message { get; set; }
    }
}
