import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboard_screen.dart';
import 'shop_screen.dart';
import 'social_screen.dart';
import '../services/mission_service.dart';
import '../services/user_service.dart';

class QuestsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const QuestsScreen({super.key, this.userData});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  List<dynamic> _missions = [];
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
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
        setState(() {
          _isLoading = false;
        });
        print(e);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startMission(int missionId) async {
    final email = widget.userData?['email'] ?? '';
    if (email.isNotEmpty) {
      final success = await MissionService.startMission(email, missionId);
      if (success) {
        _loadMissions();
      }
    }
  }

  Future<void> _checkinMission(int missionId) async {
    final email = widget.userData?['email'] ?? '';
    if (email.isEmpty) return;

    final ImagePicker picker = ImagePicker();
    // Allow user to pick image from camera or gallery
    final XFile? image = await picker.pickImage(source: ImageSource.camera); // or ImageSource.gallery

    if (image != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mengunggah bukti misi...')),
        );
      }

      final success = await MissionService.checkinMission(email, missionId, image.path);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Misi Selesai! Poin berhasil ditambahkan.')),
        );
        _loadMissions();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal check-in misi. Coba lagi.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in dibatalkan, foto tidak dipilih.')),
        );
      }
    }
  }

  Future<void> _failMission(int missionId) async {
    final email = widget.userData?['email'] ?? '';
    if (email.isNotEmpty) {
      final success = await MissionService.failMission(email, missionId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Misi digagalkan. Poin disesuaikan ke checkpoint terdekat.')),
        );
        _loadMissions();
      }
    }
  }

  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAvatar = _userProfile?['avatar'] ?? widget.userData?['avatar'] ?? 'avatar_0';
    final points = _userProfile?['points'] ?? 0;
    final level = _userProfile?['level'] ?? 1;
    final nextLevelPoints = _userProfile?['next_level_points'] ?? 250;
    
    double rawProgress = nextLevelPoints > 0 ? points / nextLevelPoints : 0.0;
    final double progress = rawProgress > 1.0 ? 1.0 : rawProgress;
    final progressWidth = 200.0 * progress; // 200 is total bar width

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
      ),
      body: RefreshIndicator(
        onRefresh: _loadMissions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Misi Aktif Card
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MISI AKTIF',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006666), letterSpacing: 1),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'LEVEL ',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            Text(
                              '$level',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF008080)),
                            ),
                          ],
                        ),
                        Text(
                          '$points / ${nextLevelPoints}XP',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    Container(
                      height: 12,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: progressWidth, // Dynamic progress
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

              const SizedBox(height: 25),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(0, 'Semua'),
                    const SizedBox(width: 10),
                    _buildFilterChip(1, 'Mental'),
                    const SizedBox(width: 10),
                    _buildFilterChip(2, 'Social'),
                    const SizedBox(width: 10),
                    _buildFilterChip(3, 'Physical'),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Featured Event Card
              Container(
                height: 260, // Increased height to prevent overflow
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/backgrounds/background-login-regis.png'),
                    fit: BoxFit.cover,
                  ),
                  color: const Color(0xFF006666), // Fallback color
                ),
                child: Stack(
                  children: [
                    // Dark overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF008080),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'FEATURED EVENT',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'MEDIUM',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            'Night\nRunner\nMarathon',
                            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.white, size: 16),
                              const SizedBox(width: 5),
                              const Text(
                                'Mulai masuk : 04:22:15',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006666),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                ),
                                child: const Text('JOIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_missions.isEmpty)
                const Center(child: Text('Belum ada misi tersedia.', style: TextStyle(color: Colors.grey)))
              else
                ..._missions.where((mission) {
                  if (_selectedFilterIndex == 0) return true;
                  if (_selectedFilterIndex == 1) return mission['category'] == 'Mental';
                  if (_selectedFilterIndex == 2) return mission['category'] == 'Social';
                  if (_selectedFilterIndex == 3) return mission['category'] == 'Physical';
                  return true;
                }).map((mission) => Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border(left: BorderSide(color: _getCategoryColor(mission['category']), width: 6)),
                      boxShadow: [
                        BoxShadow(color: Colors.blueGrey.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getCategoryBgColor(mission['category']),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_getCategoryIcon(mission['category']), color: _getCategoryColor(mission['category']), size: 24),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getCategoryBgColor(mission['category']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '+${mission['points']} PTS',
                                style: TextStyle(color: _getCategoryColor(mission['category']), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          mission['title'],
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${mission['category'].toString().toUpperCase()}  •  ${mission['difficulty'].toString().toUpperCase()}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        if (mission['user_status'] == 'underway') ...[
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _failMission(mission['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[50],
                                    foregroundColor: Colors.red,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Text('Nyerah (Gagal)'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _checkinMission(mission['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF006666),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Text('Check-in'),
                                ),
                              ),
                            ],
                          ),
                        ] else if (mission['user_status'] == 'completed') ...[
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: const Center(
                              child: Text('Selesai', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _startMission(mission['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006666),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Mulai Misi'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )).toList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
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
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.sports_kabaddi, color: Color(0xFF006666)),
                      Text('Quests', style: TextStyle(color: Color(0xFF006666), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
            currentIndex: 1, // Quests highlighted
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
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006666) : const Color(0xFFE6EAEB),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mental': return const Color(0xFF008080);
      case 'Physical': return const Color(0xFFCC0000);
      case 'Social': return const Color(0xFFE68A00);
      default: return Colors.grey;
    }
  }

  Color _getCategoryBgColor(String category) {
    switch (category) {
      case 'Mental': return const Color(0xFFE6F2F2);
      case 'Physical': return const Color(0xFFFBE6E6);
      case 'Social': return const Color(0xFFFDF3E6);
      default: return Colors.grey[100]!;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mental': return Icons.psychology;
      case 'Physical': return Icons.fitness_center;
      case 'Social': return Icons.people;
      default: return Icons.star;
    }
  }
}
