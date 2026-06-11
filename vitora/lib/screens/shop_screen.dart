import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'quests_screen.dart';
import 'social_screen.dart';

class ShopScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ShopScreen({super.key, this.userData});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedFilterIndex = 0;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Character Card
              Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0FFFF), Color(0xFFD4F1F4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color(0xFFB2EBF2), width: 2),
                ),
                child: Stack(
                  children: [
                    // Character image
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/shop/character.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person_pin,
                          size: 100,
                          color: Color(0xFF008080),
                        ),
                      ),
                    ),
                    
                    // Top badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF008080)),
                                ),
                                child: const Icon(Icons.attach_money, size: 12, color: Color(0xFF008080)),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '1,450 PTS',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    Positioned(
                      top: 50,
                      right: 0,
                      left: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2EBF2), // Light cyan
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.5)),
                            ),
                            child: const Text(
                              'STAMINA BUFF',
                              style: TextStyle(color: Color(0xFF006666), fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD0D0FF), // Light purple
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFAAAAFF).withOpacity(0.5)),
                            ),
                            child: const Text(
                              'AURA : POSITIVE',
                              style: TextStyle(color: Color(0xFF333399), fontWeight: FontWeight.bold, fontSize: 10),
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
                    const SizedBox(width: 15),
                    _buildFilterChip(1, 'Kepala'),
                    const SizedBox(width: 15),
                    _buildFilterChip(2, 'Badan'),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Shop Items Grid
              Row(
                children: [
                  Expanded(
                    child: _buildShopItemCard(
                      image: 'assets/images/shop/item_hoodie.png',
                      badgeText: 'EXPERT',
                      badgeColor: const Color(0xFF993366),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildShopItemCard(
                      image: 'assets/images/shop/item_hair.png',
                      badgeText: 'EASY',
                      badgeColor: const Color(0xFF008080),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
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
              const BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Icon(Icons.sports_kabaddi_outlined, color: Colors.grey),
                    Text('Quests', style: TextStyle(color: Colors.grey, fontSize: 10)),
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
                      Icon(Icons.shopping_bag, color: Color(0xFF006666)),
                      Text('Shop', style: TextStyle(color: Color(0xFF006666), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
            currentIndex: 2, // Shop highlighted
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
          color: isSelected ? const Color(0xFF00FFFF) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF006666) : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildShopItemCard({
    required String image,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          // Greyish inner background
          Positioned(
            top: 20, bottom: 20, left: 20, right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  image,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.checkroom, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          // Badge
          Positioned(
            top: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
