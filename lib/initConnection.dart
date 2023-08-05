import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;



import 'package:smart_ac/mqtt.dart';
//import 'package:smart_ac/main.dart';

late LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter:1,
    forceLocationManager: true,
    intervalDuration: const Duration(seconds: 1),
    //(Optional) Set foreground notification config to keep the app alive
    //when going to the background
    foregroundNotificationConfig: ForegroundNotificationConfig(notificationTitle: '', notificationText: '')
);

var BoardIdTopic; var def_lat; var def_lng; var password; var log_in_state; var username; var ssid; var BoardId;
bool tracking = true; bool wifi = false;
double actualTime=0;
String? login_status; String roomTemp = '0'; String roomHumidity = '0'; String? openTime; String? OffData; String? CoolData; String? HotData;
Position? currentPosition;
StreamSubscription<Position>? positionStream;


FutureOr<Position> getDistace() async{
  await Geolocator.checkPermission();
  await Geolocator.requestPermission();
  Position _currentUserPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  return _currentUserPosition;
}

saveBoolPrefs(String key,bool val)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, val);
}

FutureOr getBoolPrefs(String key)async{
SharedPreferences prefs = await SharedPreferences.getInstance();
return prefs.getBool('tracking');
}

savePrefs(String key,String val)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, val);
}
FutureOr getPrefs(String key2)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key2);
}


void CallbackFunctionMQTT(){
  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {

    final recMess = c![0].payload as MqttPublishMessage;
    final pt =MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');

    if (c[0].topic == '${BoardIdTopic}openTime') {
      savePrefs('openTime', pt);
      openTime  = pt;
    }

    else if (c[0].topic == '${BoardIdTopic}warmTemp') {
      savePrefs('warm_temp', pt);
    }

    else if (c[0].topic == '${BoardIdTopic}coolTemp') {
      savePrefs('cool_temp', pt);
    }
    else if (c[0].topic == '${BoardIdTopic}/${username}/Out1') {
      OffData = pt;
    }
    else if (c[0].topic == '${BoardIdTopic}/${username}/Out2') {
      HotData = pt;
    }
    else if (c[0].topic == '${BoardIdTopic}/${username}/Out3') {
      CoolData = pt;
    }
    else if (c[0].topic == '$BoardIdTopic/ac/temp') {
      savePrefs('roomTemp', pt);
      roomTemp = pt;
    }
    else if (c[0].topic == '$BoardIdTopic/ac/humidity') {
      savePrefs('roomHumidity', pt);
      roomHumidity = pt;
    }
  });
}

void initMQTTConnection() async{

  await mqttConnect();

  mqttSubscribe('${BoardIdTopic}warmTemp');

  mqttSubscribe('${BoardIdTopic}coolTemp');

  mqttSubscribe('${BoardIdTopic}openTime');

  mqttSubscribe('$BoardIdTopic/$username/Out1');

  mqttSubscribe('$BoardIdTopic/$username/Out2');

  mqttSubscribe('$BoardIdTopic/$username/Out3');
  CallbackFunctionMQTT();

}

void initPrefs() async{
  login_status = await getPrefs('login');
  //final intro = await getPrefs('intro');
  //var arr = login_status;
  BoardIdTopic = await getPrefs('BoardId');
  username = await getPrefs('username');
  def_lat = await getPrefs('def_loc_lat');
  def_lng = await getPrefs('def_loc_lng');
  tracking = await getBoolPrefs('tracking'); if(tracking == null){tracking = true;}
  roomTemp = await getPrefs('roomTemp');if(roomTemp == null){roomTemp = '0';}
  roomHumidity = await getPrefs('roomHumidity'); if(roomHumidity == null){roomHumidity = '0';}

  // return login_status;
}

