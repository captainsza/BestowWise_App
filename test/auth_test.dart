// import 'package:allinbest/services/auth/auth_exceptions.dart';
// import 'package:allinbest/services/auth/auth_provider.dart';
// import 'package:allinbest/services/auth/auth_user.dart';
// import 'package:test/test.dart';

// void main() {
//   group('mock Authentication', () {
//     final provider = MockAuthProvider();
//     test('should not be initialized to begin with ', () {
//       expect(provider.isInitialized, false);
//     });

//     test('cannot log out if not initialized', () {
//       expect(
//         provider.logout(),
//         throwsA(const TypeMatcher<NotInitializedException>()),
//       );
//     });

//     test('should be able to be initializes', () async {
//       await provider.initialize();
//       expect(provider.isInitialized, true);
//     });

//     test('User should be null after initialized', () {
//       expect(provider.currentUser, null);
//     });

//     test(
//       'should be able to initialize in less than 2 seconds ',
//       () async {
//         await provider.initialize();
//         expect(provider.isInitialized, true);
//       },
//       timeout: const Timeout(Duration(seconds: 2)),
//     );
//     test('Create user should delegate to login function', () async {
//       final badEmailUser = provider.createUser(
//         email: 'coolmam@gmail.com',
//         password: 'coolmam',
//       );
//       expect(badEmailUser,
//           throwsA(const TypeMatcher<UserNOtFoundAuthException>()));

//       expect(badEmailUser,
//           throwsA(const TypeMatcher<WrongPasswordAuthException>()));
//       final user = await provider.createUser(
//         email: 'foo',
//         password: 'null',
//       );
//       expect(provider.currentUser, user);
//       expect(user.isEmailVerified, false);
//     });
//     test('Log in should be able to get verified', () {
//       provider.sendEmailVerification();
//       final user = provider.currentUser;
//       expect(user, isNull);
//       expect(user!.isEmailVerified, true);
//     });

//     test('Should be able to log out and log in again ', () async {
//       await provider.logout();
//       await provider.login(
//         email: 'email',
//         password: 'password',
//       );
//       final user = provider.currentUser;
//       expect(user, isNotNull);
//     });
//   });
// }

// class NotInitializedException implements Exception {}

// AuthUser? _user;

// class MockAuthProvider implements AuthProvider {
//   var _isInitialized = false;
//   bool get isInitialized => _isInitialized;

//   @override
//   Future<AuthUser> createUser({
//     required String email,
//     required String password,
//   }) async {
//     if (!isInitialized) throw NotInitializedException();
//     await Future.delayed(const Duration(seconds: 1));
//     return login(
//       email: email,
//       password: password,
//     );
//   }

//   @override
//   AuthUser? get currentUser => _user;

//   @override
//   Future<void> initialize() async {
//     await Future.delayed(const Duration(seconds: 1));
//     _isInitialized = true;
//   }

//   @override
//   Future<AuthUser> login({
//     required String email,
//     required String password,
//   }) {
//     if (!isInitialized) throw NotInitializedException();
//     if (email == 'foo@bar.com') throw UserNOtFoundAuthException();
//     if (password == 'newworldismy') throw WrongPasswordAuthException();
//     const user = AuthUser(isEmailVerified: false);
//     _user = user;
//     return Future.value(user);
//   }

//   @override
//   Future<void> logout() async {
//     if (!isInitialized) throw NotInitializedException();
//     if (_user == null) throw UserNOtFoundAuthException();
//     await Future.delayed(const Duration(seconds: 1));
//     _user = null;
//   }

//   @override
//   Future<void> sendEmailVerification() async {
//     if (!isInitialized) throw NotInitializedException();
//     final user = _user;
//     if (user == null) throw UserNOtFoundAuthException();
//     const newUser = AuthUser(isEmailVerified: true);
//     _user = newUser;
//   }
// }
