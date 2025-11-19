import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vasvault/models/auth_response.dart';
import 'package:vasvault/models/register_request.dart';
import 'package:vasvault/repositories/register_repository.dart';
import 'package:meta/meta.dart';
import 'package:vasvault/utils/session_meneger.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<SignupEvent, SignupState> {
  final repository = SignupRepository();
  RegisterBloc() : super(SignupInitial()) {
    on<Signup>((event, emit) async {
      emit(SignupLoading());
      final result = await repository.signup(event.requestBody);

      // Avoid using async callbacks inside fold (they're not awaited by fold),
      // which can cause emit(...) to be called after the handler finished.
      String? errorMessage;
      AuthResponseModel? signupData;

      result.fold((l) => errorMessage = l, (r) => signupData = r);

      if (errorMessage != null) {
        emit(SignupFailed(errorMessage!));
        return;
      }

      if (signupData == null) {
        // Shouldn't happen, but guard against unexpected null
        emit(SignupFailed('Unknown signup error'));
        return;
      }

      // Copy to a local non-nullable variable so it's safe to use across awaits
      final data = signupData!;

      // signupData is non-null here; save session then emit success.
      final sessionManager = SessionManager();
      await sessionManager.saveSession(
        data.accessToken,
        data.refreshToken,
        data.id,
      );

      // Ensure the handler didn't complete while awaiting; if so, skip emitting.
      if (emit.isDone) return;

      emit(SignupSuccess(data));
    });
  }
}