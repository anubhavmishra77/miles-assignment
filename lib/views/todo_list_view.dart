import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_models/todo_view_model.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/todo_item_widget.dart';
import '../models/todo_item.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _showAddTodo = false.obs;

  final TodoController todoController = Get.find<TodoController>();
  final FirebaseService firebaseService = Get.find<FirebaseService>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    // Clear the todo data before logging out
    todoController.clearData();

    await firebaseService.signOut();
    Get.offAllNamed('/');
  }

  Future<void> _handleEdit(TodoItem todo) async {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);
    final formKey = GlobalKey<FormState>();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Todo'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInputField(
                label: 'Title',
                hint: 'Enter todo title',
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInputField(
                label: 'Description',
                hint: 'Enter todo description',
                controller: descriptionController,
                isMultiline: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              titleController.dispose();
              descriptionController.dispose();
              Get.back(result: false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(result: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await todoController.editTodo(
          todo.id,
          titleController.text,
          descriptionController.text,
        );
      } catch (e) {
        // Error handling is done in the controller
      }
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _handleDelete(TodoItem todo) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await todoController.deleteTodo(todo.id);
      } catch (e) {
        // Error handling is done in the controller
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = firebaseService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                userEmail,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          Obx(() => IconButton(
                icon: Icon(_showAddTodo.value ? Icons.close : Icons.add),
                onPressed: () => _showAddTodo.value = !_showAddTodo.value,
              )),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => _showAddTodo.value
              ? _buildAddTodoForm()
              : const SizedBox.shrink()),
          Expanded(
            child: Obx(() => _buildTodoList()),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTodoForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomInputField(
              label: 'Title',
              hint: 'Enter todo title',
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Description',
              hint: 'Enter todo description',
              controller: _descriptionController,
              isMultiline: true,
            ),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
                  onPressed: todoController.isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await todoController.addTodo(
                                _titleController.text,
                                _descriptionController.text,
                              );
                              _titleController.clear();
                              _descriptionController.clear();
                              _showAddTodo.value = false;
                            } catch (e) {
                              // Error handling is done in the controller
                            }
                          }
                        },
                  child: todoController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Todo'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    if (todoController.isLoading.value && todoController.todos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todoController.todos.isEmpty) {
      return const Center(
        child: Text('No todos yet. Add one to get started!'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // The stream will automatically refresh
      },
      child: ListView.builder(
        itemCount: todoController.todos.length,
        itemBuilder: (context, index) {
          final todo = todoController.todos[index];
          return TodoItemWidget(
            todo: todo,
            onDelete: () => _handleDelete(todo),
            onToggleComplete: (value) =>
                todoController.toggleTodoComplete(todo),
            onEdit: () => _handleEdit(todo),
          );
        },
      ),
    );
  }
}
