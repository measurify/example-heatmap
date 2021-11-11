import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_heatmap/globals.dart';
import 'package:http/http.dart';

import 'loading.dart';

class LoginPage extends StatefulWidget
{
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  static String _username;
  static String _password;
  static String _tenant;
  bool _obscuredPassword = true;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: SizedBox.expand(
            child: SingleChildScrollView(
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10, height: 200),
                  SizedBox(width: 300, child:
                    TextFormField(
                      decoration: InputDecoration(
                        suffixIcon:  IconButton(
                          icon: const Icon(Icons.person),
                          onPressed: () => {},
                        ),
                        border: const OutlineInputBorder(),
                        labelText: "username"
                      ),
                      onSaved: (value) => _username = value,
                    )
                  ),
                  const SizedBox(width: 10, height: 20),
                  SizedBox(width: 300, child:
                    TextFormField(
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(_obscuredPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: _togglePasswordObscured,
                        ),
                        border: const OutlineInputBorder(),
                        labelText: "password"
                      ),
                      onSaved: (value) => _password = value,
                      obscureText: _obscuredPassword,
                    )
                  ),
                  const SizedBox(width: 10, height: 20),
                  SizedBox(width: 300, child:
                    TextFormField(
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.business),
                            onPressed: _togglePasswordObscured,
                          ),
                          border: const OutlineInputBorder(),
                          labelText: "tenant"
                      ),
                      onSaved: (value) => _tenant = value,
                    )
                  ),
                  const SizedBox(width: 10, height: 40),
                  ElevatedButton(
                    child: const Text("Login", style: TextStyle(fontSize: 18),),
                    onPressed: ()
                    {
                      if(_key.currentState.validate()) {
                        _key.currentState.save();
                        attemptLogin().then((isLoggedIn) {
                          if (isLoggedIn)
                          {
                            // Pops the login page because it is useless at this point,
                            // Then, first pushes the dashboard and then the loading page.
                            // So that when it finishes loadings, the dashboard is shown.
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/dashboard");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadingPage()));
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Could not login!"))
                            );
                          }
                        });
                      }
                    }
                  )
                ],
              )
            )
          )
        ),
      )
    );
  }

  void _togglePasswordObscured()
  {
    setState(() {
      _obscuredPassword = !_obscuredPassword;
    });
  }

  static Future<bool> attemptLogin() async
  {
    Response response = await post(
        Uri.parse('https://students.atmosphere.tools/v1/login'),
        body: {
          "username" : _username, //"heatmap-user-username",
          "password" : _password, //"heatmap-user-password",
          "tenant": _tenant, //"measurify-heatmap"
        }
    );

    if(response.statusCode != 200) {
      return false;
    }

    Map body = jsonDecode(response.body);
    Globals.measurifyToken = body["token"];

    return true;
  }
}
