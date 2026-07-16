import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';


abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String fullName, String? phone, String? idCard);
  Future<void> logout();
  Future<void> loginWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Đăng nhập thất bại');

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(profile);
  }

  @override
  Future<UserModel> register(String email, String password, String fullName, String? phone, String? idCard) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Đăng ký thất bại');

    // Lưu thêm thông tin vào bảng profiles
    final profileData = {
      'id': response.user!.id,
      'email': email,
      'full_name': fullName,
      'role': 'customer',
      'phone': phone,
      'id_card': idCard,
    };
    
    await supabase.from('profiles').insert(profileData);
    
    return UserModel.fromJson(profileData);
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> loginWithGoogle() async {
    await supabase.auth.signInWithOAuth(OAuthProvider.google);
  }
}
