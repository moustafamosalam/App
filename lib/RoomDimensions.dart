
import 'package:flutter/material.dart';
//import 'package:smart_ac/main.dart';
import 'package:smart_ac/mqtt.dart';
import 'package:smart_ac/my_textfield.dart';
import 'package:smart_ac/initConnection.dart';

class RoomDimensions extends StatelessWidget {
  RoomDimensions({super.key});

  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final hpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
          title: const Text('Enter your room dimensions',style: TextStyle(color: Colors.grey),),
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(keyboard: TextInputType.numberWithOptions(decimal: true),controller: lengthController, hintText: 'Enter length', obscureText: false),
                SizedBox(height: 10,),
                MyTextField(keyboard: TextInputType.numberWithOptions(decimal: true),controller: widthController, hintText: 'Enter width', obscureText: false),
                SizedBox(height: 10,),
                MyTextField(keyboard: TextInputType.numberWithOptions(decimal: true),controller: hpController, hintText: 'Enter horsepower', obscureText: false),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
                },
              child: const Text('Cancel',style: TextStyle(color: Colors.white),),
            ),
            TextButton(
              onPressed: () {
                mqttPublish('${BoardIdTopic}In', 'L${lengthController.text}',true);
                mqttPublish('${BoardIdTopic}In', 'W${widthController.text}',true);
                mqttPublish('${BoardIdTopic}In', 'H${hpController.text}',true);
                Navigator.pop(context, 'OK');
                },
              child: const Text('OK',style: TextStyle(color: Colors.grey),),
            ),
          ],
        ),
      ),
      icon: Icon(Icons.settings, color: Colors.grey[400]),
      iconSize: 40.0,
    );
  }
}