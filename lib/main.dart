//import 'dart:html';
import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bottom_picker/bottom_picker.dart';

import 'package:smart_ac/Conf.dart';
import 'package:smart_ac/login_page.dart';
import 'package:smart_ac/mqtt.dart';
import 'package:smart_ac/initConnection.dart';


String temp= 'OFF';
double percent = 0; double screenHeight = 0; //double sizeBox = 0;
String image_1='images/277.jpg';
Color? per_color; Color digitalColor = Colors.grey.shade400;
Color container_color = Colors.grey.shade900;

FutureOr<bool> connect()async{
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return true;
    }
    else{return false;}
  } on SocketException catch (_) {
    print('not connected');
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initPrefs();

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  bool result = await connect();
  if(result){
    initMQTTConnection();
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // initialRoute: ((status[0] == '1')
    //     ?((status[1] == '1') ? '/' :  '/Login' )
    //     :  '/Intro' ),
    initialRoute: ((login_status == '1') ? '/' :  '/Login'),
    routes: {
      '/': (context) => AirConditionerRemote(),
      '/Conf': (context) => Conf(),
      '/Login' : (context) => LoginPage(),
    },
    //home: AirConditionerRemote(),
  ));


  streamLocation(locationSettings);

}


class AirConditionerRemote extends StatefulWidget {
  @override
  _AirConditionerRemoteState createState() => _AirConditionerRemoteState();
}

Widget middle = Image.asset('images/ac.png',color: Colors.grey, height: 200.0, width: 700.0,);

class _AirConditionerRemoteState extends State<AirConditionerRemote> {


   GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

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

     screenHeight = (window.physicalSize.longestSide / window.devicePixelRatio);
     //sizeBox = (15.33 / 100) * screenHeight;

