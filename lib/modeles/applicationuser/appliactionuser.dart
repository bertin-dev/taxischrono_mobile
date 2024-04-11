import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:taxischrono/screens/homepage.dart';

import '../../screens/auths/register.dart';
import '../../services/firebaseauthservice.dart';
import '../../varibles/variables.dart';
import '../autres/reservation.dart';
import '../autres/transaction.dart';
import '../discutions/conversation.dart';
import '../discutions/message.dart';
import 'package:logger/logger.dart';
import 'client.dart';

class ApplicationUser {
  String? userid;
  final String userEmail;
  final String userName;
  final String? userTelephone;
  final String? userProfile;
  final String? motDePasse;
  final String? userAdresse;
  final String? userDescription;
  final String? userCni;
  final DateTime? expireCniDate;

  ApplicationUser({
    this.userAdresse,
    required this.userEmail,
    required this.userName,
    this.userTelephone,
    this.userCni,
    this.motDePasse,
    this.userDescription,
    this.userid,
    this.userProfile,
    this.expireCniDate,
  });

  factory ApplicationUser.fromJson(Map<String, dynamic> mapUser) =>
      ApplicationUser(
          userAdresse: mapUser['userAdresse'],
          userEmail: mapUser['userEmail'],
          userName: mapUser['userName'],
          userTelephone: mapUser['userTelephone'],
          userCni: mapUser['userCni'],
          userDescription: mapUser['userDescription'],
          userid: mapUser['userid'],
          userProfile: mapUser['userProfile'],
          expireCniDate: mapUser['expireCniDate']);

// factorisation des données
  Map<String, dynamic> toJson() => {
        if (userAdresse != null) 'userAdresse': userAdresse,
        if (userEmail.trim().isNotEmpty) 'userEmail': userEmail,
        if (userName.trim().isNotEmpty) 'userName': userName,
        if (userTelephone != null) 'userTelephone': userTelephone,
        if (userCni != null) 'userCni': userCni,
        if (userDescription != null) 'userDescription': userDescription,
        if (userid != null) 'userid': userid,
        if (userProfile != null) 'userProfile': userProfile,
        if (expireCniDate != null) 'ExpireCniDate': expireCniDate,
      };

//  Sauvegarde d'un utilisateur dans la base de donné.
  Future saveUser() async {
    final doc = await firestore.collection('Utilisateur').doc(userid!).get();
    if (doc.exists) {
      updateUser();
    } else {
      await firestore.collection('Utilisateur').doc(userid!).set(toJson());
    }
  }

// vérification de l'existance d'un utilisateur.
// la fonction seras utilsé avant l'authentification.
  static Future<bool> userExist(
      {String? userEmail, String? userPhonNumber}) async {
    var exist = false;
    await firestore.collection('Utilisateur').get().then((value) {
      value.docs.map((element) {
        ApplicationUser userapp = ApplicationUser.fromJson(element.data());

        if (userapp.userEmail == userEmail ||
            userapp.userTelephone == userPhonNumber) {
          exist = true;
        }
      }).toList();
    });
    return exist;
  }

// mettre à jour un utilisateur
  Future updateUser() async {
    await firestore.collection('Utilisateur').doc(userid!).update(toJson());
  }

// récupérer les information de l'utilisateur en temps reel.
  static Stream<ApplicationUser> appUserInfos(idClient) => firestore
      .collection('Utilisateur')
      .doc(idClient)
      .snapshots()
      .map((user) => ApplicationUser.fromJson(user.data()!));

  // récupérer les information de l'utilisateur en future.
  static Future<ApplicationUser> infos(idClient) =>
      firestore.collection('Utilisateur').doc(idClient).get().then((value) {
        final user = ApplicationUser.fromJson(value.data()!);
        // print(user.toJson());
        return user;
      });

// Utilisateur courant dans l'application
  static Stream<ApplicationUser?>? currentUser() {
    try {
      return authentication.authStateChanges().map(
            (user) => user == null
                ? null
                : ApplicationUser(
                    userEmail: user.email!,
                    userName: user.displayName!,
                    userTelephone: user.phoneNumber,
                    userid: user.uid,
                  ),
          );
    } catch (e) {
      return null;
    }
  }

// future appUser
  static Future<ApplicationUser?> currentUserFuture() async {
    try {
      return firestore
          .collection('Utilisateur')
          .doc(authentication.currentUser!.uid)
          .get()
          .then((user) => ApplicationUser.fromJson(user.data()!));
    } catch (e) {
      return null;
    }
  }

// login whith email and password
  login() async {
    if (authentication.currentUser == null) {
      await Authservices().login(userEmail, motDePasse);
    }
  }

// fonction de tchat
  static envoyerUnMessage(Message message) async {
    Conversation conversation = Conversation(lastMessage: message);
    await conversation.sendMessage();
  }

// permet d'envoyer un méssage d'urgence au service client.
  singalerUrgence({required String message}) {
    final Message msg = Message(
      senderUserId: userid!,
      destinationUserId: idServiceClient,
      libelle: message,
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'urgence',
      isRead: false,
    );
    Message reponse = Message(
      senderUserId: idServiceClient,
      destinationUserId: userid!,
      libelle:
          "Merci de bien vouloir nous signaler votre urgence S'il-vous-plait",
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'reponse',
      isRead: false,
    );
    envoyerUnMessage(msg);
    envoyerUnMessage(reponse);
  }

// fontion permettant d'envoyer un méssage au service client
  contacterLeServiceClient({required String message}) {
    final Message msg = Message(
      senderUserId: userid!,
      destinationUserId: idServiceClient,
      libelle: message,
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'contacter',
      isRead: false,
    );
    envoyerUnMessage(msg);
  }

// signaler le départ de la course
  static signalerDepart({required TransactionApp transaction}) {
    transaction.modifierEtat(1);
  }

// fonction permettant de signaler l'arrivé à destaination
  static signalerArriver({required TransactionApp transaction}) {
    transaction.modifierEtat(2);
  }

// fontion permettant d'annuler la rservation
  static annulerUneRservation(Reservation reservation) async {
    await reservation.annuletReservation();
  }

//  fonction per;ettqnt de noter le chquffeur
  static noterLechauffeur(
      {required TransactionApp transaction, required double note}) {
    transaction.noterChauffeur(note);
  }

