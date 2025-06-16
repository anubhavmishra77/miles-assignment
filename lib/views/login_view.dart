import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../view_models/todo_view_model.dart';
import '../widgets/custom_input_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final _isLoading = false.obs;
  final _isSignUp = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      if (_isSignUp.value) {
        await _firebaseService.signUp(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await _firebaseService.signIn(
          _emailController.text,
          _passwordController.text,
        );
      }

      final TodoController todoController = Get.find<TodoController>();
      todoController.reinitialize();

      Get.offAllNamed('/todos');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() => Text(
                      _isSignUp.value ? 'Create Account' : 'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(height: 32),
                CustomInputField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Obx(() => ElevatedButton(
                      onPressed: _isLoading.value ? null : _handleSubmit,
                      child: _isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUp.value ? 'Sign Up' : 'Sign In'),
                    )),
                const SizedBox(height: 16),
                Obx(() => TextButton(
                      onPressed: _isLoading.value
                          ? null
                          : () => _isSignUp.value = !_isSignUp.value,
                      child: Text(_isSignUp.value
                          ? 'Already have an account? Sign In'
                          : 'Need an account? Sign Up'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
