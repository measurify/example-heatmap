import 'package:flutter/material.dart';
import 'package:google_maps_heatmap/globals.dart';
import 'package:google_maps_heatmap/pages/loading.dart';

class CalendarPage extends StatefulWidget
{
  const CalendarPage({Key key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
{
  @override
  Widget build(BuildContext context)
  {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "${Globals.selectedDate.toLocal()}".split(' ')[0],
            style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: const Text(
              'Select date',
            ),
          ),
        ],
      )
    );
  }

  _selectDate(BuildContext context) async
  {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: Globals.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      selectableDayPredicate: (day) {
        // Only dates before now can be selected
        return !day.isAfter(DateTime.now());
      },
      builder: (context, child){
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      }
    );

    if(picked == null || picked == Globals.selectedDate) {
      return;
    }

    // Pushes the LoadingScreen
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadingPage()));

    // Reloads the current Widget to update the shown date
    setState(() {
      Globals.selectedDate = picked;
    });
  }
}
