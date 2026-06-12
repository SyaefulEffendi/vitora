import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_config.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfileScreen({super.key, this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _currentAvatar = 'avatar_0';
  List<String> _inventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentAvatar = widget.userData?['avatar'] ?? 'avatar_0';
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final email = widget.userData?['email'] ?? '';
    if (email.isEmpty) return;

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/user/profile?email=$email'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final inventoryStr = data['inventory'] ?? '';
        
        setState(() {
          _inventory = inventoryStr.split(',').where((e) => e.isNotEmpty).toList().cast<String>();
          _currentAvatar = data['avatar'] ?? 'avatar_0';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeAvatar(String newAvatarId) async {
    final email = widget.userData?['email'] ?? '';
    if (email.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/avatar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'avatar_id': newAvatarId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentAvatar = newAvatarId;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar berhasil diganti!')),
          );
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006666)),
          onPressed: () => Navigator.pop(context, _currentAvatar),
        ),
        title: const Text('Profil Saya', style: TextStyle(color: Color(0xFF006666), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar Display
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00FFFF).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFF00FFFF), width: 4),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatars/$_currentAvatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80, color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.userData?['nama'] ?? 'User',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    widget.userData?['email'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  
                  const SizedBox(height: 40),

                  // Inventory / Avatar Change Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pilih Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006666))),
                        const SizedBox(height: 15),
                        _inventory.isEmpty 
                            ? const Text('Belum ada item avatar. Beli di Shop!', style: TextStyle(color: Colors.grey))
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildAvatarOption('avatar_0', 'Default'),
                                  ..._inventory.map((item) => _buildAvatarOption(item, 'Owned Item')),
                                ],
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarOption(String avatarId, String label) {
    bool isSelected = _currentAvatar == avatarId;
    return GestureDetector(
      onTap: () => _changeAvatar(avatarId),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00FFFF).withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF006666) : Colors.transparent,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/avatars/$avatarId.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
