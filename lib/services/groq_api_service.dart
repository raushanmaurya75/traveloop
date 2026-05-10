import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'error_handler.dart';

class GroqApiService {
  static const _model = 'llama-3.1-8b-instant';
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ??
      (throw const AppException(
          AppErrorType.apiError, 'GROQ_API_KEY not set in .env'));

  Future<Map<String, dynamic>> generateItinerary({
    required String destination,
    required int days,
  }) async {
    final prompt =
        'Act as a professional travel planner. Create a detailed itinerary for a trip to '
        '$destination for $days days. Provide a JSON response with city stops, 3 daily '
        'activities with estimated costs, and a brief description for each. '
        'Return ONLY valid JSON in this exact structure, no markdown, no extra text:\n'
        '{"stops":[{"city":"string","date":"YYYY-MM-DD","activities":[{"title":"string",'
        '"category":"string","time":"string","price":"string","description":"string"}]}]}';

    try {
      final response = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': prompt}
              ],
              'temperature': 0.7,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw AppException(
          AppErrorType.apiError,
          _friendlyHttpError(response.statusCode),
          technical: 'Groq API error ${response.statusCode}: ${response.body}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = body['choices'][0]['message']['content'] as String;
      return jsonDecode(content) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } on SocketException {
      throw const AppException(
        AppErrorType.noInternet,
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw const AppException(
        AppErrorType.timeout,
        'The request timed out. Please try again.',
      );
    } catch (e) {
      throw classifyError(e);
    }
  }

  static String _friendlyHttpError(int code) {
    switch (code) {
      case 401:
      case 403: return 'API authentication failed. Please check your Groq API key.';
      case 429: return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 503: return 'The AI service is temporarily unavailable. Please try again.';
      default:  return 'The AI service returned an error ($code). Please try again.';
    }
  }
}
