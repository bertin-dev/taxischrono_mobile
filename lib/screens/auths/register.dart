import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:logger/logger.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taxischrono/modeles/applicationuser/appliactionuser.dart';
import 'package:taxischrono/screens/composants/delayed_animation.dart';
import 'package:taxischrono/varibles/variables.dart';

import 'login_number.dart';
import 'otppage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // les variables  var _obscureText = true;
  bool _obscureconfirm = true;

  bool _obscureText = true;

  TextEditingController controllerNom = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerAdresse = TextEditingController();
  TextEditingController controllerPasse = TextEditingController();
  TextEditingController controllerConf = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loader = false;
  final keyscafold = GlobalKey<ScaffoldState>();
  PhoneNumber? numberSubmited;
  //  le debu du corps
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: keyscafold,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: loader
          ? const LoadingComponen()
          : SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DelayedAnimation(
                            delay: 1500,
                            child: Text(
                              "Formulaire d'enregistrement",
                              style: GoogleFonts.poppins(
                                color: dredColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          DelayedAnimation(
                            delay: 2500,
                            child: Text(
                              "  Enregistrez vous et commencer a profiter de nos différents packages et disponibilités pour vos multiples déplacements.",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    signupForm(),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      child: DelayedAnimation(
                        delay: 5500,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                shape: const StadiumBorder(),
                                backgroundColor: dredColor,
                                padding: const EdgeInsets.symmetric(
                                  // horizontal: 125,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'INSCRIPTION',
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4),
                              ),
                              onPressed: () async {
                                await userRegister();
                                loader = false;
                                setState(() {});
                              }),
                        ),
                      ),
                    ),
                    spacerHeight(10),
                    DelayedAnimation(
                      delay: 5500,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: dredColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'J\'ai déjà un compte? Connexion',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: DelayedAnimation(
                          delay: 6500,
                          child: Text(
                            "Retour",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    spacerHeight(15),
                  ],
                ),
              ),
            ),
    );
  }

  Widget signupForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // renseigne le nom
          DelayedAnimation(
            delay: 3500,
            child: TextFormField(
              style: police,
              controller: controllerNom,
              validator: (val) {
                return val == null
                    ? "Le nom est obligatoir"
                    : val.length < 3
                        ? "Entrer un nom valide"
                        : null;
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.person),
                hintStyle: police,
                labelText: 'Votre Nom',
                labelStyle: TextStyle(
                  color: grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Numéro de téléphone
          DelayedAnimation(
            delay: 3500,
            child: InternationalPhoneNumberInput(
              onInputChanged: (number) {
                setState(() {
                  numberSubmited = number;
                });
              },
              textStyle: police,
              validator: (val) {
                return numberSubmited!.phoneNumber == null
                    ? "le numéro de téléphone est obligatoire"
                    : numberSubmited!.phoneNumber!.length < 13
                        ? "entrez un numéro de téléphone valide"
                        : null;
              },
              hintText: "Votre Numéro de téléphone",
              inputBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: grey!),
              ),
              maxLength: 13,
              initialValue: PhoneNumber(isoCode: "CM"),
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // email
          DelayedAnimation(
            delay: 3500,
            child: TextFormField(
              controller: controllerEmail,
              validator: (val) {
                return val == null
                    ? "L'email est obligatoire"
                    : !isEmail(val)
                        ? "Entrer une adresse email valide"
                        : null;
              },
              style: police,
              decoration: InputDecoration(
                icon: const Icon(Icons.email),
                hintStyle: police,
                labelText: 'Votre e-mail',
                labelStyle: TextStyle(
                  color: grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // adresse
          DelayedAnimation(
            delay: 3500,
            child: TextFormField(
              style: police,
              controller: controllerAdresse,
              validator: (val) {
                return val == null
                    ? "renseignez votre adresse"
                    : val.length < 3
                        ? "Entrer une adresse valide"
                        : null;
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.person_pin_circle),
                hintStyle: police,
                labelText: 'Votre Adresse',
                hintText: "Odza",
                labelStyle: police.copyWith(color: grey),
              ),
            ),
          ),
          const SizedBox(height: 10),

          //mot de passe
          DelayedAnimation(
            delay: 4500,
            child: TextFormField(
              obscureText: _obscureText,
              controller: controllerPasse,
              validator: (val) {
                return val == null
                    ? "Le nom est obligatoir"
                    : val.length < 6
                        ? "le mot de passe doit avoir 6 caractères"
                        : null;
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.security),
                labelStyle: police.copyWith(color: grey),
                labelText: 'Mot de passe',
                suffix: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // confirmer le le mot de passe
          DelayedAnimation(
            delay: 4500,
            child: TextFormField(
              obscureText: _obscureconfirm,
              controller: controllerConf,
              validator: (val) {
                return val == null
                    ? "confirmer le mot de passe"
                    : val != controllerPasse.text
                        ? "le mot de passe ne corespond pas"
                        : null;
              },
              style: police,
              decoration: InputDecoration(
                icon: const Icon(Icons.security),
                hintStyle: police,
                labelStyle: police.copyWith(color: grey),
                labelText: 'Confirmer le Mot de passe',
                suffix: IconButton(
                  icon: Icon(
                    _obscureconfirm ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureconfirm = !_obscureconfirm;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future userRegister() async {
    if (formKey.currentState!.validate() && numberSubmited != null) {
      loader = true;
      setState(() {});
      await ApplicationUser.userExist(
              userEmail: controllerEmail.text,
              userPhonNumber: numberSubmited!.phoneNumber)
          .then((value) async {
        if (value) {
          loader = false;
          setState(() {});
          setState(() {
            FocusScope.of(keyscafold.currentContext!).unfocus();
          });
          /*keyscafold.currentState!.showBottomSheet((context) {
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
                    Text(
                        "Un utilisateur ayant votre numéro de téléphone ou votre email existe déjà",
                        style: police.copyWith(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    spacerHeight(30),
                    boutonText(
                        context: context,
                        action: () {
                          Navigator.of(context).pushReplacement(
                            PageTransition(
                                child: const LoginNumber(),
                                type: PageTransitionType.leftToRight),
                          );
                        },
                        text: "Connectez vous ??"),
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
          });*/
        } else {
          ApplicationUser chauffeur = ApplicationUser(
            userAdresse: controllerAdresse.text,
            userEmail: controllerEmail.text,
            userName: controllerNom.text,
            userTelephone: numberSubmited!.phoneNumber,
            motDePasse: controllerPasse.text,
          );
          Logger().i(chauffeur.toJson());
          await ApplicationUser.loginNumber(
            chauffeur,
            context: context,
            onCodeSend: (verificationId, forceResendingToken) {
              Navigator.of(context).push(
                PageTransition(
                  child: OtpPage(
                    utilisateur: chauffeur,
                    verificationId: verificationId,
                    isauthentication: false,
                  ),
                  type: PageTransitionType.leftToRight,
                ),
              );
            },
          );

          loader = false;
          setState(() {});
        }
      });
    }
  }
}
