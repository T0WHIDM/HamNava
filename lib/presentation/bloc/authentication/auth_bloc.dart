import 'package:bloc/bloc.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/log_out_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/login_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/register_use_case.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogOutUseCase _logOutUseCase;

  AuthBloc(this._loginUseCase, this._registerUseCase, this._logOutUseCase)
    : super(AuthInitial()) {
      
    //login
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await _loginUseCase(event.userName, event.password);
      emit(AuthSuccess(result));
    });

    //register
    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoading());

      var result = await _registerUseCase(
        event.name,
        event.username,
        event.email,
        event.password,
        event.passwordConfirm,
        // event.avatarFile,
      );

      emit(AuthSuccess(result));
    });

    //log out
    on<AuthLogOutEvent>((event, emit) async {
      emit(AuthLoading());

      var result = await _logOutUseCase.call();

      emit(AuthSuccess(result));
    });
  }
}
