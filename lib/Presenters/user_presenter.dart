import 'package:reqres_api_andres/Models/Users.dart';
import 'package:reqres_api_andres/Services/api_service.dart';

class UserPresenter {
  final ApiService _apiService;
  Function(List<User>, int, int, int, int)? onUsersUpdated;
  Function(String)? onError;

  UserPresenter(this._apiService);

  Future<void> loadUsers({int page = 1, int perPage = 6}) async {
    try {
      final result = await _apiService.getUsers(page: page, perPage: perPage);
      onUsersUpdated?.call(
        result['users'],
        result['current_page'],
        result['total_pages'],
        result['per_page'],
        result['total']
      );
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<void> createUser(User user) async {
    try {
      if (await _apiService.createUser(user)) {
        await loadUsers(page: 1); // Volver a la primera página después de crear
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<void> updateUser(int id, User user) async {
    try {
      if (await _apiService.updateUser(id, user)) {
        await loadUsers(); // Recargar la lista actual después de actualizar
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _apiService.deleteUser(id);
      await loadUsers(); // Recargar la lista después de eliminar
    } catch (e) {
      onError?.call(e.toString());
    }
  }
}