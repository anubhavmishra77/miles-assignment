import 'dart:async';
import 'package:get/get.dart';
import '../models/todo_item.dart';
import '../services/firebase_service.dart';

class TodoController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Reactive variables
  final RxList<TodoItem> todos = <TodoItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<List<TodoItem>>? _todosSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadTodos();
  }

  @override
  void onClose() {
    _todosSubscription?.cancel();
    super.onClose();
  }

  void _loadTodos() {
    // Cancel previous subscription if exists
    _todosSubscription?.cancel();

    _todosSubscription = _firebaseService.getTodosStream().listen(
      (todoList) {
        todos.value = todoList;
        error.value = '';
      },
      onError: (err) {
        error.value = err.toString();
        Get.snackbar(
          'Error',
          'Failed to load todos: ${err.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Method to clear all data (call on logout)
  void clearData() {
    _todosSubscription?.cancel();
    todos.clear();
    error.value = '';
    isLoading.value = false;
  }

  // Method to reinitialize for new user (call on login)
  void reinitialize() {
    clearData();
    _loadTodos();
  }

  Future<void> addTodo(String title, String description) async {
    try {
      isLoading.value = true;
      error.value = '';

      final todo = TodoItem(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        isCompleted: false,
        createdAt: DateTime.now(),
        ownerId: _firebaseService.currentUser?.uid ?? '',
        ownerEmail: _firebaseService.currentUser?.email ?? '',
      );

      await _firebaseService.addTodo(todo);

      Get.snackbar(
        'Success',
        'Todo added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editTodo(
      String todoId, String newTitle, String newDescription) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Find the existing todo
      final existingTodo = todos.firstWhere((todo) => todo.id == todoId);

      // Create updated todo
      final updatedTodo = existingTodo.copyWith(
        title: newTitle,
        description: newDescription,
      );

      await _firebaseService.updateTodo(updatedTodo);

      Get.snackbar(
        'Success',
        'Todo updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTodo(TodoItem todo) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _firebaseService.updateTodo(todo);

      Get.snackbar(
        'Success',
        'Todo updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _firebaseService.deleteTodo(todoId);

      Get.snackbar(
        'Success',
        'Todo deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete todo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = '';
  }

  void toggleTodoComplete(TodoItem todo) {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    updateTodo(updatedTodo);
  }
}
