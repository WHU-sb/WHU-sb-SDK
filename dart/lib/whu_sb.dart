import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class WHUSBConfig {
  final String? apiKey;
  final String? apiSecret;
  final String baseUrl;

  WHUSBConfig({
    this.apiKey,
    this.apiSecret,
    required this.baseUrl,
  });
}

class WHUSBClient {
  late final WHUSBConfig config;

  WHUSBClient({
    String? apiKey,
    String? apiSecret,
    String baseUrl = 'https://whu.sb/api/v1',
  }) {
    config = WHUSBConfig(
      apiKey: apiKey,
      apiSecret: apiSecret,
      baseUrl: baseUrl.replaceFirst(RegExp(r'/$'), ''),
    );
  }

  String _generateSignature(int timestamp) {
    if (config.apiKey == null || config.apiSecret == null) return '';
    final payload = '${config.apiKey}$timestamp${config.apiSecret}';
    final bytes = utf8.encode(payload);
    return sha256.convert(bytes).toString();
  }

  Future<dynamic> _request(String method, String endpoint, {Map<String, String>? query, Map<String, dynamic>? body}) async {
    var url = Uri.parse('${config.baseUrl}/${endpoint.replaceFirst(RegExp(r'^/'), '')}');
    if (query != null) {
      url = url.replace(queryParameters: query);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final headers = {
      'Content-Type': 'application/json',
      'X-API-Key': config.apiKey ?? '',
      'X-Timestamp': timestamp.toString(),
    };

    if (config.apiSecret != null) {
      headers['X-Signature'] = _generateSignature(timestamp);
    }

    http.Response response;
    if (method == 'POST') {
      response = await http.post(url, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'PUT') {
      response = await http.put(url, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'DELETE') {
      response = await http.delete(url, headers: headers);
    } else {
      response = await http.get(url, headers: headers);
    }

    final result = jsonDecode(response.body);
    if (response.statusCode >= 400 || !(result['success'] ?? true)) {
      throw Exception('API Request Failed (${response.statusCode}): ${result['message']}');
    }

    return result['data'];
  }

  // --- Course APIs ---

  Future<dynamic> listCourses({int page = 1, int limit = 20}) async {
    return _request('GET', 'courses', query: {'page': page.toString(), 'limit': limit.toString()});
  }

  Future<dynamic> getCourse(String uid) async {
    return _request('GET', 'courses/$uid');
  }

  Future<dynamic> searchCourses(String query, {int page = 1, int limit = 12}) async {
    return _request('GET', 'search/courses', query: {'query': query, 'page': page.toString(), 'limit': limit.toString()});
  }

  // --- Search APIs ---

  Future<dynamic> getHotSearches() async {
    return _request('GET', 'search/hot');
  }

  // --- User APIs ---

  Future<dynamic> getMe() async {
    return _request('GET', 'users/me');
  }

  // --- Translation APIs ---

  Future<dynamic> translate(String text, String target) async {
    return _request('POST', 'translation/translate', body: {'text': text, 'target': target});
  }
}
