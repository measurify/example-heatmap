import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:google_maps_heatmap/services/heatmap_data.dart';

class HeatmapPage extends StatefulWidget
{
  const HeatmapPage({Key key}) : super(key: key);

  @override
  State<HeatmapPage> createState() => HeatmapPageState();
}

class HeatmapPageState extends State<HeatmapPage>
{
  // A controller makes it possibile to create a Future with a sync function.
  // In this case, can be used to animate the movement of the camera.
  final Completer<GoogleMapController> _controller = Completer();
  // The heatmap to display.
  Heatmap _heatmap;

  @override
  // This is called each time the heatmap page is opened
  void initState()
  {
    super.initState();

    List<WeightedLatLng> points = List<WeightedLatLng>.from(HeatmapData.data.map((loc) => WeightedLatLng(point: LatLng(loc.latitude, loc.longitude))));
    if(points.isEmpty) {
      points.add(WeightedLatLng(point: const LatLng(44.205300, 8.416455), intensity: 0));
    }

    _heatmap = _createHeatmap(points);
  }

  @override
  Widget build(BuildContext context)
  {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: createInitialPosition(_heatmap.points),
      heatmaps: { _heatmap },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  // There is no need to use setState() here because this is only used is initState()
  // where the build() function is not yet called.
  Heatmap _createHeatmap(List<WeightedLatLng> points)
  {
    return Heatmap(
             heatmapId: HeatmapId(points[0].toString()),
             points: points,
             radius: 20,
             visible: true,
             gradient:  HeatmapGradient(
                 colors: const <Color>[Colors.green, Colors.red], startPoints: const <double>[0.2, 0.8]
             )
        );
  }

  CameraPosition createInitialPosition(List<WeightedLatLng> points)
  {
    return CameraPosition(target: points[0].point, zoom:15);
  }
}