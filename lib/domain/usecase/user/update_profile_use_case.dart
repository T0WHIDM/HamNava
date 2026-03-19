import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class UpdateProfileUseCase {
  final IUserRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<ApiException, void>> call({
    required String userId,
    required String name,
    required String email,
    required String userName,
    // File? avatar,
  }) {
    return repository.updateProfile(
      userId: userId, // پاس دادن آیدی به ریپازیتوری
      name: name,
      email: email,
      userName: userName,
    );
  }
}
