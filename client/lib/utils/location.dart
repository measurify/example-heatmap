import 'package:flutter/cupertino.dart';

@immutable
class Sample
{
  final DateTime date;
  final double latitude;
  final double longitude;
  final double altitude;

  const Sample({
    @required this.date,
    @required this.latitude,
    @required this.longitude,
    @required this.altitude
  });

  @override
  bool operator ==(Object other)
  {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final Sample other0 = other;
    return date == other0.date
        && latitude == other0.latitude
        && longitude == other0.longitude
        && altitude == other0.altitude;
  }

  @override
  int get hashCode => hashValues(date, latitude, longitude, altitude);
}