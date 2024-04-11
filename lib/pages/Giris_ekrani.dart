import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordle/constants/words.dart';
import 'package:wordle/pages/Hesap_olustur.dart';
import 'package:wordle/pages/Oyun_ekrani.dart';
import 'package:wordle/pages/odalar.dart';
import 'package:wordle/providers/authentication_provider.dart';

import 'package:provider/provider.dart';

class Giris_ekrani extends StatefulWidget {
  const Giris_ekrani({super.key});

  @override
  State<Giris_ekrani> createState() => _Giris_ekraniState();
}

class _Giris_ekraniState extends State<Giris_ekrani> {
  String username = "";
  String password = "";
  bool BosAlanUyarisiIsim = false; // Boş alan uyarısını gösterme durumu
  bool BosAlanUyarisiSifre = false; // Boş alan uyarısını gösterme durumu

  final FirebaseAuth _auth = FirebaseAuth.instance;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // signIn user
  void signInUser() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserCredential? userCredential =
        await authProvider.signInUserWithEmailAndPassword(
      email: username,
      password: password,
    );

    if (userCredential != null) {
      // 1. check if this user exist in firestore
      bool userExist = await authProvider.checkUserExist();

      if (userExist) {
        // 2. get user data from firestore
        await authProvider.getUserDataFromFireStore();

        // 3. save user data to shared preferenced - local storage
        await authProvider.saveUserDataToSharedPref();

        // 4. save this user as signed in
        await authProvider.setSignedIn();

        authProvider.setIsLoading(value: false);

        // 5. navigate to home screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Odalar(
                    isCustomTime: true,
                  )),
        );
      }
    } else {
      print("Lütfen tüm alanları doldurun");
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff21254A),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height * .25,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/baslik.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Merhaba,\nHoşgeldiniz",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "E-posta Adresi",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey,
                        )),
                      ),
                      style: TextStyle(
                          color: Colors.white), // Yazı rengini beyaz yapar
                      onChanged: (value) {
                        setState(() {
                          username = value;
                          BosAlanUyarisiIsim = false;
                        });
                      },
                    ),
                    if (BosAlanUyarisiIsim) // Boş alan uyarısı gösteriliyor mu?
                      Text(
                        "Lütfen bütün boşlukları doldurunuz.",
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Şifre",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey,
                        )),
                      ),
                      style: TextStyle(
                          color: Colors.white), // Yazı rengini beyaz yapar
                      onChanged: (value) {
                        setState(() {
                          password = value;
                          BosAlanUyarisiSifre = false;
                        });
                      },
                      obscureText:
                          true, // Şifreyi noktalı karakterlerle göstermek için
                    ),
                    if (BosAlanUyarisiSifre) // Boş alan uyarısı gösteriliyor mu?
                      Text(
                        "Lütfen bütün boşlukları doldurunuz.",
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              if (username.isEmpty && password.isEmpty) {
                                // Kullanıcı adı veya şifre boşsa, uyarıyı göster.
                                setState(() {
                                  BosAlanUyarisiIsim = true;
                                  BosAlanUyarisiSifre = true;
                                });
                              } else if (username.isEmpty) {
                                setState(() {
                                  BosAlanUyarisiIsim = true;
                                });
                              } else if (password.isEmpty) {
                                setState(() {
                                  BosAlanUyarisiSifre = true;
                                });
                              } else {
                                signInUser();
                                
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 40),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                "Giriş Yap",
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Hesap_olustur()),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 40),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                "Hesap Oluştur",
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
