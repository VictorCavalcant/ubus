import 'package:flutter/material.dart';
import 'package:ubus/components/DecorationInput.dart';
import 'package:ubus/components/MySnackBar.dart';
import 'package:ubus/misc/consts.dart';
import 'package:ubus/pages/DriverMapPage.dart';
import 'package:ubus/pages/SignIn.dart';
import 'package:ubus/services/Auth_service.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  TextEditingController _emailControllerSgUp = TextEditingController();
  TextEditingController _passwordControllerSgUp = TextEditingController();
  TextEditingController _nameControllerSgUp = TextEditingController();

  final _formKey_SgUp = GlobalKey<FormState>();

  AuthService _auth_Service = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey_SgUp,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/icon_1.png',
                  width: 300,
                ),
                TextFormField(
                    controller: _nameControllerSgUp,
                    decoration: getInputDecoration('Nome'),
                    validator: (String? value) {
                      if (value == null) {
                        return "O nome não pode ser vazio";
                      }
                      if (value.length < 4) {
                        return "O nome é muito curto";
                      }
                      return null;
                    }),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailControllerSgUp,
                  decoration: getInputDecoration('E-mail'),
                  validator: (String? value) {
                    if (value == null) {
                      return "O e-mail não pode ser vazio";
                    }
                    if (value.length < 5) {
                      return "O e-mail é muito curto";
                    }
                    if (!value.contains("@")) {
                      return null;
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordControllerSgUp,
                  decoration: getInputDecoration('Senha'),
                  validator: (String? value) {
                    if (value == null) {
                      return "A senha não pode ser retornada vazia";
                    }
                    if (value.length < 5) {
                      return "A senha é muito curta";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: getInputDecoration('Confirme a senha'),
                  validator: (String? value) {
                    if (value == null) {
                      return "A senha não pode ser retornada vazia";
                    }
                    if (value != _passwordControllerSgUp.text) {
                      return "As senhas não estão iguais!";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      buttonIsClicked_SgUp(context);
                    },
                    child: Text('Enviar Cadastro')),
                Divider(),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInPage()));
                    },
                    child: Text(
                      "Já tem conta? Efetue o login",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  buttonIsClicked_SgUp(BuildContext context) {
    String name = _nameControllerSgUp.text;
    String password = _passwordControllerSgUp.text;
    String email = _emailControllerSgUp.text;
    if (_formKey_SgUp.currentState!.validate()) {
      _auth_Service
          .registerUser(name: name, password: password, email: email)
          .then((String? error) {
        if (error != null) {
          showSnackBar(context: context, text: error);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DriverMapPage(),
            ),
          );
        }
      });
    } else {
      print("Form invalid");
    }
  }
}