  static Future authenticatePhonNumber(
      {required String phonNumber,
      required void Function(String, int?) onCodeSend,
      required void Function(PhoneAuthCredential) verificationCompleted,
      required void Function(FirebaseAuthException) verificationFailed,
      required GlobalKey<ScaffoldState> global}) async {
    var exist = await userExist(userPhonNumber: phonNumber);
    if (!exist) {
      FocusScope.of(global.currentContext!).unfocus();
      global.currentState!.showBottomSheet((context) {
        return Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Ce numéro n'as pas de compte",
                    style: police.copyWith(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                spacerHeight(30),
                boutonText(
                    context: context,
                    action: () {
                      Navigator.of(context).push(
                        PageTransition(
                            child: const SignupPage(),
                            type: PageTransitionType.leftToRight),
                      );
                    },
                    text: "Creez votre compte"),
                spacerHeight(15),
                boutonText(
                    context: context,
                    action: () {
                      Navigator.of(context).pop();
                    },
                    text: "Annuler")
              ],
            ),
          ),
        );
      });
    } else {
      await authentication.verifyPhoneNumber(
        phoneNumber: phonNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: onCodeSend,
        codeAutoRetrievalTimeout: (time) {},
      );
    }
  }

// validation OTP pour l'hautentification pour le chauffeur

  static Future validateOPT(context,
      {required String smsCode,
      required String verificationId,
      required String phone}) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await authentication.signInWithCredential(credential).then((value) async {
      if (value.user != null) {
        await value.user!.updatePhoneNumber(credential);
        await firestore
            .collection('Utilisateur')
            .doc(value.user!.uid)
            .update({"userTelephone": phone}).then((value) {
          Navigator.of(context).pushAndRemoveUntil(
              PageTransition(
                  child: const HomePage(),
                  type: PageTransitionType.leftToRight),
              (route) => false);
        });
      }
    });
  }

  static Future loginNumber(
    ApplicationUser chauffeurOtp, {
    required BuildContext context,
    required Function(String verificationId, int? value1) onCodeSend,
  }) async {
    try {
      await authentication.verifyPhoneNumber(
        phoneNumber: chauffeurOtp.userTelephone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await authentication
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              await value.user!.updateEmail(chauffeurOtp.userEmail);
              await value.user!.updateDisplayName(chauffeurOtp.userName);
              await value.user!.updatePassword(chauffeurOtp.motDePasse!);
              await chauffeurOtp.saveUser().then((val) async {
                await Client(idUser: value.user!.uid, tickets: 0)
                    .register()
                    .then((value) {
                  Navigator.of(context).pushAndRemoveUntil(
                      PageTransition(
                          child: const HomePage(),
                          type: PageTransitionType.leftToRight),
                      (route) => false);
                });
              });
            }
          });
        },
        verificationFailed: (FirebaseAuthException except) {
          debugPrint(except.code);
          Logger().d(except.code);

          toaster(
              message: "Erreur d'enrégistrement Veillez réssayer",
              color: Colors.red,
              long: true);
        },
        codeSent: onCodeSend,
        codeAutoRetrievalTimeout: (phone) {},
      );
    } catch (e) {
      debugPrint(e.toString());
      Logger().d(e.toString());
      toaster(
          message: "Erreur d'enrégistrement Veillez réssayer",
          color: Colors.red,
          long: true);
    }
  }

  static Future userRegister(BuildContext context, {required String email,
    required String password,
    required ApplicationUser chauffeur}) async {
    String? result;
    try {
      final userCredential = await authentication.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {

        await userCredential.user!.updateEmail(chauffeur.userEmail);
        await userCredential.user!.updateDisplayName(chauffeur.userName);
        await userCredential.user!.updatePassword(chauffeur.motDePasse!);
        await chauffeur.saveUser().then((val) async {
          await Client(idUser: userCredential.user!.uid, tickets: 0)
              .register()
              .then((value) {
            Navigator.of(context).pushAndRemoveUntil(
                PageTransition(
                    child: const HomePage(),
                    type: PageTransitionType.leftToRight),
                    (route) => false);
          });
        });

        //await util.user!.sendEmailVerification();
      } else {
        result = "Erreur pendant l'enregistrement du chauffeur";
        return result;
      }
    } on FirebaseAuthException catch (e) {
      result = e.code;
      return result;
    } on Exception catch (e) {
      result = e.toString();
      return result;
    }
  }
// fin de la classe

}
