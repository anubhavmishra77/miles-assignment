import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<List<TodoItem>> getTodosStream() {
    final userId = currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('todos')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final todos = snapshot.docs.map((doc) {
        return TodoItem.fromFirestore(doc);
      }).toList();
      return todos;
    }).handleError((error) {
      throw error;
    });
  }

  Future<void> addTodo(TodoItem todo) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final todoData = {
      'title': todo.title,
      'description': todo.description,
      'isCompleted': todo.isCompleted,
      'ownerId': currentUser!.uid,
      'ownerEmail': currentUser!.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('todos').add(todoData);
  }

  Future<void> updateTodo(TodoItem todo) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final todoRef = _firestore.collection('todos').doc(todo.id);
    final todoDoc = await todoRef.get();

    if (!todoDoc.exists) throw Exception('Todo not found');

    final data = todoDoc.data() as Map<String, dynamic>;
    if (data['ownerId'] != currentUser!.uid) {
      throw Exception('You can only update your own todos');
    }

    final updateData = {
      'title': todo.title,
      'description': todo.description,
      'isCompleted': todo.isCompleted,
      'ownerId': todo.ownerId,
      'ownerEmail': todo.ownerEmail,
    };

    await todoRef.update(updateData);
  }

  Future<void> deleteTodo(String todoId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final todoRef = _firestore.collection('todos').doc(todoId);
    final todoDoc = await todoRef.get();

    if (!todoDoc.exists) throw Exception('Todo not found');

    final data = todoDoc.data() as Map<String, dynamic>;
    if (data['ownerId'] != currentUser!.uid) {
      throw Exception('You can only delete your own todos');
    }

    await todoRef.delete();
  }
}
