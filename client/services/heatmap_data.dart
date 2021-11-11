import 'dart:convert';

import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:google_maps_heatmap/pages/statistics.dart';
import 'package:google_maps_heatmap/utils/location.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../globals.dart';

class HeatmapData
{
  static List<Sample> data = [];
  static Statistics statistics;

  static Future<void> getData() async
  {
    // Clears previous samples
    data.clear();

    // Generates data for the requests to Measurify
    String startDate = DateFormat('yyyy-MM-dd').format(Globals.selectedDate);
    String endDate = DateFormat('yyyy-MM-dd').format(Globals.selectedDate.add(const Duration(days: 1)));
    String filter = 'filter={"thing":"user A", "startDate": {"\$gte": "$startDate"}, "endDate": {"\$lt": "$endDate"}}';
    int nextPage = 1;

    do
    {
      // Makes request to Measurify with specified filter and page
      Response response = await get(
        Uri.parse('https://students.atmosphere.tools/v1/measurements?$filter&page=$nextPage'),
        headers: {"Authorization" : Globals.measurifyToken},
      );

      // Data contains a list of samples
      Map body = jsonDecode(response.body);
      List samples = body["docs"];

      // If samples is null some error occurred
      if(samples == null) {
        break;
      }

      // Parse samples
      for(Map sample in samples)
      {
        try
        {
          DateTime date = DateTime.parse(sample["startDate"]);
          double latitude = sample["location"]["coordinates"][0];
          double longitude = sample["location"]["coordinates"][1];
          double altitude = sample["samples"][0]["values"][0];

          data.add(Sample(date: date, latitude: latitude, longitude: longitude, altitude: altitude));
        }
        catch(exception)
        {
          print("Could not parse sample: $sample");
        }
      }

      // Checks if there is other page available
      nextPage = body["nextPage"] ?? -1;

    }while(nextPage != -1);

    /*
    Random rand = Random();
    List<String> stringSamples = DataGenerator.generateData(Globals.selectedDate, positions[rand.nextInt(positions.length)], 100+rand.nextInt(100));
    List<Map> samples = List<Map>.from(stringSamples.map((element) => json.decode(element)));

    data.clear();
    for(Map sample in samples)
    {
      DateTime date = DateTime.parse(sample["startDate"]);
      double latitude = sample["samples"][0]["latitude"];
      double longitude = sample["samples"][0]["longitude"];
      double altitude = sample["samples"][0]["altitude"];

      data.add(Sample(date: date, latitude: latitude, longitude: longitude, altitude: altitude));
    }
     */

    // Sorting data to ensure they are is chronological order
    data.sort((sample0, sample1) => sample0.date.compareTo(sample1.date));

    // Local computation to recalculate statistics
    statistics = Statistics();

    return;
  }
}