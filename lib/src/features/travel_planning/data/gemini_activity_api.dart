import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiActivityApi {
  final http.Client _client;
  final String _backendBaseUrl;

  GeminiActivityApi(this._client)
    : _backendBaseUrl = const String.fromEnvironment(
        'AI_BACKEND_URL',
        defaultValue: '',
      ).trim();

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
      return 'Sugestão automática indisponível: configure AI_BACKEND_URL no build e gere novo deploy.';
    }

    try {
      final startTime = DateTime.now();
      _debugLog('Iniciando requisição...');

      final normalizedBase = _backendBaseUrl.replaceFirst(RegExp(r'/+$'), '');
      final uri = Uri.parse('$normalizedBase/travel/suggestions');

      _debugLog('Enviando POST para: $uri');
      final sendTime = DateTime.now();

      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      final responseTime = DateTime.now();
      final networkDuration = responseTime.difference(sendTime).inMilliseconds;
      _debugLog(
        'Resposta recebida em ${networkDuration}ms (Status: ${res.statusCode})',
      );

      if (res.statusCode != 200) {
        if (res.statusCode == 401 || res.statusCode == 403) {
          return 'Serviço de IA indisponível por configuração de segurança.';
        }
        return 'Falha ao consultar IA (${res.statusCode}). Tente novamente em instantes.';
      }

      final parseStart = DateTime.now();
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final text = (body['text'] as String?)?.trim() ?? '';
      final parseEnd = DateTime.now();

      _debugLog(
        'Parse JSON em ${parseEnd.difference(parseStart).inMilliseconds}ms',
      );
      final totalDuration = parseEnd.difference(startTime).inMilliseconds;
      _debugLog('Tempo total: ${totalDuration}ms');

      if (text.isEmpty) {
        return 'Não foi possível obter resposta da IA agora.';
      }

      return text;
    } catch (e) {
      _debugLog('Erro: $e');
      return 'Não foi possível obter resposta da IA agora.';
    }
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[GEMINI] $message');
    }
  }

  void dispose() {
    _client.close();
  }
}
