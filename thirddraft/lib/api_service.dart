import 'package:get/get.dart';

class PathController extends GetxController {
  var travelTime = 0.obs;
  var stops = 0.obs;
  var price = 0.obs;

  void updateData(Map<String, dynamic> data) {
    travelTime.value = data['duration'];
    stops.value = data['numberOfTransfers'];
    price.value = data['totalPrice'];
  }
}

final pathController = PathController();
