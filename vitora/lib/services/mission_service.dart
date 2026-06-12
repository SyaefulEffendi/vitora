import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_config.dart';

class MissionService {
  static Future<List<dynamic>> getMissions(String email) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.missionsUrl}?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['missions'] ?? [];
      } else {
        throw Exception('Gagal mengambil data misi');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  static Future<bool> startMission(String email, int missionId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.startMissionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mission_id': missionId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkinMission(String email, int missionId, String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.checkinMissionUrl));
      request.fields['email'] = email;
      request.fields['mission_id'] = missionId.toString();
      request.files.add(await http.MultipartFile.fromPath('proof_image', imagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> failMission(String email, int missionId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.failMissionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mission_id': missionId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
