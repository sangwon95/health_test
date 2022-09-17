
import 'package:dio/dio.dart';

class CustomLogInterceptor extends Interceptor {

  @override
  Future onRequest(RequestOptions options) {
    print(' >>>> Request[ ${options.method} ] => PATH : ${options.path}');
    // TODO: implement onRequest
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    // TODO: implement onResponse
    print(' >>>> Response[ ${response.statusCode} ] => PATH : ${response.request.path}\n',);
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    // TODO: implement onError
      print(' >>>> Error[${err.response?.statusCode}] => PATH : ${err.request.path}\n',);
    return super.onError(err);
  }
}