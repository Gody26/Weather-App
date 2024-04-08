//import 'dart:convert';
import 'dart:convert';
import 'dart:ui';

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';

import 'additional_info_item.dart';
import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  double temp = 0;
  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

/////////// Fetching Data From API///////////
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openWeatherAPIKey',
      ));
      final data = jsonDecode(response.body);
      // setState(() {
      //   temp = data['list'][0]['main']['temp'];
      // });
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }
/////////////////////////////////////////////////

//// Building Layout ////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          final data = snapshot.data!;
          final datalist = data['list'][0];
          final currentTemp = datalist['main']['temp'];
          final currentSky = datalist['weather'][0]['main'];
          final pressure = datalist['main']['pressure'];
          final windSpeed = datalist['wind']['speed'];
          final humidity = datalist['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Icon(
                                currentSky == 'Rain' || currentSky == 'Clouds'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 60,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                currentSky,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Weather Forecast Text
                const SizedBox(height: 30),
                const Text(
                  'Tri - Hourly Forecast',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                // Weather Cards
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 39; i++)
                //         HourlyForecastItem(
                //             time: data['list'][i + 1]['dt'].toString(),
                //             value:
                //                 data['list'][i + 1]['main']['temp'].toString(),
                //             icon: data['list'][i + 1]['weather'][0]['main'] ==
                //                         'Clouds' ||
                //                     data['list'][i + 1]['weather'][0]['main'] ==
                //                         'Rain'
                //                 ? Icons.cloud
                //                 : Icons.sunny),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 105,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky =
                          data['list'][index + 1]['weather'][0]['main'];
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForecastItem(
                          time: DateFormat.Hm().format(time),
                          value: hourlyForecast['main']['temp'].toString(),
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 15),
                // additional info
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    additionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: humidity.toString(),
                    ),
                    additionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: windSpeed.toString(),
                    ),
                    additionalInfoItem(
                      icon: Icons.umbrella,
                      label: 'Pressure',
                      value: pressure.toString(),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
