import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() {
  test('Check Supabase Columns', () async {
    final envContent = File('.env').readAsStringSync();
    
    String supabaseUrl = '';
    String supabaseKey = '';
    
    for (var line in envContent.split('\n')) {
      if (line.startsWith('SUPABASE_URL=')) supabaseUrl = line.split('=')[1].trim();
      if (line.startsWith('SUPABASE_ANON_KEY=')) supabaseKey = line.split('=')[1].trim();
    }

    final client = SupabaseClient(supabaseUrl, supabaseKey);

    print('Đang kiểm tra bảng bookings...');
    
    try {
      final response = await client
          .from('bookings')
          .select('id, add_baby_seat, add_gps, delivery_method, note')
          .limit(1);
      
      print('Thành công! Cấu trúc bảng hợp lệ.');
      print('Dữ liệu trả về (nếu có): \$response');
    } catch (e) {
      print('Lỗi: \$e');
      fail('Thiếu cột hoặc bảng không hợp lệ: \$e');
    }
  });
}
