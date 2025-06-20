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
    _calculateCurrentWeek();
    _refreshRecords();
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
    await _updateTotalMilkPerWeek();
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil dihapus!')),
      );
    }
    _refreshRecords();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMEEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan Susu Sapi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Ringkasan Mingguan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Periode: ${DateFormat('dd MMM yyyy').format(_currentWeekStart)} - ${DateFormat('dd MMM yyyy').format(_currentWeekEnd)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Divider(height: 20, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Susu Minggu Ini:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${_totalMilkPerWeek.toStringAsFixed(2)} Liter',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Daftar Catatan Susu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  child: const Icon(Icons.person,
                                      color: Colors.green),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.farmerName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tanggal: ${_formatDate(record.setorDate)}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      Text(
                                        'Jumlah Susu: ${record.milkQuantity.toStringAsFixed(2)} Liter',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditRecordPage(
                                                    record: record),
                                          ),
                                        );
                                        _refreshRecords();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Hapus Catatan'),
                                            content: const Text(
                                                'Apakah Anda yakin ingin menghapus catatan ini?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _deleteRecord(record.id);
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
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
                              ],
                            ),
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
