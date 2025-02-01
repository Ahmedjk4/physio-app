import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:physio_app/core/types/failures.dart';
import 'package:physio_app/core/types/success.dart';
import 'package:physio_app/features/auth/data/repos/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  @override
  Future<Either<Failure, Success>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return right(Success('Logged in successfully'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return left(Failure('No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        return left(Failure('Wrong password provided for that user.'));
      } else if (e.code == 'invalid-credential') {
        return left(Failure('Wrong Email or Password'));
      } else {
        print(e.code);
        return left(Failure('An error occurred, please try again later.'));
      }
    } catch (e) {
      return left(Failure('An error occurred, please try again later.'));
    }
  }

  @override
  Future<Either<Failure, Success>> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return right(Success('Signed out successfully'));
    } catch (e) {
      return left(Failure(
          'An error occurred while signing out, please try again later.'));
    }
  }

  @override
  Future<Either<Failure, Success>> signUp(
      String name, String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      return right(Success('Signed up successfully, Please Login'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return left(Failure('The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        return left(Failure('The account already exists for that email.'));
      } else {
        return left(Failure('An error occurred, please try again later.'));
      }
    } catch (e) {
      return left(Failure('An error occurred, please try again later.'));
    }
  }

  @override
  Future<Either<Failure, Success>> resetPassword(String email) async {
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return right(Success('Password reset link sent to $email'));
    } catch (e) {
      return left(Failure('An error occurred, please try again later.'));
    }
  }

  @override
  Future<Either<Failure, Success>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      return right(Success('Logged In With Google Successfully'));
    } catch (e) {
      return left(Failure('An error occurred, please try again later.'));
    }
  }
}
