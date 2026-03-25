<?php

namespace WHUSBSDK;

class Client
{
    private $apiKey;
    private $apiSecret;
    private $baseUrl;

    public function __construct(array $config)
    {
        $this->apiKey = $config['apiKey'] ?? null;
        $this->apiSecret = $config['apiSecret'] ?? null;
        $this->baseUrl = rtrim($config['baseUrl'] ?? 'https://whu.sb/api/v1', '/');
    }

    private function generateSignature(int $timestamp): string
    {
        if (!$this->apiKey || !$this->apiSecret) return "";
        $payload = $this->apiKey . $timestamp . $this->apiSecret;
        return hash('sha256', $payload);
    }

    private function request(string $method, string $endpoint, array $params = [], array $body = [])
    {
        $url = $this->baseUrl . '/' . ltrim($endpoint, '/');
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }

        $timestamp = time();
        $headers = [
            'Content-Type: application/json',
            'X-API-Key: ' . ($this->apiKey ?? ""),
            'X-Timestamp: ' . $timestamp
        ];

        if ($this->apiSecret) {
            $headers[] = 'X-Signature: ' . $this->_generateSignature($timestamp);
        }

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        $result = json_decode($response, true);
        if ($httpCode >= 400 || !($result['success'] ?? true)) {
            throw new \Exception("API Request Failed ($httpCode): " . ($result['message'] ?? $response));
        }

        return $result['data'] ?? $result;
    }

    public function searchCourses(string $query, int $page = 1, int $limit = 12)
    {
        return $this->request('GET', 'search/courses', ['query' => $query, 'page' => $page, 'limit' => $limit]);
    }

    public function getMe()
    {
        return $this->request('GET', 'users/me');
    }

    public function translate(string $text, string $target)
    {
        return $this->request('POST', 'translation/translate', [], ['text' => $text, 'target' => $target]);
    }
}
