import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';

class MainStateController extends GetxController {
  RxBool isloading = false.obs;
  RxList<SearchInfo> listSource = <SearchInfo>[].obs;
  
}
