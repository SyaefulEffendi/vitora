import 'package:flutter/material.dart';
import 'mission_detail_screen.dart';
import 'quests_screen.dart';
import 'shop_screen.dart';
import 'social_screen.dart';
import 'profile_screen.dart';
import '../services/mission_service.dart';
import '../services/user_service.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const DashboardScreen({super.key, this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<dynamic> _missions = [];
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final email = widget.userData?['email'] ?? '';
    if (email.isNotEmpty) {
      try {
        final profile = await UserService.getProfile(email);
        final missions = await MissionService.getMissions(email);
        setState(() {
          _userProfile = profile ?? widget.userData;
          _missions = missions;
          _isLoading = false;
        });
      } catch (e) {
        setState(() { _isLoading = false; });
      }
    } else {
      setState(() { _isLoading = false; });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuestsScreen(userData: widget.userData)),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShopScreen(userData: widget.userData)),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SocialScreen(userData: widget.userData)),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userProfile?['nama']?.toString().split(' ')[0] ?? widget.userData?['nama']?.toString().split(' ')[0] ?? 'Olivia';
    final userAvatar = _userProfile?['avatar'] ?? widget.userData?['avatar'] ?? 'avatar_0';
    final points = _userProfile?['points'] ?? 0;
    final level = _userProfile?['level'] ?? 1;
    final nextLevelPoints = _userProfile?['next_level_points'] ?? 250;
    final streak = _userProfile?['streak'] ?? 1;
    double rawProgress = nextLevelPoints > 0 ? points / nextLevelPoints : 0.0;
    final double progress = rawProgress > 1.0 ? 1.0 : rawProgress;
    final progressWidth = 240.0; // Approximation of total bar width

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Alice Blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final updatedAvatar = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(userData: _userProfile ?? widget.userData)),
                );
                if (updatedAvatar != null && mounted) {
                  setState(() {
                    if (_userProfile != null) {
                      _userProfile!['avatar'] = updatedAvatar;
                    }
                  });
                  _loadData();
                }
              },
              child: Container(
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
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text('$streak', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 15),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF006666)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF008080), // Teal outline
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/avatars/$userAvatar.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, size: 40, color: Colors.black87),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF008080),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'LVL $level',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004C4C),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'STATUS:',
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'GOOD HEALTH',
                            style: TextStyle(
                              color: Color(0xFF00CC66),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Progres\nKeseluruhan',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text('$points', style: const TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(' / $nextLevelPoints PTS', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0FFFF),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: const Color(0xFF00FFFF), width: 1),
                            ),
                            child: const Text(
                              'Peningkatan\nAktif',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Custom Progress Bar
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: progressWidth * progress,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF008080), Color(0xFF00FFFF)]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text('$points CP', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            if (progress < 1.0)
                              Expanded(
                                child: Center(
                                  child: Text('$nextLevelPoints CP', style: TextStyle(color: Colors.grey[600], fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),

              const Text(
                'Misi Aktif',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 15),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_missions.isEmpty)
                const Center(child: Text('Belum ada misi tersedia.', style: TextStyle(color: Colors.grey)))
              else
                ..._missions.take(2).map((mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _buildQuestCard(
                    icon: _getCategoryIcon(mission['category']),
                    iconColor: _getCategoryColor(mission['category']),
                    iconBgColor: _getCategoryBgColor(mission['category']),
                    title: mission['title'],
                    subtitle: mission['subtitle'] ?? '',
                    points: '+${mission['points']} PTS',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MissionDetailScreen(userData: widget.userData, missionData: mission),
                        ),
                      );
                    },
                  ),
                )).toList(),
              
              const SizedBox(height: 25),

              // Start New Quest Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  label: const Text(
                    'START NEW QUEST',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CCCC), // Teal/Cyan button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      ),
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
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.home_outlined, color: Color(0xFF006666)),
                      Text('Home', style: TextStyle(color: Color(0xFF006666), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
              const BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Icon(Icons.people_outline, color: Colors.grey),
                    Text('Social', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex, // Home highlighted
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String points,
    double? progress,
    String? progressText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0FFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(points, style: const TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                Text(progressText ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
              ],
            )
          ]
        ],
      ),
    ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mental': return const Color(0xFF008080);
      case 'Fisik': return const Color(0xFFCC0000);
      case 'Sosial': return const Color(0xFF3333FF);
      default: return Colors.grey;
    }
  }

  Color _getCategoryBgColor(String category) {
    switch (category) {
      case 'Mental': return const Color(0xFFE0FFFF);
      case 'Fisik': return const Color(0xFFFBEAEA);
      case 'Sosial': return const Color(0xFFEAEAFF);
      default: return Colors.grey[200]!;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mental': return Icons.psychology;
      case 'Fisik': return Icons.fitness_center;
      case 'Sosial': return Icons.people;
      default: return Icons.star;
    }
  }
}
