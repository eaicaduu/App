import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient client;

  UserService(this.client);

  // listar
  Future<List<Map<String, dynamic>>> getUsers() async {
    final responseUser = await client.from('users').select();
    return List<Map<String, dynamic>>.from(responseUser as List);
  }

  // inserir
  Future<void> createUser(String name) async {
    await client.from('users').insert({'name': name});
  }

  // deletar
  Future<void> deleteUser(int userId) async {
    await client.from('users').delete().eq('id', userId);
  }

  // editar
  Future<void> updateUser(String userId, String name) async {
    await client.from('users').update({'name': name}).eq('id', userId);
  }

  // registrar ponto
  Future<void> recordAttendance(int userId, DateTime time, String type) async {
    await client.from('point').insert(
        {'user_id': userId, 'time': time.toIso8601String(), 'type': type});
  }

  // mostrar o ponto
  Future<List<Map<String, dynamic>>> getAttendanceRecords(int userId) async {
    final responseDate = await client
        .from('point')
        .select()
        .eq('user_id', userId)
        .order('time', ascending: false);

    return List<Map<String, dynamic>>.from(responseDate as List);
  }
}