void requestMapBox() async{
  double desiredTime = 10;
  //get my current location and stop streaming and checks it after 5 min
  positionStream!.pause();
  print('waiting 2 minutes');
  await Timer(const Duration(minutes: 2), () async {
    Position comparedPosition = await getDistace();
    double distance = Geolocator.distanceBetween(currentPosition!.latitude, currentPosition!.longitude, comparedPosition.latitude, comparedPosition.longitude);
    //if changed around 200 m --> moving
    if(distance > 200){
      //checking if the user entered his desired region
      //Request the actual time
      actualTime = await durationCalculation(comparedPosition.longitude.toString(), comparedPosition.latitude.toString(), def_lng, def_lat);
      if(actualTime <= desiredTime){
        print('Inside desired region');
        double time1 = actualTime;
        //checks again that the time decreases
        print('waiting 2 minutes');
        await Timer(const Duration(minutes: 2), () async{
          currentPosition = await getDistace();
          actualTime = await durationCalculation(currentPosition!.longitude.toString(), currentPosition!.latitude.toString(), def_lng, def_lat);
          if(actualTime<time1){
            print('Turn on the ac');
          }
          else{
            print('Leaving the area');
            positionStream!.resume();
          }
        });
      }

      //Outside his desired region
      else{
        print('Outside desired region');
        double waitTime = actualTime - desiredTime;
        print('waiting $waitTime minutes');
        //Timer waits for waitTime and checks again the actualTime
        await Timer(Duration(minutes: waitTime.toInt()), () async{
          print('requesting actual time');
          currentPosition = await getDistace();
          actualTime = await durationCalculation(currentPosition!.longitude.toString(), currentPosition!.latitude.toString(), def_lng, def_lat);
          if(actualTime <= desiredTime){
            openAc(actualTime);
          }
          else{
            print('waiting 2 minutes');
            await Timer(const Duration(minutes: 2), ()async{
              //Request for the last time
              currentPosition = await getDistace();
              actualTime = await durationCalculation(currentPosition!.longitude.toString(), currentPosition!.latitude.toString(), def_lng, def_lat);
              if(actualTime <= desiredTime){
                openAc(actualTime);
              }
              else{
                positionStream!.resume();
              }
            });
          }
        });

      }
   }
    else{
      //start streaming
      print('Not moving');
      positionStream!.resume();
    }
  });
}


void streamLocation(LocationSettings location_Settings){
  print('streaming');
   positionStream = Geolocator.getPositionStream(locationSettings: location_Settings).listen(
          (Position? position) {
            print('inn');
        if(position == null){ print( 'Unknown');}
        else{
          double distance = Geolocator.distanceBetween(position.latitude, position.longitude, double.parse(def_lat), double.parse(def_lng));
          print(distance/1000);
          if((distance/1000) > 0.5){
            print('Outside home region');
            currentPosition = position;
            requestMapBox();
          }
          else {
            print('At Home');
          }
        }
      });
}

FutureOr<double> durationCalculation(String sourceLong, String sourceLat, String desLong, String desLat) async{
  final response=await http.get(Uri.parse(
      'https://api.mapbox.com/directions-matrix/v1/mapbox/driving/'
          '$sourceLong,$sourceLat;$desLong,$desLat?annotations=duration&'
          'access_token=pk.eyJ1IjoibW91c3RhZmFtb3NhbGFtIiwiYSI6ImNsaGV6eXVrMDAzeWUzZ3BmanhtdXg3aHEifQ.brDefOUVFaLJXAgaYj8_hw'));
  final data = jsonDecode(response.body);
  return (data["durations"][0][1])/60 ;
}

FutureOr<void> openAc(double remainingTime) async{
  print('Open the ac');
  double time1 = remainingTime;
  //checks again after 5 min if the actualTime increased---->Turn it off
  await Timer(const Duration(minutes: 5), () async{
    print('if more off');
    currentPosition = await getDistace();
    remainingTime = await durationCalculation(currentPosition!.longitude.toString(), currentPosition!.latitude.toString(), def_lng, def_lat);
    if(remainingTime>time1){
      print('Turn off the ac');
    }
  });
}