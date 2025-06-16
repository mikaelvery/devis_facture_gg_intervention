import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devis_facture_gg_intervention/constants/colors.dart';
import 'package:devis_facture_gg_intervention/screens/home_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _rememberMe = false;
  bool _isLoggingIn = false;
  bool _loginSuccess = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isCheckingLogin = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.setLanguageCode('fr');
    _listenToTokenRefresh();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _controller.forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _loadSavedCredentials().then((_) {
      _checkIfUserIsAlreadyLoggedIn();
    });
  }

  Future<void> _checkIfUserIsAlreadyLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (_rememberMe && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      await _onLoginPressed();
    } else {
      if (mounted) {
        setState(() {
          _isCheckingLogin = false;
        });
      }
    }
  }

  void _listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': newToken,
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');
    final savedPassword = prefs.getString('savedPassword');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _onLoginPressed() async {
    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = cred.user;
      if (user != null) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'fcmToken': token,
          }, SetOptions(merge: true));
        }
      }

      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('savedEmail', _emailController.text.trim());
        await prefs.setString('savedPassword', _passwordController.text.trim());
      } else {
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
      }

      setState(() => _loginSuccess = true);
      _controller.forward();

      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = "Mot de passe incorrect.";
          break;
        case 'invalid-email':
          message = "Adresse email invalide.";
          break;
        case 'user-not-found':
          message = "Email ou mot de passe incorrect.";
          break;
        case 'invalid-credential':
          message = "Identifiants invalides ou expirés.";
          break;
        default:
          message = "Erreur inconnue, veuillez réessayer.";
      }

      setState(() {
        _isLoggingIn = false;
        _errorMessage = message;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: _isCheckingLogin
              ? _buildSplashAnimation()
              : (_loginSuccess ? _buildSplashAnimation() : _buildLoginForm()),
        ),
      ),
    );
  }

  Widget _buildSplashAnimation() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: const Text(
          'Bienvenue',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

            final fade = Tween<double>(begin: 0, end: 1).animate(_controller);

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Connexion",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 24),
              _textField(
                controller: _emailController,
                hintText: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _textField(
                controller: _passwordController,
                hintText: "Mot de passe",
                icon: Icons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: blueAccent.withAlpha(180),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: blueAccent,
                    onChanged: (val) =>
                        setState(() => _rememberMe = val ?? false),
                  ),
                  const Text("Se souvenir de moi"),
                ],
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoggingIn
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _onLoginPressed();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: blueAccent,
                ),
                child: _isLoggingIn
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Champ requis';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: darkBlue),
        suffixIcon: suffixIcon,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
