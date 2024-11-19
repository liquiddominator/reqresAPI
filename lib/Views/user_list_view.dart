
import 'package:flutter/material.dart';
import 'package:reqres_api_andres/Models/Users.dart';
import 'package:reqres_api_andres/Presenters/user_presenter.dart';
import 'package:reqres_api_andres/Services/api_service.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final UserPresenter _presenter = UserPresenter(ApiService());
  List<User> users = [];
  int currentPage = 1;
  int totalPages = 1;
  int perPage = 6;
  int total = 0;
  bool isLoading = false;
  
  final List<int> perPageOptions = [3, 6, 9, 12];

  @override
  void initState() {
    super.initState();
    _presenter.onUsersUpdated = (userList, page, pages, itemsPerPage, totalItems) {
      setState(() {
        users = userList;
        currentPage = page;
        totalPages = pages;
        perPage = itemsPerPage;
        total = totalItems;
        isLoading = false;
      });
    };
    _presenter.onError = (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    };
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    await _presenter.loadUsers(page: currentPage, perPage: perPage);
  }

  Future<void> _refreshUsers() async {
    await _loadUsers();
  }

  void _showUserDialog([User? user]) {
    final emailController = TextEditingController(text: user?.email);
    final firstNameController = TextEditingController(text: user?.firstName);
    final lastNameController = TextEditingController(text: user?.lastName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Crear Usuario' : 'Editar Usuario'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un email';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un email valido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un apellido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final newUser = User(
                  id: user?.id,
                  email: emailController.text,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  avatar: user?.avatar ?? 'https://reqres.in/img/faces/1-image.jpg',
                );
                
                if (user == null) {
                  _presenter.createUser(newUser);
                } else {
                  _presenter.updateUser(user.id!, newUser);
                }
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(user == null ? 'Usuario creado' : 'Usuario actualizado'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(user == null ? 'Crear' : 'Editar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar un usuario'),
        content: Text('Seguro que quiere eliminar a ${user.firstName} ${user.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              _presenter.deleteUser(user.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario eliminado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReqRes Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Controles de paginación
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Selector de items por página
                      Row(
                        children: [
                          const Text('Usuarios por pagina: '),
                          DropdownButton<int>(
                            value: perPage,
                            items: perPageOptions.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  perPage = newValue;
                                  currentPage = 1; // Reset a la primera página
                                });
                                _loadUsers();
                              }
                            },
                          ),
                        ],
                      ),
                      // Navegación de páginas
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: currentPage > 1
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                    _loadUsers();
                                  }
                                : null,
                          ),
                          Text('Page $currentPage of $totalPages'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: currentPage < totalPages
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                    _loadUsers();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text('Usuarios totales: $total', 
                    style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          // Lista de usuarios
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshUsers,
                    child: users.isEmpty
                        ? const Center(
                            child: Text('Usuarios no encontrados'),
                          )
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: ListTile(
                                  leading: Hero(
                                    tag: 'avatar-${user.id}',
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(user.avatar),
                                    ),
                                  ),
                                  title: Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(user.email),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showUserDialog(user),
                                        tooltip: 'Editar usuario',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _showDeleteDialog(user),
                                        tooltip: 'Eliminar usuario',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar usuario'),
      ),
    );
  }
}