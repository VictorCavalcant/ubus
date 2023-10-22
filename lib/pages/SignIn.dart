import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ubus/components/DecorationInput.dart';
import 'package:ubus/components/MySnackBar.dart';
import 'package:ubus/misc/consts.dart';
import 'package:ubus/pages/DriverMapPage.dart';

import 'package:ubus/pages/SignUp.dart';
import 'package:ubus/services/Auth_service.dart';

class SignInPage extends StatefulWidget {
  SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey_SgIn = GlobalKey<FormState>();

  AuthService _auth_Service = AuthService();

  TextEditingController _emailControllerSgIn = TextEditingController();

  TextEditingController _passwordControllerSgIn = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey_SgIn,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/icon_1.png',
                  width: 300,
                ),
                TextFormField(
                  controller: _emailControllerSgIn,
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
                  height: 30,
                ),
                TextFormField(
                  controller: _passwordControllerSgIn,
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
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () {
                      buttonIsClicked_SgIn(context);
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    },
                    child: Text('Entrar')),
                Divider(
                  color: Colors.white,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                    },
                    child: Text(
                      "Novo motorista? Efetue um cadastro para o sistema",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  buttonIsClicked_SgIn(BuildContext context) {
    String email = _emailControllerSgIn.text;
    String password = _passwordControllerSgIn.text;

    if (_formKey_SgIn.currentState!.validate()) {
      _auth_Service
          .logUser(email: email, password: password)
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
