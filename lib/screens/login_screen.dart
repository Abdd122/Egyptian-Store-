
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/providers/user_provider.dart'; // Import UserProvider

enum AuthMode { signup, login }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      if (_authMode == AuthMode.login) {
        await authService.signInWithEmailAndPassword(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        await authService.signUpWithEmailAndPassword(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  // --- Google Sign-In Logic ---
  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final userCredential = await userProvider.signInWithGoogle();
      if (userCredential == null) {
        // User cancelled the sign-in
        _showErrorDialog("تم إلغاء تسجيل الدخول.");
      }
      // Navigation will be handled by the auth state listener
    } catch (error) {
      _showErrorDialog("حدث خطأ أثناء تسجيل الدخول مع Google: $error");
    }
    // No need to set isLoading to false here, as the auth listener will trigger a rebuild
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Check if the widget is still in the tree
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حدث خطأ'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('حسنًا'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
    setState(() {
      _isLoading = false; // Reset loading state after showing the dialog
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: deviceSize.width * 0.8,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _authMode == AuthMode.login ? 'تسجيل الدخول' : 'إنشاء حساب',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 20),
                  // Email and Password fields (unchanged)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'بريد إلكتروني غير صالح!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'كلمة المرور قصيرة جدًا!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                    },
                  ),
                  if (_authMode == AuthMode.signup)
                    TextFormField(
                      enabled: _authMode == AuthMode.signup,
                      decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                      obscureText: true,
                      validator: _authMode == AuthMode.signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'كلمتا المرور غير متطابقتين!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(_authMode == AuthMode.login ? 'تسجيل الدخول' : 'إنشاء حساب'),
                        ),
                        const SizedBox(height: 10),
                        // --- Google Sign-In Button ---
                        ElevatedButton.icon(
                          onPressed: _googleSignIn,
                          icon: Image.asset('assets/images/google_logo.png', height: 24.0), // Assuming you have a google logo asset
                          label: const Text('تسجيل الدخول مع Google'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                        _authMode == AuthMode.login ? 'إنشاء حساب جديد' : 'لدي حساب بالفعل'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
