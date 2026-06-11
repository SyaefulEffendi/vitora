import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_config.dart';
import 'login_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String email;

  const CategorySelectionScreen({super.key, required this.email});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<String> _selectedCategories = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'Mental',
      'title': 'Kesehatan Mental',
      'icon': Icons.psychology,
      'color': const Color(0xFF008080),
      'bgColor': const Color(0xFFE0FFFF),
    },
    {
      'id': 'Fisik',
      'title': 'Kesehatan Fisik',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFCC0000),
      'bgColor': const Color(0xFFFBEAEA),
    },
    {
      'id': 'Sosial',
      'title': 'Kesehatan Sosial',
      'icon': Icons.people,
      'color': const Color(0xFF3333FF),
      'bgColor': const Color(0xFFEAEAFF),
    },
  ];

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  Future<void> _saveCategories() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 kategori fokus')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoriesString = _selectedCategories.join(',');
      
      final response = await http.post(
        Uri.parse(ApiConfig.categoriesUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'categories': categoriesString,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil disimpan! Silakan Login.'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Gagal menyimpan kategori'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan koneksi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Fokus Kesehatanmu',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00FFFF),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pilih kategori yang ingin kamu tingkatkan agar kami bisa merekomendasikan misi yang tepat.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategories.contains(category['id']);
                    
                    return GestureDetector(
                      onTap: () => _toggleCategory(category['id']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? category['bgColor'] : const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? category['color'] : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isSelected ? category['color'] : Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                category['icon'],
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              category['title'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? category['color'] : Colors.white,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle, color: category['color'], size: 30),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategories,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black87)
                      : const Text(
                          'LANJUTKAN',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
