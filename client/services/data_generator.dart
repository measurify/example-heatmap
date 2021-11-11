import 'dart:convert';
import 'dart:math';

import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';

class DataGenerator
{
  static List<String> generateData(DateTime date, LatLng centralPosition, int dataSamples)
  { 
    Random rand = Random();
    List<String> samples = [];

    double latitude = centralPosition.latitude;
    double longitude = centralPosition.longitude;
    double altitude = 10+rand.nextDouble()*100;

    for(int i=0; i<dataSamples; ++i)
    {
      latitude += rand.nextDouble()*sign(rand) / 2000;
      longitude += rand.nextDouble()*sign(rand) / 2000;
      altitude += rand.nextDouble()*sign(rand);
      date = date.add(const Duration(seconds: 100));

      Map sample =
      {
        "samples": [
          {
            "latitude": latitude,
            "longitude": longitude,
            "altitude" : altitude,
          }
        ],
        "startDate": date.toString(),
        "endDate": date.toString(),
      };

      samples.add(json.encode(sample));
    }

    return samples;
  }

  static int sign(Random rand)
  {
    return rand.nextBool() ? -1 : 1;
  }
}