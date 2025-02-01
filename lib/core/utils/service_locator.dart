import 'package:get_it/get_it.dart';
import 'package:physio_app/features/auth/data/repos/auth_repo_impl.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<AuthRepoImpl>(AuthRepoImpl());
}
