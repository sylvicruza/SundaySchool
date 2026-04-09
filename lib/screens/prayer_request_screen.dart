import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../services/data_service.dart';

class PrayerRequestScreen extends StatefulWidget {
  const PrayerRequestScreen({super.key});

  @override
  State<PrayerRequestScreen> createState() => _PrayerRequestScreenState();
}

class _PrayerRequestScreenState extends State<PrayerRequestScreen> {
  final _reqController = TextEditingController();
  String _selectedCategory = 'Personal';
  String _urgency = 'Low';
  bool _isAnonymous = false;
  
  List<PrayerRequest> _prayers = [];

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  void _loadPrayers() {
    setState(() {
      _prayers = DataService().getPrayerRequests();
    });
  }

  void _submit() async {
    if (_reqController.text.trim().isEmpty) return;
    
    final pr = PrayerRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      request: _reqController.text.trim(),
      urgency: _urgency,
      isAnonymous: _isAnonymous,
      date: DateTime.now(),
    );
    
    await DataService().savePrayerRequest(pr);
    _reqController.clear();
    _loadPrayers();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prayer request submitted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E0048)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Prayer Request', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Top Purple Card
                Container(
                  width: double.infinity,
                  height: 250,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Submit a Prayer\nRequest', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, height: 1.2)),
                      const SizedBox(height: 12),
                      Text('We are here to stand with you in\nfaith. Whatever is on your heart, our\ncommunity and pastoral team will\nlift it up in prayer.', style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.4, fontSize: 14)),
                    ],
                  ),
                ),
                
                // Form Card
                Padding(
                  padding: const EdgeInsets.only(top: 200, left: 24, right: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: [
                            _buildTag('Personal', primaryColor),
                            _buildTag('Family', primaryColor),
                            _buildTag('Health', primaryColor),
                            _buildTag('Financial', primaryColor),
                            _buildTag('Thanksgiving', primaryColor),
                            _buildTag('Others', primaryColor),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        const Text('YOUR REQUEST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _reqController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Share your heart with us...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black38),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const Text('URGENCY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _urgency,
                              isExpanded: true,
                              items: ['Low', 'Medium', 'High'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _urgency = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Keep Anonymous', style: TextStyle(fontWeight: FontWeight.w500)),
                              Switch(
                                value: _isAnonymous,
                                onChanged: (v){ setState(() => _isAnonymous = v); },
                                activeColor: primaryColor
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Send Request', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.send, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Recent Requests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: primaryColor),
                      const SizedBox(width: 8),
                      Text('Recent Requests', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Live Requests
                  if (_prayers.isNotEmpty)
                    ..._prayers.map((pr) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: pr.urgency == 'High' ? Colors.red.shade200 : const Color(0xFFC7A962)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${pr.date.day}/${pr.date.month} • ${pr.category.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black54)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFFFD54F), borderRadius: BorderRadius.circular(10)),
                                    child: Text(pr.isAnonymous ? 'ANONYMOUS' : 'BEING PRAYED FOR', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('"${pr.request}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ),
                      );
                    })
                  else
                    const Center(child: Text('No recent prayer requests.')),
                    
                  const SizedBox(height: 48),
                  
                  // Bottom Image Card
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/id/160/600/400'), // Candle placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                      ),
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        '"For where two or three are\ngathered in my name, there am\nI among them." — Matthew\n18:20',
                        style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color primaryColor) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
