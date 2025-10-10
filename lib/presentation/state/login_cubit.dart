import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/login_doctor.dart';

class LoginController {
  final LoginDoctor loginDoctor;

  LoginController(this.loginDoctor);

  Future<DoctorEntity?> login(String phone, String password) async {
    try {
      return await loginDoctor(phone, password);
    } catch (e) {
      rethrow;
    }
  }
}