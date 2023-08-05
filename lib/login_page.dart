import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_ac/main.dart';
import 'package:smart_ac/Conf.dart';
import 'package:smart_ac/my_button.dart';
import 'package:smart_ac/my_textfield.dart';
import 'package:smart_ac/initConnection.dart';

import 'package:http/http.dart'as http;
import 'package:quickalert/quickalert.dart';



FutureOr postRequest() async{
  //var url = Uri.https('10.0.2.17', '/SAVE');
  var response = await http.get(Uri.parse('http://192.168.2.1/SAVE?ssid=$ssid&pass=$password&username=$BoardId'));
  print('Response status: ${response.statusCode}');
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  final BoardIdController = TextEditingController();
  final usernameController = TextEditingController();

  // sign user in method


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),

                  Text(
                    'Connect to IR-Blaster wifi then :',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // logo
                  const Icon(
                    Icons.wifi,
                    size: 90,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 30),

                  // welcome back, you've been missed!
                  Text(
                    'Enter your wifi SSID and Password',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // username textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: MyTextField(
                      keyboard: TextInputType.text,
                      controller: ssidController,
                      hintText: 'SSID',
                      obscureText: false,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: MyTextField(
                      keyboard: TextInputType.text,
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // welcome back, you've been missed!
                  Text(
                    'Enter the Board Id and Username',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:25.0),
                    child: MyTextField(
                      keyboard: TextInputType.text,
                      controller: BoardIdController,
                      hintText: 'Board ID',
                      obscureText: false,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:25.0),
                    child: MyTextField(
                      keyboard: TextInputType.text,
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // sign in button
                  MyButton(
                    onTap: () async{
                      username = usernameController.text;
                      ssid = ssidController.text;
                      password = passwordController.text;
                      BoardId = BoardIdController.text;
                      await savePrefs('username', username);
                      await savePrefs('BoardId', BoardId);
                      BoardIdTopic = BoardId;
                      print(BoardIdTopic);
                      log_in_state = 1;
                      postRequest();
                      print(ssid);
                      if((username == '' || BoardId == '')){
                        QuickAlert.show(
                            context: context, type: QuickAlertType.warning, text:"Please fill the username section", title: "Wrong!",
                            confirmBtnText: "Okay", backgroundColor: Colors.grey.shade800, titleColor: Colors.white, textColor: Colors.white,
                            confirmBtnColor: Colors.grey.shade500, customAsset: 'images/warning.gif', borderRadius: 40.0
                        );
                      }
                      else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AirConditionerRemote()));
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Conf()));
                        await savePrefs('login', '1');
                      }
                      },
                  ),

                  const SizedBox(height: 20),

                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Thank you',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        Flexible(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}