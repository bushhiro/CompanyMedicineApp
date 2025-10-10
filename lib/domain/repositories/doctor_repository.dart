import '../entities/doctor_entity.dart';

abstract class DoctorRepository {
  Future<DoctorEntity> login(String phone, String password);
}