import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/exception_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../services/api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc(this._apiService) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      // Check if token exists in shared preferences
      final token = await _apiService.sharedPrefService.getToken();
      if (token != null) {
        try {
          final avatarUrl = await _apiService.getUserAvatar();
          emit(Authenticated(avatarUrl));
        } on InvalidTokenException {
          print('Invalid Token exception');
          final refreshToken =
              await _apiService.sharedPrefService.getRefreshToken();
          if (refreshToken != null) {
            print('Have refresh token');
            await _apiService.refreshToken();
            final avatarUrl = await _apiService.getUserAvatar();
            emit(Authenticated(avatarUrl));
          } else {
            print('GOing to initial state');
            emit(AuthInitial());
          }
        }
      } else {
        emit(AuthInitial());
      }
    });

    on<PhoneNumberSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _apiService.sendOtp(event.phoneNumber);
        emit(OtpSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<OtpSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        print('phoneNumber: ${event.phoneNumber}\notp: ${event.otp}');
        final token = await _apiService.verifyOtp(event.phoneNumber, event.otp);
        if (token != null) {
          final avatarUrl = await _apiService.getUserAvatar();
          emit(Authenticated(avatarUrl));
        }
      } catch (e) {
        emit(AuthError('OTP Verification Failed'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _apiService.sharedPrefService.clearToken();
      emit(AuthInitial());
    });
  }
}
