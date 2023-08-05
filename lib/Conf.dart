import 'dart:async';
import 'dart:io';
//import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:network_info_plus/network_info_plus.dart';


import 'package:smart_ac/mqtt.dart';
import 'package:smart_ac/RoomDimensions.dart';
import 'package:smart_ac/initConnection.dart';

class Conf extends StatefulWidget {
  const Conf({Key? key}) : super(key: key);

  @override
  State<Conf> createState() => _ConfState();

}


String temp= 'OFF';
double percent = 0;
String image_1='images/277.jpg';
Color per_color = Colors.white;
Color container_color = Colors.grey.shade900;
String? _currentvalue;
String? init_temp;

final NetworkInfo _networkInfo = NetworkInfo();
Widget middle = Image.asset('images/ac.png',color: Colors.grey, height: 200.0, width: 700.0,);

GlobalKey<ScaffoldState> _globalKey1 = GlobalKey<ScaffoldState>();

class _ConfState extends State<Conf> {

  FutureOr<bool> checkInternetConnectivity() async{
    bool result = await checkConnectivity();
    if(!result) {
      QuickAlert.show(
          context: context, type: QuickAlertType.warning,
          text: "No internet connection...", title: "Connection!",
          confirmBtnText: "Okay", backgroundColor: Colors.grey.shade900,
          titleColor: Colors.white, textColor: Colors.white,
          confirmBtnColor: Colors.grey.shade500, customAsset: 'images/wif.gif',
          borderRadius: 40.0
      );
      return false;
    }
    else{
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    //()async{await checkConnectivity();};
  }

  @override
  Widget build(BuildContext context) {
    final screenWdith = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _globalKey1,
      drawer: Drawer(
          shape: OutlineInputBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0), topRight: Radius.circular(30.0),)),
          width: (screenWdith*0.7),
          child: ListView(
            children: [
              UserAccountsDrawerHeader(accountName: Text(''),
                accountEmail: Text('Menu',style: TextStyle(fontSize: 34.0,color: Colors.white,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('images/291.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),),
              SizedBox(height: 5.2,),
              ListTile(
                leading: Icon(Icons.home,color: Colors.grey[300],size: 28.0,),
                title: Text('Home',style: TextStyle(fontSize: 23.0,color: Colors.grey[300]),),
                onTap: () async{
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=>AirConditionerRemote()));
                  Navigator.pop(context); Navigator.pop(context);
                },
                visualDensity: VisualDensity.compact,
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey[400],
              ),
              ListTile(
                leading: Icon(Icons.account_tree,color: Colors.grey[300],size: 28.0,),
                title: Text('Configuration',style: TextStyle(fontSize: 23.0,color: Colors.grey[300]),),
                onTap: (){},
                visualDensity: VisualDensity.compact,
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey[400],
              ),
              ListTile(
                leading: Icon(Icons.location_pin,color: Colors.grey[300],size: 28.0,),
                title: Text('Set Location',style: TextStyle(fontSize: 23.0,color: Colors.grey[300]),),
                onTap: (){
                  QuickAlert.show(
                      context: context, type: QuickAlertType.confirm, text:"Set your current location as your default location?",
                      confirmBtnText: "Yes", cancelBtnText: "No", backgroundColor: Colors.grey.shade800, titleColor: Colors.white, textColor: Colors.white,
                      confirmBtnColor: Colors.grey.shade500, customAsset: 'images/confirm.gif', borderRadius: 40.0,
                      onConfirmBtnTap: ()async{
                        Position default_location = await getDistace();
                        savePrefs('def_loc_lat', default_location.latitude.toString());
                        savePrefs('def_loc_lng', default_location.longitude.toString());
                        Navigator.pop(context);
                        QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            text: "Location is saved successfully",
                            title: "Default location!",
                            confirmBtnText: "Okay",
                            backgroundColor: Colors.grey.shade800,
                            titleColor: Colors.white,
                            autoCloseDuration: Duration(seconds: 3),
                            textColor: Colors.white,
                            confirmBtnColor: Colors.grey.shade500,
                            customAsset: 'images/success.gif',
                            borderRadius: 40.0,);
                      }
                  );
                },
                visualDensity: VisualDensity.compact,
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey[400],
              ),
              ListTile(
                leading: Icon(Icons.timer_outlined,color: Colors.grey[300],size: 28.0,),
                title: Text('Time Selection',style: TextStyle(fontSize: 23.0,color: Colors.grey[300]),),
                onTap: (){
                  BottomPicker(
                    items: const [
                      Text('10'), Text('11'), Text('12'), Text('13'), Text('14'), Text('15'), Text('16'), Text('17'),
                      Text('18'), Text('19'), Text('20'),Text('21'), Text('22'), Text('23'),Text('24'), Text('25')
                    ],
                    title: "Time to turn on the ac before arrival",
                    titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey.shade400),
                    backgroundColor: Colors.grey.shade900,
                    gradientColors: const [Color(0xFF3f3f3f), Color(0xFFeeeeee)],
                    pickerTextStyle: TextStyle(color: Colors.grey.shade400, fontSize: 22, fontWeight: FontWeight.bold,),
                    onSubmit: (dynamic time){

                    },
                  ).show(context);
                },
                visualDensity: VisualDensity.compact,
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey[400],
              ),
              SwitchListTile(
                  value: tracking,
                  secondary: Icon(Icons.not_listed_location,color: Colors.grey[300],size: 28.0,),
                  title: Text('Tracking',style: TextStyle(fontSize: 23.0,color: Colors.grey[300]),),
                  activeColor: Colors.green, onChanged: (value){
                setState(() {
                  if(value == true){
                    tracking = true;
                    streamLocation(locationSettings);
                  }
                  else{
                    tracking =false;
                    positionStream!.cancel();
                  }
                  print('saving prefs track');
                  saveBoolPrefs('tracking', value);
                });
              }),
              Divider(
                thickness: 0.5,
                color: Colors.grey[400],
              ),
            ],
          ),
          backgroundColor: Colors.grey[900]//Color(0xFF403F4D),
      ),
      backgroundColor: Colors.lightBlue[900],
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(image_1), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: (){
                        _globalKey1.currentState!.openDrawer();
                      },
                      icon: Icon(Icons.menu, color: Colors.grey[400],),
                      iconSize: 40.0,
                    ),
                    //SizedBox(width: 62,),
                    Text("Configuration",style: TextStyle(
                      color: Colors.grey,
                      //fontWeight: FontWeight.bold,
                      fontSize: 32,
                    )),
                    RoomDimensions()
                  ],
                ),
                //SizedBox(height: 133.2,),
                Container(
                    child: middle
                ),
                //SizedBox(height: 128.2,),
                Container(
                  decoration: BoxDecoration(color: container_color, borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0),topRight: Radius.circular(40.0))) ,
                  height: screenHeight*0.29,
                  //width: 500.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () async{
                              wifi = await checkInternetConnectivity();
                              if(wifi) {
                                setState(() {
                                  temp = 'OFF';
                                  per_color = Colors.white;
                                  image_1 = 'images/277.jpg';
                                  container_color = Colors.grey.shade900;
                                  middle = Image.asset(
                                    'images/ac.png', color: Colors.grey,
                                    height: 200.0,
                                    width: 700.0,);
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    text: "Waiting the user to send data ...",
                                    title: "Loading",
                                    confirmBtnText: 'Cancel',
                                    onConfirmBtnTap: () {
                                      Navigator.pop(context);
                                      mqttPublish('${BoardIdTopic}In', 'C',false);
                                    },
                                    customAsset: 'images/custom.gif',
                                    borderRadius: 40.0,
                                  );
                                  mqttPublish('${BoardIdTopic}In', 'R1${username},',false);
                                  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
                                    final recMess = c![0].payload as MqttPublishMessage;
                                    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                                    if (c[0].topic == '${BoardIdTopic}/${username}/Out1') {
                                      OffData  = pt;
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.confirm,
                                          text: "Button data is sent successfully",
                                          title: "Data sent!",
                                          confirmBtnText: "Save",
                                          cancelBtnText: "Test",
                                          backgroundColor: Colors.grey.shade800,
                                          titleColor: Colors.white,
                                          textColor: Colors.white,
                                          confirmBtnColor: Colors.grey.shade500,
                                          customAsset: 'images/success.gif',
                                          borderRadius: 40.0,
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                          },
                                          onCancelBtnTap: () {
                                            mqttPublish('${BoardIdTopic}In', 'S$OffData,',false);
                                          }
                                      );
                                      //client.unsubscribe('${usernameTopic}Out1');
                                    }
                                  });
                                });
                              }
                            },
                            icon: Icon(Icons.power_settings_new,color: Colors.red[900],),
                            iconSize: 50.0,
                          ),
                          IconButton(
                            onPressed: () async{
                              wifi = await checkInternetConnectivity();
                              if(wifi) {
                                init_temp = await getPrefs('warm_temp');
                                setState(() {
                                  percent = 0.75;
                                  container_color = Color(0xDF1C1C1C);
                                  per_color = Colors.redAccent;
                                  temp = '$init_temp\u1d52C';
                                  image_1 = 'images/280.jpg';
                                  middle = CircularPercentIndicator(
                                    radius: 250,
                                    lineWidth: 25,
                                    percent: percent,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    animation: true,
                                    animationDuration: 1000,
                                    backgroundColor: Colors.grey.shade800,

                                    linearGradient: LinearGradient(
                                        colors: [Colors.red, Colors.blue]),
                                    center: Text(temp, style: TextStyle(
                                        fontSize: 55,
                                        fontWeight: FontWeight.w700,
                                        color: per_color),),
                                  );
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    text: "Waiting the user to send data ...",
                                    title: "Loading",
                                    confirmBtnText: 'Cancel',
                                    onConfirmBtnTap: () {
                                      Navigator.pop(context);
                                      mqttPublish('${BoardIdTopic}In', 'C',false);
                                    },
                                    customAsset: 'images/custom.gif',
                                    borderRadius: 40.0,
                                  );
                                  mqttPublish('${BoardIdTopic}In', 'R2${username},',false);
                                  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
                                    final recMess = c![0].payload as MqttPublishMessage;
                                    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                                    if (c[0].topic == '${BoardIdTopic}/${username}/Out2') {
                                      HotData  = pt;
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.confirm,
                                          text: "Button data is sent successfully",
                                          title: "Data sent!",
                                          confirmBtnText: "Save",
                                          cancelBtnText: "Test",
                                          backgroundColor: Colors.grey.shade800,
                                          titleColor: Colors.white,
                                          textColor: Colors.white,
                                          confirmBtnColor: Colors.grey.shade500,
                                          customAsset: 'images/success.gif',
                                          borderRadius: 40.0,
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                            BottomPicker(
                                              items: [
                                                Text('16'),
                                                Text('17'),
                                                Text('18'),
                                                Text('19'),
                                                Text('20'),
                                                Text('21'),
                                                Text('22'),
                                                Text('23'),
                                                Text('24'),
                                                Text('25'),
                                                Text('26'),
                                                Text('27'),
                                                Text('28'),
                                                Text('29'),
                                                Text('30'),
                                                Text('31'),
                                                Text('32'),
                                                Text('33')
                                              ],
                                              title: "Choose your warm temperature",
                                              titleStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 21,
                                                  color: Colors.grey.shade400),
                                              backgroundColor: Colors.grey
                                                  .shade900,
                                              //bottomPickerTheme: BottomPickerTheme.plumPlate,
                                              gradientColors: [
                                                Color(0xFF3f3f3f),
                                                Color(0xFFeeeeee)
                                              ],
                                              pickerTextStyle: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              onSubmit: (
                                                  dynamic warm_temp) async {
                                                print(warm_temp + 16);
                                                _currentvalue =
                                                    (warm_temp + 16).toString();
                                                await savePrefs('warm_temp',
                                                    (warm_temp + 16)
                                                        .toString());
                                                mqttPublish('${BoardIdTopic}warmTemp', (warm_temp + 16).toString(), true);
                                                setState(() {
                                                  temp =
                                                  '$_currentvalue\u1d52C';
                                                  middle =
                                                      CircularPercentIndicator(
                                                        radius: 250,
                                                        lineWidth: 25,
                                                        percent: percent,
                                                        circularStrokeCap: CircularStrokeCap
                                                            .round,
                                                        animation: true,
                                                        animationDuration: 1000,
                                                        backgroundColor: Colors
                                                            .grey.shade800,

                                                        linearGradient: LinearGradient(
                                                            colors: [
                                                              Colors.red,
                                                              Colors.blue
                                                            ]),
                                                        center: Text(temp,
                                                          style: TextStyle(
                                                              fontSize: 55,
                                                              fontWeight: FontWeight
                                                                  .w700,
                                                              color: per_color),),
                                                      );
                                                });
                                              },
                                            ).show(context);
                                          },
                                          onCancelBtnTap: () {
                                            mqttPublish('${BoardIdTopic}In', 'S$HotData,',false);
                                          }
                                      );
                                      client.unsubscribe('${BoardIdTopic}/${username}/Out2');
                                    }
                                  });
                                });
                              }
                            },
                            icon: Icon(Icons.local_fire_department_sharp,color: Colors.red[400],),
                            iconSize: 50.0,
                          ),
                          IconButton(
                            onPressed: () async{
                              wifi = await checkInternetConnectivity();
                              if(wifi) {
                                init_temp = await getPrefs('cool_temp');
                                setState(() {
                                  percent = 0.35; per_color = Colors.indigo;
                                  container_color = Colors.grey.shade100;
                                  temp = '$init_temp\u1d52C'; image_1 = 'images/273.jpg';
                                  middle = CircularPercentIndicator(
                                    radius: 250,
                                    lineWidth: 25,
                                    percent: percent,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    animation: true,
                                    animationDuration: 1000,
                                    backgroundColor: Colors.white,
                                    linearGradient: LinearGradient(
                                        colors: [Colors.red, Colors.blue]),
                                    center: Text(temp, style: TextStyle(
                                        fontSize: 55,
                                        fontWeight: FontWeight.w700,
                                        color: per_color),),
                                  );
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    text: "Waiting the user to send data ...",
                                    title: "Loading",
                                    confirmBtnText: 'Cancel',
                                    onConfirmBtnTap: () {
                                      mqttPublish('${BoardIdTopic}In', 'C',false);
                                      Navigator.pop(context);
                                    },
                                    customAsset: 'images/custom.gif',
                                  );
                                  mqttPublish('${BoardIdTopic}In', 'R3${username},',false);
                                  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
                                    final recMess = c![0].payload as MqttPublishMessage;
                                    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                                    if (c[0].topic == '${BoardIdTopic}/${username}/Out3') {
                                      CoolData  = pt;
                                      Navigator.pop(context);
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.confirm,
                                          text: "Button data is sent successfully",
                                          title: "Data sent!",
                                          confirmBtnText: "Save",
                                          cancelBtnText: "Test",
                                          backgroundColor: Colors.grey.shade800,
                                          titleColor: Colors.white,
                                          textColor: Colors.white,
                                          confirmBtnColor: Colors.grey.shade500,
                                          customAsset: 'images/success.gif',
                                          borderRadius: 40.0,
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                            BottomPicker(
                                              items: [
                                                Text('16'),
                                                Text('17'),
                                                Text('18'),
                                                Text('19'),
                                                Text('20'),
                                                Text('21'),
                                                Text('22'),
                                                Text('23'),
                                                Text('24'),
                                                Text('25'),
                                                Text('26'),
                                                Text('27'),
                                                Text('28'),
                                                Text('29'),
                                                Text('30'),
                                                Text('31'),
                                                Text('32'),
                                                Text('33')
                                              ],
                                              title: "Choose your warm temperature",
                                              titleStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 21,
                                                  color: Colors.grey.shade400),
                                              backgroundColor: Colors.grey
                                                  .shade900,
                                              //bottomPickerTheme: BottomPickerTheme.plumPlate,
                                              gradientColors: [
                                                Color(0xFF3f3f3f),
                                                Color(0xFFeeeeee)
                                              ],
                                              pickerTextStyle: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              onSubmit: (
                                                  dynamic warm_temp) async {
                                                print(warm_temp + 16);
                                                _currentvalue =
                                                    (warm_temp + 16).toString();
                                                await savePrefs('warm_temp',
                                                    (warm_temp + 16)
                                                        .toString());
                                                mqttPublish('${BoardIdTopic}warmTemp', (warm_temp + 16).toString(), true);
                                                setState(() {
                                                  temp =
                                                  '$_currentvalue\u1d52C';
                                                  middle =
                                                      CircularPercentIndicator(
                                                        radius: 250,
                                                        lineWidth: 25,
                                                        percent: percent,
                                                        circularStrokeCap: CircularStrokeCap
                                                            .round,
                                                        animation: true,
                                                        animationDuration: 1000,
                                                        backgroundColor: Colors
                                                            .grey.shade800,

                                                        linearGradient: LinearGradient(
                                                            colors: [
                                                              Colors.red,
                                                              Colors.blue
                                                            ]),
                                                        center: Text(temp,
                                                          style: TextStyle(
                                                              fontSize: 55,
                                                              fontWeight: FontWeight
                                                                  .w700,
                                                              color: per_color),),
                                                      );
                                                });
                                              },
                                            ).show(context);
                                          },
                                          onCancelBtnTap: () {
                                            mqttPublish('${BoardIdTopic}In', 'S$CoolData,',false);
                                          }
                                      );
                                      client.unsubscribe('${BoardIdTopic}/${username}/Out3');
                                    }
                                  });
                                });
                              }
                            },
                            icon: Icon(Icons.ac_unit_sharp,color: Colors.blue,),
                            iconSize: 50.0,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '  OFF',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900]
                            ),
                          ),
                          Text(
                            '   WARM',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400]
                            ),
                          ),
                          Text(
                            '  COOL',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

