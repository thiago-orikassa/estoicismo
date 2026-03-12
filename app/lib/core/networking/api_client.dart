import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl();

  final String _baseUrl;
  String? _accessToken;

  static const _productionUrl = 'https://aethor-production.up.railway.app';

  static String _defaultBaseUrl() {
    // Use DEV_SERVER_URL dart-define to point at a local server during development.
    const devUrl = String.fromEnvironment('DEV_SERVER_URL');
    if (devUrl.isNotEmpty) return devUrl;
    // Android emulator uses 10.0.2.2 to reach host machine.
    if (Platform.isAndroid) return 'http://10.0.2.2:8787';
    return _productionUrl;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final root = Uri.parse(_baseUrl);
    return Uri(
      scheme: root.scheme,
      host: root.host,
      port: root.hasPort ? root.port : null,
      path: path,
      queryParameters: query,
    );
  }

  void setAccessToken(String? value) {
    _accessToken = value;
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? query}) async {
    final client = HttpClient();
    final request = await client.getUrl(_uri(path, query));
    _applyAuthHeader(request);
    final response = await request.close();
    final raw = await utf8.decoder.bind(response).join();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw HttpException('GET $path failed: ${response.statusCode} $data');
    }

    return data;
  }

  Future<Map<String, dynamic>> post(String path,
      {required Map<String, dynamic> body}) async {
    final client = HttpClient();
    final request = await client.postUrl(_uri(path));
    _applyAuthHeader(request);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    final raw = await utf8.decoder.bind(response).join();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw HttpException('POST $path failed: ${response.statusCode} $data');
    }

    return data;
  }

  Future<Map<String, dynamic>> delete(String path,
      {Map<String, String>? query}) async {
    final client = HttpClient();
    final request = await client.deleteUrl(_uri(path, query));
    _applyAuthHeader(request);
    final response = await request.close();
    final raw = await utf8.decoder.bind(response).join();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw HttpException('DELETE $path failed: ${response.statusCode} $data');
    }

    return data;
  }

  void _applyAuthHeader(HttpClientRequest request) {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
}
