import 'dart:convert';

import 'package:http/http.dart' as http;



class GeminiActivityApi {
  final http.Client _client;
  final String _backendBaseUrl;



  GeminiActivityApi(this._client)
    : _backendBaseUrl = const String.fromEnvironment('AI_BACKEND_URL');

  bool get isConfigured => _backendBaseUrl.trim().isNotEmpty;

  String buildPrompt({
    required String cityLabel,
    required String weatherLabel,
    required String daytimeLabel,
  }) {
    return 'Você é um guia de viagem. Cidade: $cityLabel. Clima atual: $weatherLabel. Momento do dia: $daytimeLabel. Sugira 5 atividades objetivas para hoje, incluindo uma opção indoor e uma outdoor, com linguagem curta em português do Brasil.';
  }

  Future<String> suggest({required String prompt}) async {
    if (!isConfigured) {
      return 'Sugestão automática indisponível no momento (backend de IA não configurado).';
    }

    try {
      final uri = Uri.parse('$_backendBaseUrl/travel/suggestions');
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (res.statusCode != 200) {
        if (res.statusCode == 401 || res.statusCode == 403) {
          return 'Serviço de IA indisponível por configuração de segurança.';
        }
        return 'Falha ao consultar IA (${res.statusCode}). Tente novamente em instantes.';
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final text = (body['text'] as String?)?.trim() ?? '';
      if (text.isEmpty) {
        return 'Não foi possível obter resposta da IA agora.';
      }

      return text;
    } catch (_) {
      return 'Não foi possível obter resposta da IA agora.';
    }
  }

  void dispose() {
    _client.close();
  }
}
