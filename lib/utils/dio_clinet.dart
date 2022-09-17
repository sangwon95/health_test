
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'custom_log_interceptor.dart';

Client client = Client();


class Client {

  Dio _createDio() {
    Dio dio = Dio();
    dio.interceptors.add(CustomLogInterceptor());
    dio.options.connectTimeout = 4000; // 4초
    dio.options.receiveTimeout = 4000; // 4초

    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'authorizationToken'
    };

    return dio;
  }

  /// Dio post method
  /// [Login], [Sign],
  /// @param path : 서버 경로
  /// @param data : Map data
  /// @param context
  Future<Response> dioPost(String path, Map<String, dynamic> data, BuildContext context) async {
    Response response;
    try {
      response = await _createDio().post(path, data: data);

      if (response.statusCode == 200) {
        if (response.data['status']['message'] == 'Success') {
          response.statusMessage = response.data['status']['message'];
          return response;
        }
        else {
          response.statusMessage = response.data['status']['message'];
          return response;
        }
      }
      else {
       // Etc.newShowSnackBar('서버 오류로 재시도 바랍니다.', context);
      }
    } on DioError catch (e) {
      print(' >>>>[DioError] : ' + e.toString());
     // Etc.newShowSnackBar('서버 연결 오류로 재시도 바랍니다.', context);
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return response;
  }

  /// Dio get method
  /// [User Info], [Chat List], [User List], [Recent Chat List Data]
  /// @param path : 서버 경로
  /// @param data : Map data
  /// @param context
  Future<Response> dioGet(String path, Map<String, dynamic> data,
      BuildContext context) async {
    Response response;
    try {
      response = await _createDio().get(
          path, queryParameters: data);

      if (response.statusCode == 200) {
        if (response.data['status']['message'] == 'Success') {
          response.statusMessage = response.data['status']['message'];
          return response;
        }
        else {
          response.statusMessage = response.data['status']['message'];
          return response;
        }
      }
      else {
       // Etc.newShowSnackBar('서버 오류로 재시도 바랍니다.', context);
      }
    } on DioError catch (e) {
      print(' >>>>[DioError] : ' + e.toString());
      //Etc.newShowSnackBar('서버 오류로 재시도 바랍니다.', context);
      throw Exception('서버 연결 오류');
    } catch (e) {
      print(e.toString());
    }
    return response;
  }
}