     //tempHumidity();
   }

   void tempHumidity()async{
   bool result = await connect();
   if (result) {
     client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
       final recMess = c![0].payload as MqttPublishMessage;
       final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
       print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');

       print(BoardIdTopic);
       if (c[0].topic == '$BoardIdTopic/ac/temp') {
         setState(() {savePrefs('roomTemp', pt);
           roomTemp = pt;});
       }
       else if (c[0].topic == '$BoardIdTopic/ac/humidity') {
         setState(() {savePrefs('roomHumidity', pt);roomHumidity = pt;});
       }
     });
   }}


  @override
  Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
     // if (temp == 'OFF') {
     //   initMQTTConnection();
     // }
    return Scaffold(
      key: _globalKey,
      drawer: Drawer(
        shape: OutlineInputBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0), topRight: Radius.circular(30.0),)),
        width: (screenWidth*0.7),
        backgroundColor: Colors.grey[900],//Color(0xFF403F4D),
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
              onTap: (){},
              visualDensity: VisualDensity.compact,
            ),
            Divider(
              thickness: 0.5,
              color: Colors.grey[400],
            ),
            ListTile(
              leading: Icon(Icons.account_tree,color: Colors.grey[300],size: 28.0,),
              title: Text('Configuration',style: TextStyle(fontSize: 23.0,color: Colors.grey[300]),),
              onTap: (){
                //Navigator.push(context, MaterialPageRoute(builder: (context)=>Conf()));
                Navigator.popAndPushNamed(context, '/Conf');
                print('Hi');
              },
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
                    print(default_location);
                    def_lat = default_location.latitude.toString();
                    def_lng = default_location.longitude.toString();
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
                  description: 'Recommended: $openTime', descriptionStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.grey.shade400),
                  titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey.shade400),
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
      ),

      backgroundColor: Colors.grey[900],
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(image_1), fit: BoxFit.cover),),
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: (){
                        _globalKey.currentState!.openDrawer();
                      },
                      icon: Icon(Icons.menu, color: Colors.grey[400],),
                      iconSize: 40.0,
                    ),
                    PopupMenuButton(
                      color: Colors.grey[400],
                      icon: Icon(Icons.settings,color: Colors.grey[400],),
                      iconSize: 40.0,
                      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                      itemBuilder: (context)=>[
                        PopupMenuItem(child: ListTile(
                          leading: Icon(Icons.logout,color: Colors.black,size: 28.0,),
                          title: Text('Log out',style: TextStyle(fontSize: 23.0,color: Colors.black, fontWeight: FontWeight.w600),),
                          onTap: ()async{
                            await savePrefs('login', '0'); await savePrefs('username', 'null');
                            middle = Image.asset('images/ac.png',color: Colors.grey, height: 200.0, width: 700.0,);
                            image_1='images/277.jpg'; digitalColor = Colors.grey.shade400;
                            container_color = Colors.grey.shade900;
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                            mqttPublish('${BoardIdTopic}In', 'L',false);
                          },
                          visualDensity: VisualDensity.compact,
                        ),)
                      ],
                    ),
                  ],
                ),
                //SizedBox(height: 133.2,),
                Container(
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          //SizedBox(height: (8.5/100)*screenHeight),//11.5
                          Spacer(),
                          middle,
                          //SizedBox(height: sizeBox),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, right: 15.0,bottom: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text('Room temp',style: TextStyle(fontSize: 15,color: digitalColor),),
                                    Text('$roomTemp',style: TextStyle(fontSize: 65,color: digitalColor,fontFamily: 'Digital')),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Humidity',style: TextStyle(fontSize: 15,color: digitalColor),),
                                    Text('$roomHumidity',style: TextStyle(fontSize: 65,color: digitalColor,fontFamily: 'Digital'),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
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
                              if (wifi) {
                                print(BoardIdTopic);
                                setState(() {
                                  temp = 'OFF'; //sizeBox = (12.33/100)*screenHeight;//15.33
                                  per_color = Colors.white; digitalColor = Colors.grey.shade400;
                                  image_1 = 'images/277.jpg';
                                  container_color = Color(0xFF1C1C1C);
                                  middle = Image.asset(
                                    'images/ac.png', color: Colors.grey,
                                    height: 200.0,
                                    width: 700.0,);

                                });
                                mqttPublish('${BoardIdTopic}In', 'S$OffData,',false);
                              }
                            },
                            icon: Icon(Icons.power_settings_new,color: Colors.red[900],),
                            iconSize: 50.0,
                          ),
                          IconButton(
                            onPressed: () async{
                              wifi = await checkInternetConnectivity();
                              if(wifi) {
                                temp = await getPrefs('warm_temp');
                                if (temp == null) {
                                  QuickAlert.show(
                                      context: context, type: QuickAlertType.warning, text:"Please configure your buttons", title: "Wrong!",
                                      confirmBtnText: "Okay", backgroundColor: Colors.grey.shade800, titleColor: Colors.white, textColor: Colors.white,
                                      confirmBtnColor: Colors.grey.shade500, customAsset: 'images/warning.gif', borderRadius: 40.0
                                  );
                                }
                                else {
                                  temp = temp + '\u1d52C';
                                  setState(() {
                                    percent = 0.75;  //sizeBox = ((5.37/100)*867.43);//10.37
                                    container_color = Color(0xDF1C1C1C);
                                    per_color = Colors.redAccent; digitalColor = Colors.grey.shade400;
                                    temp;
                                    image_1 = 'images/280.jpg';
                                    middle = CircularPercentIndicator(
                                      radius: 250,
                                      lineWidth: 25,
                                      percent: percent,
                                      circularStrokeCap: CircularStrokeCap
                                          .round,
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

                                  });
                                  mqttPublish('${BoardIdTopic}In', 'S$HotData,',false);
                                }
                              }
                            },
                            icon: Icon(Icons.local_fire_department_sharp,color: Colors.red[400],),
                            iconSize: 50.0,
                          ),
                          IconButton(
                            onPressed: () async{
                              wifi = await checkInternetConnectivity();
                              if(wifi) {
                                temp = await getPrefs('cool_temp');
                                if (temp == null) {
                                  QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.warning,
                                      text: "Please configure your buttons",
                                      title: "Wrong!",
                                      confirmBtnText: "Okay",
                                      backgroundColor: Colors.grey.shade800,
                                      titleColor: Colors.white,
                                      textColor: Colors.white,
                                      confirmBtnColor: Colors.grey.shade500,
                                      customAsset: 'images/warning.gif',
                                      borderRadius: 40.0
                                  );
                                }
                                else {
                                  temp = temp + '\u1d52C';
                                  setState(() {
                                    percent = 0.35; //sizeBox = (5.37/100)*screenHeight;//10.37
                                    per_color = Colors.indigo; digitalColor = Colors.black;
                                    container_color = Colors.grey.shade100;
                                    temp;
                                    image_1 = 'images/273.jpg';
                                    middle = CircularPercentIndicator(
                                      radius: 250,
                                      lineWidth: 25,
                                      percent: percent,
                                      circularStrokeCap: CircularStrokeCap
                                          .round,
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

                                  });
                                  mqttPublish('${BoardIdTopic}In', 'S$CoolData,',false);
                                }
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
      )
    );

  }
}

