import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:google_maps_heatmap/services/heatmap_data.dart';
import 'package:google_maps_heatmap/utils/location.dart';

class StatisticsPage extends StatelessWidget
{
  const StatisticsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    Color bright = brighter(Theme.of(context).canvasColor);

    // If there are too few points, the statistics are not shown
    if(HeatmapData.data.isEmpty)
    {
      return SingleChildScrollView(
        child: Column(
            children: [
            const SizedBox(height: 20),
            StatisticsField(name: "Total Samples", data: HeatmapData.data.length.toString(), color: bright,),
          ],
        )
      );
    }

    // Otherwise, show the full statistics page
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          StatisticsField(name: "Total Samples", data: HeatmapData.data.length.toString(), color: bright,),
          const Divider(thickness: 5, height: 40),
          StatisticsField(name: "Max Latitude:", data: HeatmapData.statistics.maxLatitude.toStringAsFixed(3)+"°", color: bright),
          StatisticsField(name: "Min Latitude:", data: HeatmapData.statistics.minLatitude.toStringAsFixed(3)+"°"),
          StatisticsField(name: "Max Longitude:", data: HeatmapData.statistics.maxLongitude.toStringAsFixed(3)+"°", color: bright),
          StatisticsField(name: "Min Longitude:", data: HeatmapData.statistics.minLongitude.toStringAsFixed(3)+"°"),
          StatisticsField(name: "Max Altitude:", data: HeatmapData.statistics.maxAltitude.toStringAsFixed(3)+" m", color: bright),
          StatisticsField(name: "Min Altitude:", data: HeatmapData.statistics.minAltitude.toStringAsFixed(3)+" m"),
          const Divider(thickness: 5, height: 40),
          StatisticsField(name: "Travelled Distance:", data: HeatmapData.statistics.travelledDistance.toStringAsFixed(3)+" km", color: bright),
          StatisticsField(name: "Trip Time:", data: format(HeatmapData.statistics.tripTime)),
          const Divider(thickness: 5, height: 40),
        ],
      ),
    );
  }

  Color brighter(Color color)
  {
    HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withLightness(hsl.lightness+0.05).toColor();
  }

  String format(Duration duration)
  {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class StatisticsField extends StatelessWidget
{
  final String name;
  final String data;
  final Color color;

  const StatisticsField({Key key, this.name, this.data, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return Container(
      color: color,
      child: Row(children: [
        const SizedBox(width: 20),
        Expanded(
          child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          flex: 2,
        ),
        const SizedBox(width: 50, height: 35),
        Expanded(
          child: Text(data, style: const TextStyle(fontSize: 18)),
        )
      ])
    );
  }
}

class Statistics
{
  double _minLatitude = double.infinity;
  double _maxLatitude = double.negativeInfinity;
  double _minLongitude = double.infinity;
  double _maxLongitude = double.negativeInfinity;
  double _minAltitude = double.infinity;
  double _maxAltitude = double.negativeInfinity;
  double _travelledDistance = 0;
  Duration _tripTime = const Duration();

  double get minLatitude => _minLatitude;
  double get maxLatitude => _maxLatitude;
  double get minLongitude => _minLongitude;
  double get maxLongitude => _maxLongitude;
  double get minAltitude => _minAltitude;
  double get maxAltitude => _maxAltitude;
  double get travelledDistance => _travelledDistance;
  Duration get tripTime => _tripTime;

  Statistics()
  {
    _calculateMaxsMins();
    _calculateTravelledDistance();
    _calculateTripTime();
  }

  void _calculateMaxsMins()
  {
    for(Sample sample in HeatmapData.data)
    {
      if(sample.longitude > _maxLongitude) {
        _maxLongitude = sample.longitude;
      }
      if(sample.longitude < _minLongitude) {
        _minLongitude = sample.longitude;
      }

      if(sample.latitude > _maxLatitude) {
        _maxLatitude = sample.latitude;
      }
      if(sample.latitude < _minLatitude) {
        _minLatitude = sample.latitude;
      }

      if(sample.altitude > _maxAltitude) {
        _maxAltitude = sample.altitude;
      }
      if(sample.altitude < _minAltitude) {
        _minAltitude = sample.altitude;
      }
    }
  }

  void _calculateTravelledDistance()
  {
    List<LatLng> samples = List<LatLng>.from(HeatmapData.data.map((sample) => LatLng(sample.latitude, sample.longitude)));

    double distance = 0;
    for(int i=0; i<samples.length-1; ++i) {
      distance += _calculateDistanceInKM(samples[i], samples[i+1]);
    }

    _travelledDistance = distance;
  }

  void _calculateTripTime()
  {
    if(HeatmapData.data.length < 2) {
      return;
    }

    DateTime firstDate = HeatmapData.data.first.date;
    DateTime lastDate = HeatmapData.data.last.date;
    _tripTime = lastDate.difference(firstDate);
  }

  // https://en.wikipedia.org/wiki/Haversine_formula
  double _calculateDistanceInKM(LatLng point0, LatLng point1)
  {
    var p = 0.017453292519943295;    // pi / 180
    var a = 0.5 - cos((point1.latitude - point0.latitude) * p)/2 +
        cos(point0.latitude * p) * cos(point1.latitude * p) *
            (1 - cos((point1.longitude - point0.longitude) * p))/2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}

