import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboard_screen.dart';
import 'quests_screen.dart';
import 'shop_screen.dart';
import 'social_screen.dart';
import '../services/mission_service.dart';

class MissionDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? missionData;

  const MissionDetailScreen({super.key, this.userData, this.missionData});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  bool _isUnderway = false;
  bool _isLoading = false;

  Future<void> _startMission() async {
    final email = widget.userData?['email'];
    final missionId = widget.missionData?['id'];
    
    if (email != null && missionId != null) {
      setState(() => _isLoading = true);
      final success = await MissionService.startMission(email, missionId);
      setState(() {
        _isLoading = false;
        if (success) {
          _isUnderway = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memulai misi atau misi sudah berjalan.')));
        }
      });
    }
  }

  Future<void> _checkinMission() async {
    final email = widget.userData?['email'];
    final missionId = widget.missionData?['id'];

    if (email != null && missionId != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera); // Or ImageSource.gallery

      if (image != null) {
        setState(() => _isLoading = true);
        final success = await MissionService.checkinMission(email, missionId, image.path);
        setState(() {
          _isLoading = false;
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil Check-in! Poin ditambahkan.')));
            Navigator.pop(context); // Go back to refresh list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal Check-in.')));
          }
        });
      }
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
        automaticallyImplyLeading: false, // We'll customize it if needed, or just rely on bottom nav
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context), // Allows returning to dashboard
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
              // Main Mission Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Color(0xFFCC0000), width: 6)),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFBEAEA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.volunteer_activism, color: Color(0xFFCC0000), size: 28),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBEAEA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '+50 PTS',
                                style: TextStyle(color: Color(0xFFCC0000), fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.missionData?['title'] ?? 'Latihan Otot Inti',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF006666), height: 1.1),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.missionData?['subtitle'] ?? 'Tingkatkan kekuatan dengan sesi\n15 menit fokus pada otot inti.',
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 25),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (!_isUnderway)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _startMission,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006666),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('MULAI MISI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _checkinMission,
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              label: const Text('UNGGAH BUKTI (CHECK-IN)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00CCCC),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              // Sub-missions removed because they are not applicable to the current mission structure
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation Bar from Screenshot
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
            currentIndex: 0, // In screenshot, Home is highlighted
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
}
