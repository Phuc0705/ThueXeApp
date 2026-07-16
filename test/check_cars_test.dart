// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() {
  test('Check cars table columns', () async {
    final envContent = File('.env').readAsStringSync();
    
    String supabaseUrl = '';
    String supabaseKey = '';
    
    for (var line in envContent.split('\n')) {
      if (line.startsWith('SUPABASE_URL=')) supabaseUrl = line.split('=')[1].trim();
      if (line.startsWith('SUPABASE_ANON_KEY=')) supabaseKey = line.split('=')[1].trim();
    }

    final client = SupabaseClient(supabaseUrl, supabaseKey);

    try {
      final response = await client
          .from('cars')
          .select()
          .limit(1);
      
      print('Thành công! Cấu trúc bảng cars:');
      if (response.isNotEmpty) {
        print(response.first.keys.toList());
      } else {
        print('Bảng cars trống');
      }
    } catch (e) {
      print('Lỗi: \$e');
      fail('Lỗi: \$e');
    }
  });
}
