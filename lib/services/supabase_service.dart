import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/milk_record.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MilkRecord>> getMilkRecords() async {
    try {
      final response = await _supabase
          .from('milk_records')
          .select('*')
          .order('setor_date', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => MilkRecord.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching milk records: $e');
      throw Exception('Gagal mengambil catatan susu: $e');
    }
  }

  Future<void> addMilkRecord(MilkRecord record) async {
    try {
      await _supabase.from('milk_records').insert({
        'setor_date': record.setorDate.toIso8601String().split('T').first,
        'farmer_name': record.farmerName,
        'milk_quantity': record.milkQuantity,
      });
    } catch (e) {
      print('Error adding milk record: $e');
      throw Exception('Gagal menambahkan catatan susu: $e');
    }
  }

  Future<void> updateMilkRecord(MilkRecord record) async {
    try {
      await _supabase.from('milk_records').update({
        'setor_date': record.setorDate.toIso8601String().split('T').first,
        'farmer_name': record.farmerName,
        'milk_quantity': record.milkQuantity,
      }).eq('id', record.id);
    } catch (e) {
      print('Error updating milk record: $e');
      throw Exception('Gagal memperbarui catatan susu: $e');
    }
  }

  Future<void> deleteMilkRecord(String id) async {
    try {
      await _supabase.from('milk_records').delete().eq('id', id);
    } catch (e) {
      print('Error deleting milk record: $e');
      throw Exception('Gagal menghapus catatan susu: $e');
    }
  }

  Future<double> getTotalMilkPerWeek(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('milk_records')
          .select('milk_quantity')
          .gte('setor_date', startDate.toIso8601String().split('T').first)
          .lte('setor_date', endDate.toIso8601String().split('T').first);

      final List<dynamic> data = response;
      double total = 0.0;
      for (var item in data) {
        total += (item['milk_quantity'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting total milk per week: $e');
      throw Exception('Gagal menghitung total susu mingguan: $e');
    }
  }
}
