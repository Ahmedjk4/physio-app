import 'package:dartz/dartz.dart';
import 'package:physio_app/core/types/failures.dart';
import 'package:physio_app/core/types/success.dart';

abstract class AuthRepo {
  Future<Either<Failure, Success>> signInWithEmailAndPassword(
      String email, String password);
  Future<Either<Failure, Success>> signUp(
      String name, String email, String password);
  Future<Either<Failure, Success>> resetPassword(String email);
  Future<void> signOut();
  Future<Either<Failure, Success>> signInWithGoogle();
}
