import 'package:flutter/material.dart';
import 'package:google_maps_heatmap/services/heatmap_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatefulWidget
{
  const LoadingPage({Key key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
{
  @override
  void initState()
  {
    super.initState();
    // When the LoadingScreen is opened, it starts loading the page
    // and then pops it self from the Navigator.
    HeatmapData.getData().then((value) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Center(
          child: SpinKitCircle(
            color: Theme.of(context).primaryColor,
            size: 80.0,
          )
      ),
    );
  }
}
