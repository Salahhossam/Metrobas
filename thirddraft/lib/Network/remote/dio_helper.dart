import 'package:dio/dio.dart';


//Authentication Request ==>  https://accept.paymob.com/api/auth/tokens
//Order Registration API ==> : https://accept.paymob.com/api/ecommerce/orders
// Payment Key Request ==>  https://accept.paymob.com/api/acceptance/payment_keys
class DioHelperPayment {
  static late Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.1.9:8001/api/',
        headers: {
          'Content-Type': 'application/json',
        },
        receiveDataWhenStatusError: true,
      ),
    );
  }

  // to get data from url
  static Future<Response> getData(
      {required String url, Map<String, dynamic>? query}) async {
    return await dio.get(url, queryParameters: query);
  }

  // post data
  static Future<Response> postData(
      {required String url,
        required Map<String, dynamic>? data,
        Map<String, dynamic>? query}) async {
    return await dio.post(url, data: data, queryParameters: query);
  }

}


  // Future<void> _performAuthentication() async {
  //   final String email = emailController.text;
  //   final String password = passwordController.text;
  //   await DioHelperPayment.postData(
  //     url: 'auth/login',
  //     data: {
  //       'userName': email,
  //       'password': password,
  //     },
  //   ).then((value) {
  //     if (value.statusCode == 200) {
  //       log(value.data);
  //       Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (context) => const SingUp()));
  //     } else {
  //       log('Authentication failed: ${value.statusCode}');
  //     }
  //   }).catchError((error) {
  //     print('Error during authentication: $error');
  //   });
  // }