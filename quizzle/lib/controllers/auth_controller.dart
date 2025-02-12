// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:quizzle/firebase/references.dart';
// import 'package:quizzle/screens/screens.dart'
//     show AppIntroductionScreen, HomeScreen, LoginScreen;
// import 'package:quizzle/utils/utils.dart';
// import 'package:quizzle/widgets/widgets.dart';

// class AuthController extends GetxController {
//   @override
//   void onReady() {
//     initAuth();
//     super.onReady();
//   }

//   late FirebaseAuth _auth;
//   final _user = Rxn<User>();
//   late Stream<User?> _authStateChanges;

//   void initAuth() async {
//     await Future.delayed(const Duration(seconds: 2)); // waiting in splash
//     _auth = FirebaseAuth.instance;
//     _authStateChanges = _auth.authStateChanges();
//     _authStateChanges.listen((User? user) {
//       _user.value = user;
//     });
//     navigateToIntroduction();
//   }

//   Future<void> siginInWithGoogle() async {
//     final GoogleSignIn googleSignIn = GoogleSignIn();

//     try {
//       GoogleSignInAccount? account = await googleSignIn.signIn();
//       if (account != null) {
//         final gAuthentication = await account.authentication;
//         final credential = GoogleAuthProvider.credential(
//             idToken: gAuthentication.idToken,
//             accessToken: gAuthentication.accessToken);
//         await _auth.signInWithCredential(credential);
//         await saveUser(account);
//         navigateToHome();
//       }
//     } on Exception catch (error) {
//       AppLogger.e(error);
//     }
//   }

//   Future<void> signOut() async {
//     AppLogger.d("Sign out");
//     try {
//       await _auth.signOut();
//       navigateToHome();
//     } on FirebaseAuthException catch (e) {
//       AppLogger.e(e);
//     }
//   }

//   Future<void> saveUser(GoogleSignInAccount account) async {
//     userFR.doc(account.email).set({
//       "email": account.email,
//       "name": account.displayName,
//       "profilepic": account.photoUrl
//     });
//   }

//   User? getUser() {
//     _user.value = _auth.currentUser;
//     return _user.value;
//   }

//   bool isLogedIn() {
//     return _auth.currentUser != null;
//   }

//   void navigateToHome() {
//     Get.offAllNamed(HomeScreen.routeName);
//   }

//   void navigateToLogin() {
//     Get.toNamed(LoginScreen.routeName);
//   }

//   void navigateToIntroduction() {
//     Get.offAllNamed(AppIntroductionScreen.routeName);
//   }

//   void showLoginAlertDialog() {
//     Get.dialog(
//       Dialogs.quizStartDialog(onTap: () {
//         Get.back();
//         navigateToLogin();
//       }),
//       barrierDismissible: false,
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:quizzle/firebase/references.dart';
import 'package:quizzle/screens/screens.dart'
    show AppIntroductionScreen, HomeScreen, LoginScreen;
import 'package:quizzle/utils/utils.dart';
import 'package:quizzle/widgets/widgets.dart';

class AuthController extends GetxController {
  @override
  void onReady() {
    initAuth();
    super.onReady();
  }

  late FirebaseAuth _auth;
  final _user = Rxn<User>();
  late Stream<User?> _authStateChanges;

  void initAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Waiting in splash
    _auth = FirebaseAuth.instance;
    _authStateChanges = _auth.authStateChanges();
    _authStateChanges.listen((User? user) {
      _user.value = user;
    });
    navigateToIntroduction();
  }

  /// **🔹 Register New User with Email & Password**
  Future<void> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user to Firestore
      await saveUser(userCredential.user!);
      navigateToHome();
    } catch (e) {
      AppLogger.e(e);
      Get.snackbar("Error", e.toString(),
          backgroundColor: Get.theme.colorScheme.error);
    }
  }

  /// **🔹 Sign In with Email & Password**
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      navigateToHome();
    } catch (e) {
      AppLogger.e(e);
      Get.snackbar("Error", e.toString(),
          backgroundColor: Get.theme.colorScheme.error);
    }
  }

  /// **🔹 Sign Out**
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      navigateToLogin();
    } catch (e) {
      AppLogger.e(e);
    }
  }

  /// **🔹 Save User to Firestore**
  Future<void> saveUser(User user) async {
    await userFR.doc(user.email).set({
      "email": user.email,
      "name": user.displayName ?? "User",
      "profilepic": user.photoURL ?? "",
    });
  }

  /// **🔹 Get Current User**
  User? getUser() {
    _user.value = _auth.currentUser;
    return _user.value;
  }

  /// **🔹 Check if User is Logged In**
  bool isLogedIn() {
    return _auth.currentUser != null;
  }

  /// **🔹 Navigation Functions**
  void navigateToHome() {
    Get.offAllNamed(HomeScreen.routeName);
  }

  void navigateToLogin() {
    Get.offAllNamed(LoginScreen.routeName);
  }

  void navigateToIntroduction() {
    Get.offAllNamed(AppIntroductionScreen.routeName);
  }

  /// **🔹 Show Login Dialog**
void showLoginAlertDialog() async {
  bool startQuiz = await Dialogs.quizStartDialog(onTap: () {
    Get.back();
    navigateToLogin();
  });

  if (startQuiz) {
    navigateToLogin();
  }
}

}
