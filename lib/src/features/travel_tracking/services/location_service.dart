import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<void> requestPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final asked = await Geolocator.requestPermission();
      if (asked == LocationPermission.denied) {
        throw Exception('Permissão de localização negada');
      }
    }
    if (await Geolocator.isLocationServiceEnabled() == false) {
      throw Exception('Serviço de localização desabilitado');
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    );
  }
}
