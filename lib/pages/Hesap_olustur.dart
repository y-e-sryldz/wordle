import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wordle/services/firebase_halper.dart';

import 'package:wordle/models/user_model.dart';
import 'package:wordle/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class Hesap_olustur extends StatefulWidget {
  const Hesap_olustur({super.key});

  @override
  State<Hesap_olustur> createState() => _Hesap_olusturState();
}

class _Hesap_olusturState extends State<Hesap_olustur> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? finalFileImage;
  String username = "";
  String password = "";
  String name = "";
  bool BosAlanUyarisiIsim = false; // Boş alan uyarısını gösterme durumu
  bool BosAlanUyarisiSifre = false; // Boş alan uyarısını gösterme durumu
  bool BosAlanUyarisiname = false;

  // validate email method
  bool validateEmail(String username) {
    // Regular expression for email validation
    final RegExp emailRegex =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    // Check if the email matches the regular expression
    return emailRegex.hasMatch(username);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    final authProvider = context.watch<AuthenticationProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "İsim Soyisim",
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
                          name = value;
                          BosAlanUyarisiname = false;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: "E-posta Adresi",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.grey,
                        )),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        } else if (!validateEmail(value)) {
                          return 'Please enter a valid email';
                        } else if (validateEmail(value)) {
                          return null;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        username = value.trim();
                      },
                      style: TextStyle(
                          color: Colors.white), // Yazı rengini beyaz yapar
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
                      controller: _passwordController,
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
                      Container(
                        decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                        child: TextButton(
                          onPressed: () async {
                            if (username.isEmpty || password.isEmpty) {
                              if (username.isEmpty &&
                                  password.isEmpty &&
                                  name.isEmpty) {
                                // Kullanıcı adı ve şifre boşsa, uyarıyı göster.
                                setState(() {
                                  BosAlanUyarisiIsim = true;
                                  BosAlanUyarisiSifre = true;
                                  BosAlanUyarisiname = true;
                                });
                              } else if (username.isEmpty) {
                                setState(() {
                                  BosAlanUyarisiIsim = true;
                                });
                              } else if (password.isEmpty) {
                                setState(() {
                                  BosAlanUyarisiSifre = true;
                                });
                              } else if (name.isEmpty) {
                                setState(() {
                                  BosAlanUyarisiname = true;
                                });
                              }
                            } else {
                              signUpUser();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            child: Text(
                              "Hesap Oluştur",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Geri Dön",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    ],),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // signUp user
  void signUpUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    
      UserCredential? userCredential =
          await authProvider.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );

      if (userCredential != null) {
        // send email verification

        // user has been created - now we save the user to firestore
        print('user crested: ${userCredential.user!.uid}');

        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: username,
          image: '',
          createdAt: '',
          playerRating: 1200,
        );

        authProvider.saveUserDataToFireStore(
          currentUser: userModel,
          fileImage: finalFileImage,
          onSuccess: () async {
            formKey.currentState!.reset();
            // sign out the user and navigate to the login screen
            // so that he may now sign In
            print("Kayıt başarıyla tamamlandı, lütfen giriş yapın");
            await authProvider.signOutUser().whenComplete(() {
              Navigator.pop(context);
            });
          },
          onFail: (error) {
            print(error);
          },
        );
      }
  }
}
