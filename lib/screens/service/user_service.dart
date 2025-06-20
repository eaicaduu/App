import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient client;

  UserService(this.client);

  // Listar usuários
  Future<List<Map<String, dynamic>>> getUsers() async {
    final List<dynamic> responseUser = await client.from('users').select();
    return responseUser.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getUserByName(String username) async {
    final response = await client
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();

    return response;
  }

  Future<void> createUser(String nome, String username, String senha) async {
    await client.from('users').insert({
      'name': nome,
      'username': username,
      'password': senha,
      'admin': false,
    });
  }

  Future<bool> usernameExists(String username) async {
    final response = await client
        .from('users')
        .select('id')
        .eq('username', username)
        .maybeSingle();

    return response != null;
  }

  // Deletar usuário
  Future<void> deleteUser(int userId) async {
    await client.from('users').delete().eq('id', userId);
  }

  // Atualizar usuário
  Future<void> updateUser(int userId, String name, String username,
      String password, bool isadmin) async {
    await client.from('users').update({
      'name': name,
      'username': username,
      'password': password,
      'admin': isadmin ? true : false,
    }).eq('id', userId);
  }

  Future<void> recordAttendance(int userId, DateTime time, String type) async {
    final response = await client
        .from('point')
        .select()
        .eq('user_id', userId)
        .eq('year', time.year)
        .eq('month', time.month)
        .eq('day', time.day);

    int countToday = (response as List).length;

    String period;
    if (countToday < 2) {
      period = 'Manhã';
    } else if (countToday < 4) {
      period = 'Tarde';
    } else {
      period = 'Extra';
    }

    await client.from('point').insert({
      'user_id': userId,
      'year': time.year,
      'month': time.month,
      'day': time.day,
      'hour': time.hour,
      'minute': time.minute,
      'second': time.second,
      'type': type,
      'period': period,
    });
  }

  // Buscar pontos de um usuário
  Future<List<Map<String, dynamic>>> getAttendanceRecords(int userId) async {
    final response = await client
        .from('point')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: true);

    return response.map((record) {
      final year = record['year'];
      final month = record['month'];
      final day = record['day'];
      final hour = record['hour'];
      final minute = record['minute'];
      final second = record['second'];

      final dateTime = DateTime(year, month, day, hour, minute, second);
      return {
        'type': record['type'],
        'time': dateTime,
      };
    }).toList();
  }
}
