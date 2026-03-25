package sb.whu;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;

public class WHUSBClient {
    private final String apiKey;
    private final String apiSecret;
    private final String baseUrl;
    private final HttpClient httpClient;

    public WHUSBClient(String apiKey, String apiSecret, String baseUrl) {
        this.apiKey = apiKey;
        this.apiSecret = apiSecret;
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.httpClient = HttpClient.newBuilder().build();
    }

    public WHUSBClient(String apiKey, String apiSecret) {
        this(apiKey, apiSecret, "https://whu.sb/api/v1");
    }

    private String generateSignature(long timestamp) {
        if (apiKey == null || apiSecret == null)
            return "";
        try {
            String payload = apiKey + timestamp + apiSecret;
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(payload.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1)
                    hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Signature generation failed", e);
        }
    }

    private String sendRequest(String method, String endpoint, String jsonBody) throws Exception {
        long timestamp = Instant.now().getEpochSecond();
        String url = baseUrl + (endpoint.startsWith("/") ? endpoint : "/" + endpoint);

        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .header("X-API-Key", apiKey != null ? apiKey : "")
                .header("X-Timestamp", String.valueOf(timestamp));

        if (apiSecret != null) {
            builder.header("X-Signature", generateSignature(timestamp));
        }

        if (method.equals("POST")) {
            builder.POST(HttpRequest.BodyPublishers.ofString(jsonBody != null ? jsonBody : "{}"));
        } else if (method.equals("PUT")) {
            builder.PUT(HttpRequest.BodyPublishers.ofString(jsonBody != null ? jsonBody : "{}"));
        } else if (method.equals("DELETE")) {
            builder.DELETE();
        } else {
            builder.GET();
        }

        HttpResponse<String> response = httpClient.send(builder.build(), HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() >= 400) {
            throw new Exception("API error (" + response.statusCode() + "): " + response.body());
        }

        return response.body();
    }

    // --- Course APIs ---
    public String listCourses(int page, int limit) throws Exception {
        return sendRequest("GET", "/courses?page=" + page + "&limit=" + limit, null);
    }

    public String getCourse(String uid) throws Exception {
        return sendRequest("GET", "/courses/" + uid, null);
    }

    public String searchCourses(String query, int page, int limit) throws Exception {
        String encodedQuery = java.net.URLEncoder.encode(query, StandardCharsets.UTF_8);
        return sendRequest("GET", "/search/courses?query=" + encodedQuery + "&page=" + page + "&limit=" + limit, null);
    }

    // --- Teacher APIs ---
    public String listTeachers(int page, int limit) throws Exception {
        return sendRequest("GET", "/teachers?page=" + page + "&limit=" + limit, null);
    }

    // --- Search APIs ---
    public String simpleSearch(String query, String scope, int page, int limit) throws Exception {
        String encodedQuery = java.net.URLEncoder.encode(query, StandardCharsets.UTF_8);
        return sendRequest("GET",
                "/search/simple?query=" + encodedQuery + "&scope=" + scope + "&page=" + page + "&limit=" + limit, null);
    }

    // --- User APIs ---
    public String getUserMe() throws Exception {
        return sendRequest("GET", "/users/me", null);
    }

    public String getUserDashboard() throws Exception {
        return sendRequest("GET", "/users/dashboard", null);
    }

    // --- Translation APIs ---
    public String translate(String text, String targetLang) throws Exception {
        String jsonBody = String.format("{\"text\":\"%s\",\"target\":\"%s\"}", text, targetLang);
        return sendRequest("POST", "/translation/translate", jsonBody);
    }
}
