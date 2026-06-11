import 'package:flutter/material.dart';
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

                  // Podium Top 3
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Rank 2
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: _buildPodiumItem(
                            rank: 2,
                            name: 'Luna_V',
                            pts: '7,120',
                            avatar: 'avatar_1',
                            borderColor: const Color(0xFFC0C0C0), // Silver
                            size: 80,
                            ptsColor: const Color(0xFF008080),
                          ),
                        ),
                        // Rank 3
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _buildPodiumItem(
                            rank: 3,
                            name: 'Kora_Run',
                            pts: '6,890',
                            avatar: 'avatar_2',
                            borderColor: const Color(0xFFCD7F32), // Bronze
                            size: 80,
                            ptsColor: const Color(0xFF008080),
                          ),
                        ),
                        // Rank 1
                        Positioned(
                          top: 0,
                          child: _buildPodiumItem(
                            rank: 1,
                            name: 'Zenith...',
                            pts: '8,940 PTS',
                            avatar: 'avatar_3',
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

                  // List ranks
                  _buildListRankItem(
                    rank: '04.',
                    name: 'Mars_O...',
                    level: 'L42',
                    streak: '12D STREAK',
                    pts: '6540 PTS',
                    avatar: 'avatar_4',
                  ),
                  const SizedBox(height: 15),
                  
                  _buildListRankItem(
                    rank: '05.',
                    name: 'Aura_Flow',
                    level: 'L38',
                    pts: '5910 PTS',
                    avatar: 'avatar_5',
                  ),
                  const SizedBox(height: 15),

                  _buildListRankItem(
                    rank: '06.',
                    name: 'Nova_Pu...',
                    level: 'L35',
                    streak: '3D STREAK',
                    pts: '4200 PTS',
                    avatar: 'avatar_6',
                  ),
                  const SizedBox(height: 10),
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
    required String pts,
    required String avatar,
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
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isRank1 ? 20 : 16, color: isRank1 ? const Color(0xFF006666) : Colors.black87),
        ),
        Text(
          pts,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isRank1 ? 14 : 12, color: ptsColor),
        ),
      ],
    );
  }

  Widget _buildListRankItem({
    required String rank,
    required String name,
    required String level,
    String? streak,
    required String pts,
    required String avatar,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Icon(Icons.bolt, color: Color(0xFF008080)),
          ),
        ],
      ),
    );
  }
}
