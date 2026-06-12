import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_service.dart';
import '../api/api_config.dart';
import 'dashboard_screen.dart';
import 'quests_screen.dart';
import 'shop_screen.dart';

class SocialScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const SocialScreen({super.key, this.userData});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  List<dynamic> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/leaderboard'));
      if (response.statusCode == 200) {
        setState(() {
          _leaderboard = jsonDecode(response.body)['leaderboard'];
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  void _sendCheer(String targetEmail, String targetName) async {
    final success = await UserService.sendCheer(targetEmail);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil memberikan cheer ke $targetName!')),
      );
      _loadLeaderboard(); // Reload to get updated cheers
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAvatar = widget.userData?['avatar'] ?? 'avatar_0';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9), // Very light cyan background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00FFFF),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatars/$userAvatar.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.black87),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'VITORA',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF006666)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Leave space for the sticky bottom card
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Peringkat\nMingguan',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF006666), height: 1.1),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.black54),
                              const SizedBox(width: 5),
                              const Text('Berakhir 02d 14h', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6666FF), // Purple/Blue
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'DIAMOND\nLEAGUE',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),

                  const SizedBox(height: 40),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_leaderboard.isEmpty)
                    const Center(child: Text("Belum ada data di Leaderboard"))
                  else ...[
                    // Podium Top 3
                    if (_leaderboard.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Rank 2
                            if (_leaderboard.length > 1)
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: _buildPodiumItem(
                                  rank: 2,
                                  name: _leaderboard[1]['nama'].split(' ')[0],
                                  email: _leaderboard[1]['email'] ?? '',
                                  pts: '${_leaderboard[1]['points']} PTS',
                                  avatar: _leaderboard[1]['avatar'],
                                  cheers: _leaderboard[1]['cheers'] ?? 0,
                                  streak: _leaderboard[1]['streak'] ?? 1,
                                  borderColor: const Color(0xFFC0C0C0), // Silver
                                  size: 80,
                                  ptsColor: const Color(0xFF008080),
                                ),
                              ),
                            // Rank 3
                            if (_leaderboard.length > 2)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: _buildPodiumItem(
                                  rank: 3,
                                  name: _leaderboard[2]['nama'].split(' ')[0],
                                  email: _leaderboard[2]['email'] ?? '',
                                  pts: '${_leaderboard[2]['points']} PTS',
                                  avatar: _leaderboard[2]['avatar'],
                                  cheers: _leaderboard[2]['cheers'] ?? 0,
                                  streak: _leaderboard[2]['streak'] ?? 1,
                                  borderColor: const Color(0xFFCD7F32), // Bronze
                                  size: 80,
                                  ptsColor: const Color(0xFF008080),
                                ),
                              ),
                            // Rank 1
                            if (_leaderboard.length > 0)
                              Positioned(
                                top: 0,
                                child: _buildPodiumItem(
                                  rank: 1,
                                  name: _leaderboard[0]['nama'].split(' ')[0],
                                  email: _leaderboard[0]['email'] ?? '',
                                  pts: '${_leaderboard[0]['points']} PTS',
                                  avatar: _leaderboard[0]['avatar'],
                                  cheers: _leaderboard[0]['cheers'] ?? 0,
                                  streak: _leaderboard[0]['streak'] ?? 1,
                                  borderColor: const Color(0xFFFFD700), // Gold
                                  size: 110,
                                  isRank1: true,
                                  ptsColor: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),

                    // List ranks 4 and below
                    ...List.generate(_leaderboard.length > 3 ? _leaderboard.length - 3 : 0, (index) {
                      final item = _leaderboard[index + 3];
                      return Column(
                        children: [
                          _buildListRankItem(
                            rank: '${(index + 4).toString().padLeft(2, '0')}.',
                            name: item['nama'].split(' ')[0],
                            email: item['email'] ?? '',
                            level: 'L${item['level']}',
                            pts: '${item['points']} PTS',
                            avatar: item['avatar'],
                            cheers: item['cheers'] ?? 0,
                            streak: '${item['streak']} Hari',
                          ),
                          const SizedBox(height: 15),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          // Sticky Bottom Card for "Peringkat Berikutnya"
          Positioned(
            left: 20,
            right: 20,
            bottom: 20, // Sit right above bottom nav
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEFEF), // Light cyan grey
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF006666), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                          children: [
                            TextSpan(text: 'Peringkat Berikutnya : '),
                            TextSpan(text: 'Master', style: TextStyle(color: Color(0xFF008080))),
                          ],
                        ),
                      ),
                      const Text('1,150 PTS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 220, // Approximated
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF008080), Color(0xFF00FFFF)]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Icon(Icons.home_outlined, color: Colors.grey),
                    Text('Home', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Icon(Icons.sports_kabaddi_outlined, color: Colors.grey),
                    Text('Quests', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                    Text('Shop', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.people, color: Color(0xFF006666)),
                      Text('Social', style: TextStyle(color: Color(0xFF006666), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                label: '',
              ),
            ],
            currentIndex: 3, // Social highlighted
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen(userData: widget.userData)),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => QuestsScreen(userData: widget.userData)),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ShopScreen(userData: widget.userData)),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required String email,
    required String pts,
    required String avatar,
    required int cheers,
    required int streak,
    required Color borderColor,
    required double size,
    required Color ptsColor,
    bool isRank1 = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRank1) 
          const Icon(Icons.stars, color: Color(0xFFFFD700), size: 30),
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(isRank1 ? 4 : 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatars/$avatar.png',
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: size, height: size, color: Colors.white,
                    child: Icon(Icons.person, size: size * 0.6, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isRank1 ? 20 : 16, color: isRank1 ? const Color(0xFF006666) : Colors.black87),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.local_fire_department, color: Color(0xFFC2185B), size: 14),
            Text('$streak', style: const TextStyle(color: Color(0xFFC2185B), fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
        Text(
          pts,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isRank1 ? 14 : 12, color: ptsColor),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _sendCheer(email, name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.pink, size: 12),
                const SizedBox(width: 4),
                Text('$cheers', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.pink)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListRankItem({
    required String rank,
    required String name,
    required String email,
    required String level,
    String? streak,
    required String pts,
    required String avatar,
    required int cheers,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Text(rank, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 15),
          ClipOval(
            child: Image.asset(
              'assets/images/avatars/$avatar.png',
              width: 45,
              height: 45,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 45, height: 45, color: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(level, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (streak != null) ...[
                      const Icon(Icons.local_fire_department, color: Color(0xFFC2185B), size: 14),
                      const SizedBox(width: 2),
                      Text(streak, style: const TextStyle(color: Color(0xFFC2185B), fontWeight: FontWeight.bold, fontSize: 10)),
                      const SizedBox(width: 10),
                    ],
                    Text(pts, style: const TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => _sendCheer(email, name),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pink[50],
                    border: Border.all(color: Colors.pink[200]!),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.pink, size: 18),
                ),
              ),
              const SizedBox(height: 4),
              Text('$cheers cheers', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
