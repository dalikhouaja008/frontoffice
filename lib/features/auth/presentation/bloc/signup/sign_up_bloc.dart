import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_boost/features/auth/domain/entities/grpd_consent.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/use_cases/sign_up_use_case.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpUseCase signUpUseCase;

  SignUpBloc(this.signUpUseCase) : super(SignUpInitial()) {
    on<SignUpRequested>((event, emit) async {
      emit(SignUpLoading());

      final result = await signUpUseCase(
        event.username, 
        event.email, 
        event.password, 
        event.role, 
        event.publicKey);

      result.fold(
        (failure) => emit(SignUpFailure(failure)),
        (user) {
          emit(SignUpSuccess(user));
                },
      );
    });
  }
}
