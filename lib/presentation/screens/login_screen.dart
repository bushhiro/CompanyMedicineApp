import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_app/widgets/action_buttons.dart';
import '../../data/models/doctor.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repo = DoctorRepositoryImpl();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final request = DoctorLoginRequest(
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final authResponse = await _repo.login(request);

      final prefs = await SharedPreferences.getInstance();

      if (authResponse == null) {
        throw Exception("Пустой ответ");
      }

      final doctor = await _repo.getCurrentDoctor(authResponse.token);

      print("TOKEN IS : ${authResponse.token}");
      await prefs.setString('token', authResponse.token);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            doctorName: doctor?.fullName ?? 'Неизвестно',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(title: const Text("Авторизация"), backgroundColor: AppColors.primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Телефон"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Пароль"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ActionButtons(
                alignment: Alignment.center,
                showOpen: true,
                openLabel: "Войти",
                onOpen: _loading ? null : _login,
              ),
          ],
        )
      ),
    );
  }
}