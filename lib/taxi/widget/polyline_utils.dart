import 'package:google_maps_flutter/google_maps_flutter.dart';

List<LatLng> decodePolylineStringToLatLng(String encoded) {
  try {
    List<LatLng> latLngList = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      LatLng p = LatLng(lat / 1E5, lng / 1E5);
      latLngList.add(p);
    }

    return latLngList;
  } catch (e) {
    print(e);
    return [];
  }
}
