import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class LoginDoctor {
  final DoctorRepository repository;

  LoginDoctor(this.repository);

  Future<DoctorEntity> call(String phone, String password) async {
    return await repository.login(phone, password);
  }
}