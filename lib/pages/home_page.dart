import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/milk_record.dart';
import '../services/supabase_service.dart';
import 'add_edit_record_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<MilkRecord>> _milkRecordsFuture;
  double _totalMilkPerWeek = 0.0;
  DateTime _currentWeekStart = DateTime.now();
  DateTime _currentWeekEnd = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshRecords();
    _calculateCurrentWeek();
  }

  void _calculateCurrentWeek() {
    DateTime now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    _currentWeekEnd = _currentWeekStart.add(const Duration(days: 6));
  }

  Future<void> _refreshRecords() async {
    setState(() {
      _milkRecordsFuture = _supabaseService.getMilkRecords();
    });
    _updateTotalMilkPerWeek();
  }

  Future<void> _updateTotalMilkPerWeek() async {
    final total = await _supabaseService.getTotalMilkPerWeek(
      _currentWeekStart,
      _currentWeekEnd,
    );
    setState(() {
      _totalMilkPerWeek = total;
    });
  }

  Future<void> _deleteRecord(String id) async {
    await _supabaseService.deleteMilkRecord(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil dihapus!')));
    _refreshRecords();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Setoran Susu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Mingguan (${_formatDate(_currentWeekStart)} - ${_formatDate(_currentWeekEnd)})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Susu Minggu Ini: ${_totalMilkPerWeek.toStringAsFixed(2)} Liter',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MilkRecord>>(
              future: _milkRecordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan setoran susu.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final record = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            '${record.farmerName} - ${_formatDate(record.setorDate)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          subtitle: Text(
                            'Jumlah Susu: ${record.milkQuantity.toStringAsFixed(2)} Liter',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF60A5FA),
                                ), // blue-400
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AddEditRecordPage(record: record),
                                    ),
                                  );
                                  _refreshRecords();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color(0xFFEF4444),
                                ), // red-500
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Hapus Catatan'),
                                          content: const Text(
                                            'Apakah Anda yakin ingin menghapus catatan ini?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _deleteRecord(record.id);
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFEF4444,
                                                ),
                                              ),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditRecordPage()),
          );
          _refreshRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
