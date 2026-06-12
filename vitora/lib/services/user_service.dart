import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_config.dart';

class UserService {
  static Future<Map<String, dynamic>?> getProfile(String email) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/profile?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leaderboard'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['leaderboard'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> redeemPoints(String email, int cost, String rewardName) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/shop/redeem'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'cost': cost,
          'reward_name': rewardName,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> buyItem(String email, int cost, String itemId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/shop/buy_item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'cost': cost,
          'item_id': itemId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  static Future<bool> sendCheer(String targetEmail) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/social/cheer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'target_email': targetEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
