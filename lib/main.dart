import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<dynamic, dynamic> weather = {};
  bool daynight() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    return (hour >= 6) && (hour <= 18);
  }

  Future<Map<dynamic, dynamic>> getweather() async {
    bool serviceEnabled;
    var position;
    var response;
    String city_name='';
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      city_name = 'bangalore';
    }else{
      position=await Geolocator.getCurrentPosition();
    }
    print(position);
    print(position.latitude.toString());
    String weather_key = '56696014b1b0f79692a93ba0ec757061';
    if (position!=null){
      response = await http.get(Uri.https(
          'api.openweathermap.org',
          '/data/2.5/weather',
          {'lat': position.latitude.toString(), 'lon': position.longitude.toString(),'appid':weather_key, 'units': 'metric'}));
    }else{
      response = await http.get(Uri.https(
          'api.openweathermap.org',
          '/data/2.5/weather',
          {'q': city_name, 'appid': weather_key, 'units': 'metric'}));
    }
    String jsonweather = response.body;
    weather = jsonDecode(jsonweather);
    return weather;
  }

  @override
  Widget build(BuildContext context) {
    bool ifday = daynight();
    Color bgcolor;
    if (ifday) {
      bgcolor = Colors.white;
    } else {
      bgcolor = Color(0xff1e212a);
    }
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              final weather = snapshot.data as Map<dynamic, dynamic>;
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.all(30),
                      decoration: ShapeDecoration(
                          shape: StadiumBorder(), color: Colors.greenAccent),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                    child: Row(
                                  children: [
                                    Text(
                                      '${weather['main']['temp']}°C',
                                      style: TextStyle(fontSize: 35),
                                    ),
                                    Image(
                                        image: AssetImage(
                                            'assets/${weather['weather'][0]['icon']}.png')),
                                  ],
                                )),
                                Text('${weather['weather'][0]['main']}',
                                    style: TextStyle(fontSize: 30)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                    'Min: ${weather['main']['temp_min']}°C',
                                    style: TextStyle(fontSize: 18)),
                                Text(
                                    'Max: ${weather['main']['temp_max']}°C',
                                    style: TextStyle(fontSize: 18))
                              ],
                            )
                          ]),
                    ),
                    Container(
                      height: 300,
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40.0),
                              bottomRight: Radius.circular(40.0),
                              topLeft: Radius.circular(40.0),
                              bottomLeft: Radius.circular(40.0)),
                          color: HexColor('#4C4f69').withOpacity(0.7)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Humidity: ${weather['main']['humidity']}%',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                  Text(
                                      'Wind: ${(weather['wind']['speed'] * 180 / 5).round() / 10} km/h',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white))
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Pressure: ${weather['main']['pressure']} hPa',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                  Text(
                                      'Wind: ${weather['wind']['deg']} °',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white))
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Sunrise: ${DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunrise']*1000).hour}:${DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunrise']*1000).minute}',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white)),
                                  Text(
                                      'Sunset: ${DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunset']*1000).hour}:${DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunset']*1000).minute}',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white))
                                ]),
                          ]),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.all(20),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            getweather();
                          });
                        },
                        child: Text('refresh')),
                  ]);
            }
          },
          future: getweather(),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
